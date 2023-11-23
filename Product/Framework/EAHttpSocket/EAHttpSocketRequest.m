//
//  EAHttpSocketRequest.m
//  HttpSocketDemo
//
//  Created by rick on 2022/6/22.
//

#import "EAHttpSocketRequest.h"
#import "EAccountGCDAsyncSocket.h"

#define  WWW_PORT 0  // 0 => automatic
#define USE_SECURE_CONNECTION    1
#define USE_CFSTREAM_FOR_TLS     0 // Use old-school CFStream style technique
#define MANUALLY_EVALUATE_TRUST  1
#define READ_HEADER_LINE_BY_LINE 0
#define EAccountLibSocketCallBackDone @"EAccountLibSocketCallBackDone" //block 已回调过

@interface EAHttpSocketRequest()<GCDAsyncSocketDelegate>

@property (nonatomic, strong)EAURLRequest * urlRequest;

@property (nonatomic, strong)EAccountGCDAsyncSocket *asyncSocket;
//@property (nonatomic, copy) NSString *hadCallback;
@property (nonatomic, copy)requestResponseBlock responseBlock;

@property (nonatomic, assign) BOOL index;

@end

@implementation EAHttpSocketRequest


- (void)requestWithURLRequest:(EAURLRequest *)request responseBlock:(requestResponseBlock)responseBlock{
    _urlRequest = request;
    self.responseBlock = responseBlock;
    [self startSocket];
    [self startTimerTick];
}

- (void)startSocket{

    // Create our GCDAsyncSocket instance.
    self.asyncSocket = [[EAccountGCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    
    _index = NO;
    
    uint16_t port = self.urlRequest.URL.port.intValue;
    if (port == 0)
    {
#if USE_SECURE_CONNECTION
        port = 443; // HTTPS
#else
        port = 80;  // HTTP
#endif
        if (self.urlRequest.secureConnection) {
            port = 443; // HTTPS
        }else {
            port = 80;  // HTTP
        }
    }
    NSTimeInterval tempTimeOut = 3;
    if(self.urlRequest.timeoutInterval>0){
        tempTimeOut = self.urlRequest.timeoutInterval-1;
    }
    
    if (![self.asyncSocket connectToHost:self.urlRequest.URL.host onPort:port withTimeout:tempTimeOut error:&error])
    {
        NSLog(@"Unable to connect to due to invalid configuration: %@", error);
    }
    else
    {
        
    }
    if (self.urlRequest.secureConnection) {
#if USE_SECURE_CONNECTION
        
#if USE_CFSTREAM_FOR_TLS
        {
            // Use old-school CFStream style technique
            
            NSDictionary *options = @{
                                      EAccountGCDAsyncSocketUseCFStreamForTLS : @(YES),
                                      EAccountGCDAsyncSocketSSLPeerName : self.urlRequest.URL.host
                                      };
            
            [self.asyncSocket startTLS:options];
        }
        
#elif MANUALLY_EVALUATE_TRUST
        {
            NSDictionary *options = @{
                EAGCDAsyncSocketManuallyEvaluateTrust : @(YES),
                                      GCDAsyncSocketSSLPeerName : self.urlRequest.URL.host
                                      };
            [self.asyncSocket startTLS:options];
        }
#else
        {
            NSDictionary *options = @{
                                      EAccountAsyncSocketSSLPeerName : self.urlRequest.URL.host
                                      };
            //        DLog(@"Requesting StartTLS with options:\n%@", options);
            [self.asyncSocket startTLS:options];
        }
#endif
        
#endif
        
    }
    
}

- (NSData *)requestHeade{
    NSString *requestStrFrmt = nil;
    NSString *requestStr = nil;
    if ([self.urlRequest.HTTPMethod isEqualToString:@"POST"]) {
        requestStrFrmt = @"POST %@ HTTP/1.1\r\n";
        requestStr = [NSString stringWithFormat:requestStrFrmt, self.urlRequest.URL.path];
    }else{
        
        if (self.urlRequest.parametersString.length) {
            requestStrFrmt = @"GET %@?%@ HTTP/1.1\r\n";
            requestStr = [NSString stringWithFormat:requestStrFrmt, self.urlRequest.URL.path,self.urlRequest.parametersString];
        }else{
            requestStrFrmt = @"GET %@ HTTP/1.1\r\n";
            requestStr = [NSString stringWithFormat:requestStrFrmt, self.urlRequest.URL.path];
        }
    }
    
    //设置请求头
    for (NSString * key in self.urlRequest.headerFields) {
        requestStr = [requestStr stringByAppendingString:[NSString stringWithFormat:@"%@: %@\r\n", key,[self.urlRequest.headerFields valueForKey:key]]];
    }
    requestStr = [requestStr stringByAppendingString:[NSString stringWithFormat:@"reqId: %@\r\n", self.urlRequest.reqId]];
    requestStr = [requestStr stringByAppendingString:[NSString stringWithFormat:@"Host: %@\r\n", self.urlRequest.URL.host]];
    if ([self.urlRequest.HTTPMethod isEqualToString:@"POST"]) {
        NSString * parameter = @"";
        for (NSString * key in self.urlRequest.parameters) {
            if (parameter.length) {
                parameter = [parameter stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",key,[self.urlRequest.parameters valueForKey:key]]];
            }else{
                parameter = [NSString stringWithFormat:@"\r\n%@=%@",key,[self.urlRequest.parameters valueForKey:key]];
            }
        }
        requestStr = [requestStr stringByAppendingString:[NSString stringWithFormat:@"content-length: %li\r\n", parameter.length]];
        requestStr = [requestStr stringByAppendingString:parameter];
    }
    requestStr = [requestStr stringByAppendingString:@"\r\n"];
    
//    NSLog(@"-----------------------\r\n%@\r\n",requestStr);
    return [requestStr dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - socket 代理
/**
   成功连接到目标主机后的回调
 **/
- (void)socket:(EAccountGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
   
    NSData *requestData = [self requestHeade];
    
    [_asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    
    NSData *responseTerminatorData = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    
    [_asyncSocket readDataToData:responseTerminatorData withTimeout:-1.0 tag:0];
   
}


- (void)socket:(EAccountGCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler{
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)socketDidSecure:(EAccountGCDAsyncSocket *)sock{
    // This method will be called if USE_SECURE_CONNECTION is set
}

- (void)socket:(EAccountGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
}

- (void)socket:(EAccountGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"httpResponse---->>>%@",httpResponse);
    NSArray *array = [httpResponse componentsSeparatedByString:@"\r\n"];
//    NSLog(@"array---->>>%@",array);
    if (array) {
        
        NSString *str1 = [array objectAtIndex:0];
        if ([str1 hasPrefix:@"HTTP"] || [str1 hasPrefix:@"http"]) {
            
            if ([self containsStringMethod:@"302" bString:str1]) {
                
                for (int i = 0; i < array.count; i++) {
                    NSString *location = [array objectAtIndex:i];
                    if ([location rangeOfString:@"Location: " options:NSCaseInsensitiveSearch].length) {
                        NSRange range = [location rangeOfString:@"http"];
                        if (range.length > 0) {
                            NSString *url = [location substringFromIndex:range.location];
                            if ([url hasPrefix:@"https"] || [url hasPrefix:@"HTTPS"]) {
                                self.urlRequest.secureConnection = YES;
                            }else {
                                self.urlRequest.secureConnection = NO;
                            }
                                [self.asyncSocket disconnect];
                                EAURLRequest *req = [[EAURLRequest alloc] init];
                                req.URL = [NSURL URLWithString:url];
                                req.parameters = [EAParasUtil parameterWithURL:req.URL];
                                [self requestWithURLRequest:req responseBlock:self.responseBlock];
                            }else {
                                [self requestWithURLRequest:nil responseBlock:^(NSDictionary * _Nullable resultDic, NSData * _Nullable resultData, NSURLResponse * _Nullable response, NSError * _Nullable error, NSString * _Nullable reqId) {
                                    
                                }];
                            }
                            return;
                        }
                    }
                }
            }
        }
    
    //获取返回的JSON
        NSRange range1 = [httpResponse rangeOfString:@"{"];
        NSString *jsonResponseStr = @"";
        if (range1.length) {
            for (long x=httpResponse.length-1; x>0; x--) {
                NSString * subStr = [httpResponse substringFromIndex:x];
                
                if ([subStr isEqualToString:@"}"]) {
                    jsonResponseStr = [httpResponse substringWithRange:NSMakeRange(range1.location, x+1)];
                    break;
                }else if ([subStr containsString:@"}"]) {
                    jsonResponseStr = [httpResponse substringWithRange:NSMakeRange(range1.location, x-3)];
                    break;
                }
            }
        }
        
        NSDictionary *result = [EAParasUtil dicFromJsonStr:jsonResponseStr];
    
        if (result) {
            [self.asyncSocket disconnect];
            _index = NO;
    
            id codeObj = [result objectForKey:@"result"];
            NSInteger code = -98760;
            if ([codeObj respondsToSelector:@selector(integerValue)]) {
                code = [codeObj integerValue];
            }
            //如果code是30002
            if (code == 30002) {

            }
    
                if (self.responseBlock) {
                    self.responseBlock(result, [jsonResponseStr dataUsingEncoding:NSUTF8StringEncoding], nil, nil, self.urlRequest.reqId);
                    [self.asyncSocket disconnect];
                    self.responseBlock = nil;
                }
            
            return;
        }
        
        if (_index == NO) {
            _index = YES;
            
            //读取响应数据
            NSInteger contentLength = 0;
            for (NSString * str in array) {
                if ([str containsString:@"Content-Length"]) {
                    NSArray * strArr = [str componentsSeparatedByString:@":"];
                    contentLength = [strArr[1] integerValue];
                }
            }
           
            if (!contentLength) {
                NSData *responseTerminatorData = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding];
                [self.asyncSocket readDataToData:responseTerminatorData withTimeout:-1.0 tag:0];
            }else{
                [self.asyncSocket readDataToLength:contentLength withTimeout:-1 tag:tag];
            }
        }else {
            NSDictionary *errDict = @{@"msg" : @"网络错误",@"resultCode" : @"80001"};
            NSError *error = [NSError errorWithDomain:@"requestError" code:80001 userInfo:errDict];
    
            if (self.responseBlock) {
                self.responseBlock(nil, nil, nil, error, self.urlRequest.reqId);
                self.responseBlock = nil;
            }
        }
}

- (BOOL)containsStringMethod:(NSString *)aString bString:(NSString *)bString{
    if (!aString || [aString isEqualToString:@""]) {
        return NO;
    }
    if ([bString rangeOfString:aString].location != NSNotFound) {
        return YES;
        
    }
    return NO;
}

- (void)socketDidDisconnect:(EAccountGCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        //获取error描述
        NSString *errStr = [EAParasUtil getDescriptionFromError:err];
        //确定错误码
        NSInteger errCode = [EAParasUtil getErrCode:errStr];
        NSString *errCodeStr = [NSString stringWithFormat:@"%ld",errCode];
        NSDictionary *errDict = @{@"msg" : errStr,@"resultCode" : errCodeStr};
        NSError *newerror = [NSError errorWithDomain:@"requestError" code:errCode userInfo:errDict];
        if (self.responseBlock) {
            self.responseBlock(nil, nil, nil, newerror, self.urlRequest.reqId);
            self.responseBlock = nil;
        }
    }
}

- (BOOL)isDisConnect {
    return self.asyncSocket.isDisconnected;
}

- (BOOL)isConnected{
    return self.asyncSocket.isConnected;
}

#pragma mark - 超时

//请求计时器
- (void)startTimerTick{
    
    if (self.urlRequest.timeoutInterval == 0) {
        self.urlRequest.timeoutInterval = 3;
    }
    
    dispatch_source_t gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));

    dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.urlRequest.timeoutInterval * NSEC_PER_SEC));
    dispatch_source_set_timer(gcdTimer, tt, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);

    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(gcdTimer, ^{
        [weakSelf timeTick];
        dispatch_suspend(gcdTimer);
    });

    dispatch_resume(gcdTimer);
}

/// 超时处理
- (void)timeTick {
    if (self.responseBlock) {
        [self.asyncSocket disconnect];
        NSDictionary *errDict = @{@"msg" : @"请求超时",@"resultCode" : @"80000"};
        NSError *newError = [NSError errorWithDomain:@"requestError" code:80000 userInfo:errDict];
        
        self.responseBlock(nil, nil, nil, newError, self.urlRequest.reqId);
        self.responseBlock = nil;
    }
}

@end

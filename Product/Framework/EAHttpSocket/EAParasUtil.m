//
//  EAParasUtil.m
//  HttpSocketDemo
//
//  Created by rick on 2022/6/23.
//

#import "EAParasUtil.h"
#import <CoreTelephony/CTCellularData.h>

#include <ifaddrs.h>
#include <sys/socket.h>
#import <sys/ioctl.h>
#include <net/if.h>
#import <arpa/inet.h>
#import <netdb.h>

@implementation EAParasUtil

+ (BOOL) EAccountAPIIsEmptyStr:(NSString *)string
{
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (NSDictionary*)dicFromJsonStr:(NSString*)json{
    json = [json stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    if (!json) {
        return nil;
    }
    NSDictionary * dic;
    NSError *error = nil;
    NSData * data = [json dataUsingEncoding:NSUTF8StringEncoding];
    dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(error)
    {
        NSLog(@"json解析失败：%@",error.localizedDescription);
        return nil;
    }
    return  dic;
}

+ (NSString *)stringFromDic:(NSDictionary *) dic{
    if(!dic){
        return nil;
    }
    NSError * error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    if(error)
    {
        NSLog(@"dic解析失败：%@",error.localizedDescription);
        return nil;
    }
    NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}


+ (NSDictionary *)parameterWithURL:(NSURL *) url {
 
    NSMutableDictionary *parm = [[NSMutableDictionary alloc]init];
 
    //传入url创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
 
    //回调遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [parm setObject:obj.value forKey:obj.name];
    }];
 
    return parm;
}

+ (NSString *)getDescriptionFromError:(NSError *)error {
    NSString *errStr  =@"";
    NSDictionary *d = error.userInfo ;
    if(d){
        errStr = [d objectForKey:@"NSLocalizedDescription"];
        if (errStr==nil) {
            errStr = @"网络连接失败";
        }
    }else{
        errStr = @"网络连接失败";
    }
    return errStr;
}

+ (NSInteger)getErrCode:(NSString *)errStr {
    NSInteger errCode = 80001;//默认是80001
    if ([errStr containsString:@"请求超时"] || [errStr containsString:@"The request timed out"] || [errStr containsString:@"Attempt to connect to host timed out"]) {
        errCode = 80000;//超时是80000
    }else if ([errStr containsString:@"No route to host"]) {
        errCode = 80008;
    }else if ([errStr containsString:@"nodename nor servname provided, or not known"]) {
        errCode = 80009;
    }else if ([errStr containsString:@"Socket closed by remote peer"]) {
        errCode = 80010;
    }
    return errCode;
}

@end

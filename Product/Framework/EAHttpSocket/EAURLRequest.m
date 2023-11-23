//
//  EARequest.m
//  HttpSocketDemo
//
//  Created by rick on 2022/6/22.
//

#import "EAURLRequest.h"

@interface EAURLRequest()


@end

@implementation EAURLRequest

- (instancetype)init{
    if (self=[super init]) {
        self.reqId = [self getRandomUUID];
    }
    return self;
}


- (void)setURL:(NSURL *)URL{
    _URL = URL;
    if ([_URL.scheme hasPrefix:@"https"] || [_URL.scheme hasPrefix:@"HTTPS"]) {
        _secureConnection = YES;
    }
}

- (NSMutableDictionary *)headerFields{
    if (!_headerFields) {
        _headerFields = [NSMutableDictionary dictionary];
    }
    return _headerFields;
}

- (void)setParameters:(NSDictionary<NSString *,NSString *> *)parameters{
    _parameters = parameters;
    NSString * str = @"";
    for (NSString * key in _parameters) {
        str = [str stringByAppendingString:[NSString stringWithFormat:str.length?@"&%@=%@":@"%@=%@",key,[self.parameters valueForKey:key]]];
    }
    _parametersString = str;
}

- (NSString *)getRandomUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    uuid = [uuid lowercaseString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuid;
}


@end

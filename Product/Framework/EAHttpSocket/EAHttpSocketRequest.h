//
//  EAHttpSocketRequest.h
//  HttpSocketDemo
//
//  Created by rick on 2022/6/22.
//

#import <Foundation/Foundation.h>
#import "EAURLRequest.h"
#import "EAParasUtil.h"

NS_ASSUME_NONNULL_BEGIN

typedef   void (^requestResponseBlock) ( NSDictionary * _Nullable resultDic, NSData * _Nullable resultData,  NSURLResponse * _Nullable  response,  NSError * _Nullable  error ,NSString * _Nullable reqId );

typedef   void (^requestResponseBlockSEC) ( NSDictionary * _Nullable resultDic, NSData * _Nullable resultData,  NSURLResponse * _Nullable  response,  NSError * _Nullable  error ,NSString * _Nullable reqId, NSString * _Nullable randomkey_block);

@interface EAHttpSocketRequest : NSObject

- (void)requestWithURLRequest:(EAURLRequest *) request responseBlock:(requestResponseBlock) responseBlock;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END

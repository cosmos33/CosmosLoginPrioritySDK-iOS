//
//  EARequest.h
//  HttpSocketDemo
//
//  Created by rick on 2022/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EAURLRequest : NSObject

@property (nonatomic, copy)NSString * HTTPMethod;

@property (nonatomic, copy)NSString * reqId;

@property (nonatomic,strong) NSURL *URL;

@property (nonatomic)NSTimeInterval timeoutInterval;

@property (nonatomic, copy)NSDictionary<NSString*,NSString*> * parameters;

@property (nonatomic, strong)NSMutableDictionary * headerFields;

@property (nonatomic, assign)BOOL secureConnection;

@property (nonatomic, copy)NSString * parametersString;

@end

NS_ASSUME_NONNULL_END

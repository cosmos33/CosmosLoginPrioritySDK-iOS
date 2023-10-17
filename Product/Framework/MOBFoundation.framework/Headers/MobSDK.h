//
//  MobSDK.h
//  MOBFoundation
//
//  Created by liyc on 17/2/23.
//  Copyright © 2017年 MOB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOBSDKDef.h"

/**
 MobSDK
 */
@interface MobSDK : NSObject

/**
 获取版本号

 @return 版本号
 */
+ (NSString * _Nonnull)version;

/**
 获取应用标识
 
 @return 应用标识
 */
+ (NSString * _Nullable)appKey;

/**
 获取应用密钥

 @return 应用密钥
 */
+ (NSString * _Nullable)appSecret;


/**
 获取隐私协议级别
 
 @return 协议级别
 */
+ (int)privacyLevel;

/**
 获取当前国际域名

 @return 域名
 */
+ (NSString *_Nullable)getInternationalDomain;

/**
 设置国际域名

 @param domainType 域名类型
 */
+ (void)setInternationalDomain:(MOBFSDKDomainType)domainType;

/**
 变更应用密钥，针对服务器刷新应用密钥后，可以通过该方法进行修改

 @param appSecret 应用密钥
 */
+ (void)changeAppSecret:(NSString * _Nonnull)appSecret;

/**
 注册appKey、appSecret,确保在 didFinishLaunchingNotification 中调用

 @param appKey appKey
 @param appSecret appSecret
 @param privacyLevel 隐私协议级别(需要同意一次=2,不需要同意=0,建议使用2,避免政策变动，功能不可用)

 */
+ (void)registerAppKey:(NSString * _Nonnull)appKey
             appSecret:(NSString * _Nonnull)appSecret
          privacyLevel:(int)level;


@end

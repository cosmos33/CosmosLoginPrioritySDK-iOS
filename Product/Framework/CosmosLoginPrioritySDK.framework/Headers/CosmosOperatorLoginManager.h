//
//  CosmosOperatorAdapter.h
//  LoginSDK
//
//  Created by wangxuefei on 2019/10/28.
//  Copyright © 2019 MOMO. All rights reserved.
// 当前版本号:高级权限 0.0.1

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CosmosOperatorType.h"

NS_ASSUME_NONNULL_BEGIN


/**
 用于预取号
 @param resultDic 三大运营商回调信息
 @param error 为空表示预取号失败。
 */
typedef void(^PreLoginCallback)( NSDictionary * _Nullable   resultDic,  NSError * _Nullable  error);


/**
 拉起登录页点击一键登录获取到手机号的回调
 */

typedef PreLoginCallback LoginCallback;


/**
 登录页按钮点击事件
 */
typedef void (^LoginClickAction)(NSDictionary * _Nullable   resultDic, CosmosOperatorsType type);



@interface CosmosOperatorLoginManager : NSObject


+ (void)initSDK:(NSString *)appid;


/**
 支持三网，如果运营商支持异网取号，仅配置了移动/联通/电信 其中1个或2个。如：仅配置了电信
 移动和联通的手机号会尝试使用电信的SDK预取号。
 
 ps:目前双卡手机默认开启，单卡手机默认关闭。
 */

+ (void)supportAllOperator:(BOOL)isSupport;

/**
 配置各运营商id
 @param appId  运营商的appid
 @param appKey 运营商的appKey
 @param registerType 运营商类型
 @param encrypType 加密类型：预留参数，暂时传nil
 各运营商对应关系:移动: appId:APPID appKey:APP Secret
               联通: appId:应用标识 appKey:应用密钥
               电信: appId:AppID  appKey:AppSecret
 */
+ (void)registerAppId:(NSString *)appId
               appKey:(NSString *)appKey
                 type:(CosmosOperatorsType)registerType
           encrypType:(NSString * _Nullable)encrypType;

/**
 预取号: 业务方根据是否有error来判断是否跳转 一键登录。
 @param timeoutInterval 单次q预取号的超时时间(网络原因导致的 预取号失败，会默认发起一次重试)。
 resultDic:{
    @"securityPhone" : @"1111xxxx111", //手机掩码
    @"traceId": @"",  //运营商的traceId(排查问题时用到)
    @"source" : @""  //预取号成功的运营商类型（移动 10086  联通 10010）
 }
 */
+ (void)requestPreLogin:(NSTimeInterval)timeoutInterval
             completion:(PreLoginCallback)preLoginCallback;



/**
 获取授权码
 resultDic {
        @"appid" : @"",
        @"token" : @"",
        @"source": @""    (移动10086，联通10010)
 }

 */
+ (void)getAuthorizationCompletion:(LoginCallback)callBack;


@end

NS_ASSUME_NONNULL_END

//
//  EAParasUtil.h
//  HttpSocketDemo
//
//  Created by rick on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EAParasUtil : NSObject

/// json字符串转字典
/// @param json JSON字符串
+ (NSDictionary*)dicFromJsonStr:(NSString*)json;

/// 字典转字符串
/// @param dic 字典
+ (NSString *)stringFromDic:(NSDictionary *) dic;


/// URL参数转字典
/// @param url get路径
+ (NSDictionary *)parameterWithURL:(NSURL *) url;

+ (NSString *)getDescriptionFromError:(NSError *)error;

+ (NSInteger)getErrCode:(NSString *)errStr;

@end

NS_ASSUME_NONNULL_END

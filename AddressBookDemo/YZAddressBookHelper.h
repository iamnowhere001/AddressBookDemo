//
//  YZAddressBookHelper.h
//  YZCommunity
//
//  Created by 曾治铭 on 15/10/26.
//  Copyright © 2015年 压寨团队. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YZAddressBookHelper : NSObject

/**
 *  请求通讯录数据, 按字母分类排序,返回排序后的字典数组
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookByAlphabetClassifySortArrayWithSuccess:(void (^)(NSArray *addressBookArray))success fail:(void (^)())fail;

/**
 *  请求通讯录数据, 按字母分类排序,返回字典
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookByAlphabetClassifySortDictWithSuccess:(void (^)(NSDictionary *addressBookDict))success fail:(void (^)())fail;

#pragma mark - 字典数组

/**
 *  请求通讯录数据数组
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookArrayWithSuccess:(void (^)(NSArray *addressBookArray))success fail:(void (^)())fail;

/**
 *  请求通讯录数据字典
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookDictionaryWithSuccess:(void (^)(NSDictionary *addressBookDict))success fail:(void (^)())fail;

/**
 *  请求通讯录访问权限
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookWithSuccess:(void (^)())success fail:(void (^)())fail;

/**
 *  打开设置界面，设置权限（ios8以上生效）
 */
+ (void)openApplicationSettings;

/**
 *  获取通讯录数据
 *
 *  @return 通讯录字典对象
 */
+(NSDictionary *)getAddressBookDictionary;

@end

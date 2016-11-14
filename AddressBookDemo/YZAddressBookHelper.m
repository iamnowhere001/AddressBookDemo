//
//  YZAddressBookHelper.m
//  YZCommunity
//
//  Created by 曾治铭 on 15/10/26.
//  Copyright © 2015年 压寨团队. All rights reserved.
//

#import "YZAddressBookHelper.h"
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#import "pinyin.h"

@implementation YZAddressBookHelper

/**
 *  请求通讯录数据, 按字母分类排序,返回排序后的字典数组
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookByAlphabetClassifySortArrayWithSuccess:(void (^)(NSArray *addressBookArray))success fail:(void (^)())fail
{
    [self requestAddressBookWithSuccess:^{
        // 获取通讯录字典
        NSDictionary *addressBookDict = [self getAddressBookDictionary];
        // 按字母分类排序
        addressBookDict = [self alphabetClassifySortWithDictionary:addressBookDict];
        // 获取字典key
        NSArray *keyArray = [addressBookDict allKeys];
        // 排序KEY
        NSArray *sortArray = [keyArray sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *keySortArray = [NSMutableArray arrayWithArray:sortArray];
        if ([sortArray containsObject:@"#"]) {
            [keySortArray removeObject:@"#"];
            [keySortArray addObject:@"#"];
        }
        
        // 将通讯录字典按排序添加到数组中
        NSMutableArray *addressBookArray = [NSMutableArray array];
        for (NSString *key in keySortArray) {
            NSMutableDictionary *addressDict = [NSMutableDictionary dictionary];
            [addressDict setObject:key forKey:@"key"];
            [addressDict setObject:addressBookDict[key] forKey:@"value"];
            [addressBookArray addObject:addressDict];
        }
        success(addressBookArray);
        
    } fail:^{
        fail();
    }];
}

/**
 *  请求通讯录数据, 按字母分类排序,返回字典
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookByAlphabetClassifySortDictWithSuccess:(void (^)(NSDictionary *addressBookDict))success fail:(void (^)())fail
{
    [self requestAddressBookWithSuccess:^{
        // 获取通讯录字典
        NSDictionary *addressBookDict = [self getAddressBookDictionary];
        // 按字母分类排序
        addressBookDict = [self alphabetClassifySortWithDictionary:addressBookDict];
        success(addressBookDict);
        
    } fail:^{
        fail();
    }];
}

/**
 *  按字母分类排序
 *
 *  @param addressBookDict 通讯录字典
 *
 *  @return 按字母分类排序后的数组字典
 */
+ (NSDictionary *)alphabetClassifySortWithDictionary:(NSDictionary *)addressBookDict
{
    // 字母分类排序字典
    NSMutableDictionary *alphabetSortDcit = [NSMutableDictionary dictionary];
    
    // 添加“pinyin”字段
    NSArray *pinyinDictArray = [self addConvertPinyinWithDictionary:addressBookDict];
    
    // 按照“pinyin”字段排序数组
    NSArray *pinyinSortDictArray =  [self sortDictionaryArrayWithKey:@"pinyin" dictArray:pinyinDictArray];
    
    // 遍历通讯录数组
    for (NSMutableDictionary *pinyinDict in pinyinSortDictArray)
    {
        
       NSString *pinyin = pinyinDict[@"pinyin"];
        
        // 分类键和分类数组
        NSString *key = [pinyin substringToIndex:1];
        NSMutableArray *classifyArray;

        // 判断是否为大写字母
        int keyChar = [pinyin characterAtIndex:0];
        if((keyChar >= 'A') && (keyChar <= 'Z'))
        {
            // 获取"name"字段的第一个字符, 判断是否为中文
            NSString *name = pinyinDict[@"name"];
            int firstChar = [name characterAtIndex:0];
            if(!(firstChar > 0x4e00 && firstChar < 0x9fff)){
                // 如果不是中文，则将“pinyin”字段的值转换为开头大写，其余小写
                [pinyinDict setObject:[pinyin capitalizedString] forKey:@"pinyin"];
            }
            
        }else{
            // 数字, 特殊字符
            key = @"#";
        }
        
        // 更新分类排序字典中的数组
        classifyArray = [alphabetSortDcit objectForKey:key];
        if (!classifyArray) {
            classifyArray = [NSMutableArray array];
        }
        [classifyArray addObject:pinyinDict];
        [alphabetSortDcit setObject:classifyArray forKey:key];

    }
    return alphabetSortDcit;
}

#pragma mark - 字典数组
/**
 *  请求通讯录数据数组
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookArrayWithSuccess:(void (^)(NSArray *addressBookArray))success fail:(void (^)())fail
{
    [self requestAddressBookWithSuccess:^{
        
        // 存储字典数组
        NSMutableArray *addressBookArray = [NSMutableArray array];

        // 获取通讯录字典数据
        NSDictionary *addressBookDict = [self getAddressBookDictionary];
        
        // 遍历字典
        for (NSString *phone in [addressBookDict allKeys]) {
            [addressBookArray addObject:@{@"name":[addressBookDict objectForKey:phone], @"phone":phone}];
        }
        
        success(addressBookArray);
        
    } fail:^{
        fail();
    }];
}

/**
 *  请求通讯录数据字典
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookDictionaryWithSuccess:(void (^)(NSDictionary *addressBookDict))success fail:(void (^)())fail
{
    [self requestAddressBookWithSuccess:^{
        NSDictionary *addressBookDict = [self getAddressBookDictionary];
        success(addressBookDict);
    } fail:^{
        fail();
    }];
}

/**
 *  请求通讯录访问权限
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
+(void)requestAddressBookWithSuccess:(void (^)())success fail:(void (^)())fail
{
    //创建通讯录对象
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    //请求访问用户通讯录,注意无论成功与否block都会调用
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            success();
        }else{
            fail();
            NSLog(@"获取通讯录访问权限失败：%@", error);
        }
    });
}

/**
 *  打开设置界面，设置权限（ios8以上生效）
 */
+ (void)openApplicationSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 *  获取通讯录数据
 *
 *  @return 通讯录字典对象
 */
+(NSDictionary *)getAddressBookDictionary
{
    // 存储通讯录的字典，键为phone，值为name
    NSMutableDictionary *addressBookDict = [NSMutableDictionary dictionary];
    
    // 取得通讯录访问授权
    ABAuthorizationStatus authorization= ABAddressBookGetAuthorizationStatus();
    // 如果未获得授权
    if (authorization != kABAuthorizationStatusAuthorized) {
        NSLog(@"尚未获得通讯录访问授权！");
        return addressBookDict;
    }
    
    // 取得通讯录中所有人员记录
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);

    // 通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    // 循环，获取每个人的个人信息
    for (NSInteger i = 0; i < nPeople; i++)
    {
        // 获取通讯录联系人信息
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        // 获取手机号信息
        ABMultiValueRef phoneNumbersRef= ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, 0));
        
        // 去除非法字符
        if (phone != nil && phone.length >= 11) {
            // 去除开头的“+86”
            if ([phone hasPrefix:@"+86"]) {
                phone = [phone substringFromIndex:[@"+86" length]];
            }
            // 非数字字符
            phone = [phone stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phone length])];
        }else{
            //释放资源，跳过本条记录
            if (phoneNumbersRef) CFRelease(phoneNumbersRef);
            if (person) CFRelease(person);
            continue;
        }
        
        // 判断是否为11位并且1开头的手机号码
        if (phone == nil || phone.length != 11 || ![phone hasPrefix:@"1"]) {
            //释放资源，跳过本条记录
            if (phoneNumbersRef) CFRelease(phoneNumbersRef);
            if (person) CFRelease(person);
            continue;
        }
        
        
        // 获取个人名字信息
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        
//        NSString *fullName = (__bridge NSString *)ABRecordCopyCompositeName(person);
//        
//        // 拼接姓名全称
//        NSMutableString *name = [[NSMutableString alloc] init];
//        if (fullName != nil && fullName.length > 0) {
//            // 如果有全称，直接使用全称
//            [name appendString:fullName];
//        }else{
//            // 没有全称，则拼接姓名
//            if (firstName != nil && firstName.length > 0) {
//                [name appendString:firstName];
//            }
//            if (lastName != nil && lastName.length > 0) {
//                if (name.length > 0) {
//                    [name appendString:@" "];
//                }
//                [name appendString:lastName];
//            }
//        }
        
        // 拼接姓名
        NSMutableString *name = [[NSMutableString alloc] init];
        if (lastName != nil && lastName.length > 0) {
            [name appendString:lastName];
        }
        if (firstName != nil && firstName.length > 0) {
            [name appendString:firstName];
        }
        
        // 如果没有获取名称,则标记为未知姓名
        if (name.length == 0) {
            [name appendString:@"未知姓名"];
        }
        
        // 添加联系人字典到字典
        [addressBookDict setObject:name forKey:phone];
        
        //释放资源
        if (phoneNumbersRef) CFRelease(phoneNumbersRef);
        if (person) CFRelease(person);
    }
    
    //释放资源
    if (allPeople) CFRelease(allPeople);

    return addressBookDict;
}


/**
 *  添加通讯录中姓名解析的拼音
 *
 *  @param addressBookDict 通讯录字典
 *
 *  @return 返回带有的pinyin的字典数组
 */
+ (NSArray *)addConvertPinyinWithDictionary:(NSDictionary *)addressBookDict
{
    // 存储排序后的字典
    NSMutableArray *addressBookArray = [NSMutableArray array];
    
    // 遍历字典
    for (NSString *phone in [addressBookDict allKeys]) {
        
        // 获取名字
        NSString *name = [addressBookDict objectForKey:phone];
        if (name == nil || name.length == 0) {
            name = @"未知姓名";
        }
        
        // 解析名字中的拼音首字母
        NSString *pinyin=[NSString string];
        for(int j = 0; j < name.length; j++){
            NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([name characterAtIndex:j])]uppercaseString];
            pinyin=[pinyin stringByAppendingString:singlePinyinLetter];
        }
        if (pinyin == nil || pinyin.length == 0) {
            pinyin = @"WZXM";
        }
        
        // 将联系人信息存入字典
        NSMutableDictionary *personDict = [NSMutableDictionary dictionary];
        [personDict setObject:phone forKey:@"phone"];
        [personDict setObject:name forKey:@"name"];
        [personDict setObject:pinyin forKey:@"pinyin"];
        
        // 将联系人字典信息添加到数组中
        [addressBookArray addObject:personDict];        
    }
    // 返回添加pinyin的字典数组
    return addressBookArray;
}

/**
 *  将字典数组通过指定的key进行排序
 *
 *  @param key       排序的key
 *  @param dictArray 排序的字典数组
 *
 *  @return 排序后的字典数组
 */
+ (NSMutableArray *)sortDictionaryArrayWithKey:(NSString *)key dictArray:(NSArray *)dictArray
{
    NSMutableArray *sortArray = [NSMutableArray arrayWithArray:dictArray];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]];
    [sortArray sortUsingDescriptors:sortDescriptors];
    return sortArray;
}

/**
 *  转换通讯录字典中“pinyin”字段为开头大写，其余小写
 *
 *  @param addressBookArray 带有“pinyin”字段的通讯录字典数组
 *
 *  @return 转换后的字典数组
 */
+(NSArray *)convertCapitalizedPinyinWithArray:(NSArray *)addressBookArray
{
    NSMutableArray *convertPinyinArray = [NSMutableArray array];
    
    // 遍历通讯录数组
    for (NSDictionary *addressDict in addressBookArray) {
        NSMutableDictionary *convertPinyinDict = [NSMutableDictionary dictionaryWithDictionary:addressDict];
        // 将“pinyin”字段的值转换为开头大写，其余小写
        NSString *capitalizedPinyin = [addressDict[@"pinyin"] capitalizedString];
        [convertPinyinDict setObject:capitalizedPinyin forKey:@"pinyin"];
        [convertPinyinArray addObject:convertPinyinDict];
    }
    return convertPinyinArray;
}

///**
// *  判断字符串首字母类型
// *
// *  @param str 字符串
// *
// *  @return 字符串首字母类型，0=其它，1=数字，2=大写字母，3=小写字母，4=中文汉字
// */
//+ (int)isFirstCharacterTypeWithString:(NSString *)str
//{
//    int firstChar = [str characterAtIndex:0];
//    
//    // 判断数字
//    if ((firstChar > 47) && (firstChar < 58)) {
//        return 1;
//    }
//    
//    // 判断大写字母
//    if ((firstChar > 64) && (firstChar < 91)) {
//        return 2;
//    }
//    
//    // 判断小写字母
//    if ((firstChar > 96) && (firstChar < 123)) {
//        return 3;
//    }
//    
//    // 判断中文
//    if(firstChar > 0x4e00 && firstChar < 0x9fff)
//    {
//        return 4;
//    }
//    
//    return  0;
//}
//
//
//
///**
// *  将通讯录字典进行分类，"special"=特殊字符，"number"=数字，"alphabet"=字母，"chinese"=中文汉字
// *
// *  @param addressBookDict 通讯录字典
// *
// *  @return 分类字典
// */
//+ (NSDictionary *)classifyAddressBookDictWithDictionary:(NSDictionary *)addressBookDict
//{
//    NSMutableDictionary *specialDict = [NSMutableDictionary dictionary]; // 特殊字符
//    NSMutableDictionary *numberDict = [NSMutableDictionary dictionary];  // 数字
//    NSMutableDictionary *alphabetDict = [NSMutableDictionary dictionary];// 大小写字母
//    NSMutableDictionary *chineseDict = [NSMutableDictionary dictionary]; // 中文汉字
//    
//    // 遍历字典
//    for (NSString *phone in [addressBookDict allKeys]) {
//        
//        // 获取名字
//        NSString *name = [addressBookDict objectForKey:phone];
//        
//        // 获取首字母类型
//        int type = [self isFirstCharacterTypeWithString:name];
//        
//        // 分类
//        switch (type) {
//            case 0: // 特殊字符
//                [specialDict setObject:name forKey:phone];
//                break;
//            case 1: // 数字
//                [numberDict setObject:name forKey:phone];
//                break;
//            case 2: // 大写字母
//            case 3: // 小写字母
//                [alphabetDict setObject:name forKey:phone];
//                break;
//            case 4: // 中文汉字
//                [chineseDict setObject:name forKey:phone];
//                break;
//            default:
//                break;
//        }
//    }
//    
//    // 将分类添加到字典中
//    NSMutableDictionary *classifyDict = [NSMutableDictionary dictionary]; // 分类字典
//    [classifyDict setObject:specialDict forKey:@"special"];
//    [classifyDict setObject:numberDict forKey:@"number"];
//    [classifyDict setObject:alphabetDict forKey:@"alphabet"];
//    [classifyDict setObject:chineseDict forKey:@"chinese"];
//    
//    return classifyDict;
//}
//



@end

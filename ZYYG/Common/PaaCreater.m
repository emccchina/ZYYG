//
//  PaaCreater.m
//  AllinpayTest_ObjC
//
//  Created by allinpay-shenlong on 14-10-27.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "PaaCreater.h"

@implementation PaaCreater

static int count = 0;

+ (NSString *)createrWithOrderNo:(NSString*)orderNo productName:(NSString*)name money:(NSString*)money type:(NSInteger)type shopNum:(NSString *)shopNum key:(NSString *)shopKey
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate * workDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate timeIntervalSinceReferenceDate]];
    NSString * timeStr = [dateFormatter stringFromDate:workDate];
    NSString *receiveURL = [NSString stringWithFormat:@"%@?type=%ld&member=%@&source=iOS", kReceiveURLForPay,(long)type,[UserInfo shareUserInfo].userKey];
    NSArray * paaDic = @[
                         @"1", @"inputCharset",
                         receiveURL, @"receiveUrl",
                         @"v1.0", @"version",
                         @"1", @"signType",
                         shopNum, @"merchantId",
                         orderNo, @"orderNo",
                         money, @"orderAmount",
                         @"0", @"orderCurrency",
                         timeStr, @"orderDatetime",
                         name, @"productName",
                         @"0", @"payType",
                         shopKey, @"key",
                         ];
    
    NSString *paaStr = [self formatPaa:paaDic];
    count++;
    
    return paaStr;
}

+ (NSString *)formatPaa:(NSArray *)array {
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    NSMutableString *paaStr = [[NSMutableString alloc] init];
    for (int i = 0; i < array.count; i++) {
        [paaStr appendFormat:@"%@=%@&", array[i+1], array[i]];
        mdic[array[i+1]] = array[i];
        i++;
    }
    NSString *signMsg = [self md5:[paaStr substringToIndex:paaStr.length - 1]];
    mdic[@"signMsg"] = signMsg.uppercaseString;
    if (mdic[@"key"]) {//商户私有签名密钥 通联后台持有不传入插件
        [mdic removeObjectForKey:@"key"];
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:mdic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    [paaStr setString:jsonStr];
    return paaStr;
}

+ (NSString *)md5:(NSString *)string {
    const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    CC_LONG strLen = (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    unsigned char *result = calloc(CC_MD5_DIGEST_LENGTH, sizeof(unsigned char));
    CC_MD5(str, strLen, result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [hash appendFormat:@"%02x", result[i]];
    }
    
    free(result);
    
    return hash;
}

@end

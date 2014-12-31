//
//  PaaCreater.h
//  AllinpayTest_ObjC
//
//  Created by allinpay-shenlong on 14-10-27.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "APay.h"
//支付订单生成
@interface PaaCreater : NSObject

/*orderNo  订单号
 *name     商品名字
 *money    签署量  分为单位
 *订单就是 1 保证金就是 2
 */
+ (NSString *)createrWithOrderNo:(NSString*)orderNo productName:(NSString*)name money:(NSString*)money type:(NSInteger)type;

@end

//
//  OrderSubmitModel.h
//  ZYYG
//
//  Created by EMCC on 15/2/2.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"
#import "ClassifyModel.h"
#import "AdressModel.h"

@interface OrderSubmitModel : NSObject

/* 选择普通发票时:
 * 1.发票抬头可写。
 * 2.税费 = (商品总额 + 包装费 + 配送费 - 立减金额 - 其他优惠) * 税点。
 * 3.订单总额 = 商品总额 + 包装费 + 配送费 + 税费。
 * 4.实收总额 = 订单总额 - 立减金额 - 其他优惠。
 * 5.应付总额 = 实收总额 - 已付总额。
 */

@property (nonatomic, assign) CGFloat   totalPrice;//商品总额
@property (nonatomic, assign) CGFloat   packPrice;//包装费用
@property (nonatomic, assign) CGFloat   delivPrice;//配送费用
@property (nonatomic, assign) CGFloat   taxPrice;//税费
@property (nonatomic, assign) CGFloat   cutPrice;//立减金额
@property (nonatomic, assign) CGFloat   favoPrice;//优惠金额
@property (nonatomic, assign) CGFloat   dealPrice;//应付金额
@property (nonatomic, assign) CGFloat   paidPrice;//已付金额

@property (nonatomic, strong) NSString      *invoiceType;//发票 0 不要票；10 普通发票；20 增值税发票
@property (nonatomic, strong) NSString      *userKey;
@property (nonatomic, strong) NSString      *productIDs;//产品id 组合 成字符串
@property (nonatomic, strong) ClassifyModel      *delivery;//配送code
@property (nonatomic, strong) ClassifyModel      *packing;//包装code
@property (nonatomic, strong) NSDictionary  *invoiceInfo;
@property (nonatomic, strong) NSString      *addressID;

-(MutableOrderedDictionary *)dictWithAES;

- (void)calculatePrice;

@end

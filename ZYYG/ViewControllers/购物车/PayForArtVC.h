//
//  PayForArtVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

//填写订单
@interface PayForArtVC : BaseViewController

@property (nonatomic, strong) NSArray *products;
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
@end

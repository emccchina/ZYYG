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
@property (nonatomic, assign) CGFloat   totalPrice;
@property (nonatomic, assign) CGFloat   packPrice;
@property (nonatomic, assign) CGFloat   delivPrice;
@property (nonatomic, assign) CGFloat   taxPrice;
@end

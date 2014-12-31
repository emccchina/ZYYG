//
//  CartModel.h
//  ZYYG
//
//  Created by EMCC on 14/12/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//购物车模型
@interface CartModel : NSObject

@property (nonatomic, copy) NSString    *ImageUrl;//商品图片地址
@property (nonatomic, copy) NSString    *product_id;//商品编号
@property (nonatomic, copy) NSString    *size;
@property (nonatomic, copy) NSString    *Title;
@property (nonatomic, copy) NSString    *Count;
@property (nonatomic, copy) NSString    *Num;
@property (nonatomic, copy) NSString    *Money;
@property (nonatomic, assign) BOOL  selected;

- (void)parseDict:(NSDictionary*)dict;

@end

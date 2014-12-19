//
//  OrderModel.h
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject

@property (nonatomic, strong) NSString          *OrderCode;
@property (nonatomic, strong) NSString          *OrderType;
@property (nonatomic, strong) NSString          *CreateTime;
@property (nonatomic, assign) NSString          *GoodsTotal;
@property (nonatomic, strong) NSString          *OrderMoney;
@property (nonatomic, strong) NSString          *OrderStatus;
@property (nonatomic, assign) NSInteger          state;
@property (nonatomic, strong) NSMutableArray    *Goods;

+(id)orderModelWithDict:(NSDictionary *)dict;
@end

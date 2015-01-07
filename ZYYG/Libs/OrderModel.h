//
//  OrderModel.h
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//订单
@interface OrderModel : NSObject

@property (nonatomic, strong) NSString          *OrderCode;//订单编号
@property (nonatomic, strong) NSString          *OrderType;//订单类型
@property (nonatomic, strong) NSString          *CreateTime;//生成时间
@property (nonatomic, assign) NSString          *GoodsTotal;//商品数量
@property (nonatomic, strong) NSString          *OrderMoney;//订单金额
@property (nonatomic, strong) NSString          *OrderStatus;//订单状态
@property (nonatomic, assign) NSInteger          state;//状态编号
@property (nonatomic, strong) NSMutableArray    *Goods;//订单商品(多个)
@property (nonatomic, strong) NSString          *MerchantID;//商户id
@property (nonatomic, strong) NSString          *PayKey;//商户key
+(id)orderModelWithDict:(NSDictionary *)dict;
@end

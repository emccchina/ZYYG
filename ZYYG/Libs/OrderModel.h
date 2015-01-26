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
@property (nonatomic, strong) NSString          *CancelTime;//失效时间
@property (nonatomic, strong) NSString          *CreateTime;//生成时间
@property (nonatomic, assign) NSString          *GoodsTotal;//商品数量
@property (nonatomic, strong) NSString          *OrderStatus;//订单状态
@property (nonatomic, strong) NSString          *OrderType;//订单类型
@property (nonatomic, strong) NSString          *OrderMoney;//订单金额
@property (nonatomic, assign) NSInteger          state;//状态编号
@property (nonatomic, strong) NSMutableArray    *Goods;//订单商品(多个)
@property (nonatomic, strong) NSString          *MerchantID;//商户id
@property (nonatomic, strong) NSString          *PayKey;//商户key
@property (nonatomic, strong) NSString          *PaidMoney;//已付款(已扣除保证金)
@property (nonatomic, strong) NSString          *PayMoney;//应付款（尾款）
@property (nonatomic, strong) NSString          *PayTime;//付尾款时间
@property (nonatomic, strong) NSString          *RemainingTime;//剩余时间
@property (nonatomic, strong) NSString          *TimeSpan;//时长（多少小时/分钟内付款)

+(id)orderModelWithDict:(NSDictionary *)dict;
@end

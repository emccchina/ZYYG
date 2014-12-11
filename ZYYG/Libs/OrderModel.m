//
//  OrderModel.m
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderModel.h"
#import "GoodsModel.h"

@implementation OrderModel

+(id)orderModelWithDict:(NSDictionary *)dict
{
    OrderModel *order =[[OrderModel alloc] init];
    order.Goods=[NSMutableArray array];
    order.OrderCode=[dict safeObjectForKey:@"OrderCode"];
    order.OrderType=[dict safeObjectForKey:@"OrderType"];
    order.CreateTime=[dict safeObjectForKey:@"CreateTime"];
    order.GoodsTotal=[dict safeObjectForKey:@"GoodsTotal"];
    order.OrderMoney=[dict safeObjectForKey:@"OrderMoney"];
    order.OrderStatus=[dict safeObjectForKey:@"OrderStatus"];
    NSMutableArray *goods=[NSMutableArray arrayWithArray:dict[@"Goods"]];
    for (int i=0; i<goods.count; i++) {
        NSDictionary *gd=goods[i];
        GoodsModel *g=[[GoodsModel alloc] init];
        g.GoodsCode=[gd safeObjectForKey:@"Code"];
        g.GoodsName=[gd safeObjectForKey:@"Title"];
        g.defaultImageUrl=[gd safeObjectForKey:@"ImgUrl"];
        g.AppendPrice=[[gd safeObjectForKey:@"Price"] floatValue];
        [order.Goods addObject:g];
    }
    
    return order;
    
}
@end

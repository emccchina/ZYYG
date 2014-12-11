//
//  GoodsModel.m
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "GoodsModel.h"

@implementation GoodsModel

+(id)goodsModelWith:(NSDictionary *)dict
{
    GoodsModel *goods =[[GoodsModel alloc] init];
    goods.GoodsCode =[dict safeObjectForKey:@"GoodsCode"];//商品编码
    goods.GoodsName=[dict safeObjectForKey:@"GoodsName"] ;//商品名
    goods.GoodsIntro=[dict safeObjectForKey:@"GoodsIntro"];//商品简介
    goods.AppendPrice=[dict[@"AppendPrice"] floatValue];//价格
    goods.ArtName=[dict safeObjectForKey:@"ArtName"] ;//艺术家名称
    goods.AuthorIntro=[dict safeObjectForKey:@"AuthorIntro"] ;//作者简介
    goods.CategoryName=[dict safeObjectForKey:@"CategoryName"] ;//分类名称
    goods.CreationStyle=[dict safeObjectForKey:@"CreationStyle"] ;//创作风格
    goods.GoodsNum=dict[@"GoodsNum"];//商品数量
    goods.ImageUrl=dict[@"ImageUrl"] ;//图片路径
    goods.Intro=[dict safeObjectForKey:@"Intro"] ;//商品简介
    goods.IsCollect=dict[@"IsCollect"];//是否收藏 1标示收藏 0表示没收藏
    goods.LimitedSale=[dict safeObjectForKey:@"LimitedSale"] ;//限量
    goods.SpecDesc=[dict safeObjectForKey:@"SpecDesc"] ;//尺寸
    return goods;
}

- (void)goodsModelFromCart:(NSDictionary *)dict
{
    self.ArtName = dict[@"Title"];
    self.GoodsCode = dict[@"product_id"];
    self.SpecDesc = dict[@"size"];
    self.AppendPrice = [dict[@"Money"] floatValue];
    self.picURL = dict[@"ImageUrl"];
}

- (void)goodsModelFromHomePage:(NSDictionary *)dict
{
    self.ArtName = dict[@"Special_Id"];
    self.GoodsCode = dict[@"Product_Id"];
    self.GoodsName = dict[@"Product_Name"];
    self.SpecDesc = dict[@"size"];
    self.AppendPrice = [dict[@"Product_Price"] floatValue];
    self.picURL = dict[@"Pic_Url"];
}

@end

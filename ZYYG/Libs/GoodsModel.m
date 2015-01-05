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
    goods.centificateIntro = dict[@"Certificate"];
    goods.Intro=[dict safeObjectForKey:@"Intro"] ;//商品简介
    goods.IsCollect=dict[@"IsCollect"];//是否收藏 1标示收藏 0表示没收藏
    goods.LimitedSale=[dict safeObjectForKey:@"LimitedSale"] ;//限量
    goods.SpecDesc=[dict safeObjectForKey:@"SpecDesc"] ;//尺寸
    goods.typeForGoods = [dict[@"SaleChannel"] integerValue]/10;
    return goods;
}

- (void)goodsModelFromCollect:(NSDictionary *)dict
{
    self.picURL = [dict safeObjectForKey:@"ImageUrl"];
    self.GoodsCode = [dict safeObjectForKey:@"GoodsCode"];
    self.CollectCode = [dict safeObjectForKey:@"CollectCode"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
    self.ArtName = [dict safeObjectForKey:@"ArtName"];
    self.SaleChannel = [dict safeObjectForKey:@"SaleChannel"];
    self.CreateTime = [dict safeObjectForKey:@"CreateTime"];
    self.UpShelfTime = [dict safeObjectForKey:@"UpShelfTime"];
    self.Nstatus = [dict safeObjectForKey:@"Nstatus"];
    
}

- (void)goodsModelFromCart:(NSDictionary *)dict
{
    self.ArtName = [dict safeObjectForKey:@"Title"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
    self.GoodsCode = [dict safeObjectForKey:@"product_id"];
    self.SpecDesc = [dict safeObjectForKey:@"size"];
    self.AppendPrice = [[dict safeObjectForKey:@"Money"] floatValue];
    self.picURL = [dict safeObjectForKey:@"ImageUrl"];
    self.addCartCount = [dict safeObjectForKey:@"Num"];
    self.valid = ([[dict safeObjectForKey:@"isValid"] isEqualToString:@"False"] ? NO : YES);
}

- (void)goodsModelFromHomePage:(NSDictionary *)dict
{
    self.ArtName = [dict safeObjectForKey:@"Special_Id"];
    self.GoodsCode = [dict safeObjectForKey:@"Product_Id"];
    self.GoodsName = [dict safeObjectForKey:@"Product_Name"];
    self.SpecDesc = [dict safeObjectForKey:@"size"];
    self.AppendPrice = [[dict safeObjectForKey:@"Product_Price"] floatValue];
    self.picURL = [dict safeObjectForKey:@"Pic_Url"];
}

- (void)goodsModelFromSearch:(NSDictionary *)dict
{
    self.ArtName = [dict safeObjectForKey:@"ArtName"];
    self.GoodsCode = [dict safeObjectForKey:@"GoodsCode"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
//    self.SpecDesc = dict[@"size"];
    self.AppendPrice = [[dict safeObjectForKey:@"Price"] floatValue];
    self.picURL = [dict safeObjectForKey:@"ImgUrl"];
}
- (void)goodsModelFromOrder:(NSDictionary *)dict
{
    self.GoodsCode = [dict safeObjectForKey:@"Code"];
    self.GoodsName = [dict safeObjectForKey:@"Title"];
    self.AppendPrice = [[dict safeObjectForKey:@"Price"] floatValue];
    self.picURL = [dict safeObjectForKey:@"Title"];
}

@end

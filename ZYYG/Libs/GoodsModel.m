//
//  GoodsModel.m
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "GoodsModel.h"

@implementation GoodsModel

-(void)goodsModelWith:(NSDictionary *)dict
{
    self.GoodsCode =[dict safeObjectForKey:@"GoodsCode"];//商品编码
    self.GoodsName=[dict safeObjectForKey:@"GoodsName"] ;//商品名
    self.GoodsIntro=[dict safeObjectForKey:@"GoodsIntro"];//商品简介
    self.AppendPrice=[dict[@"AppendPrice"] floatValue];//价格
    self.ArtName=[dict safeObjectForKey:@"ArtName"] ;//艺术家名称
    self.AuthorIntro=[dict safeObjectForKey:@"AuthorIntro"] ;//作者简介
    self.CategoryName=[dict safeObjectForKey:@"CategoryName"] ;//分类名称
    self.CreationStyle=[dict safeObjectForKey:@"CreationStyle"] ;//创作风格
    self.GoodsNum=dict[@"GoodsNum"];//商品数量
    self.ImageUrl=dict[@"ImageUrl"] ;//图片路径
    self.centificateIntro = dict[@"Certificate"];
    self.Intro=[dict safeObjectForKey:@"Intro"] ;//商品简介
    self.IsCollect=dict[@"IsCollect"];//是否收藏 1标示收藏 0表示没收藏
    self.LimitedSale=[dict safeObjectForKey:@"LimitedSale"] ;//限量
    self.SpecDesc=[dict safeObjectForKey:@"SpecDesc"] ;//尺寸
    self.typeForGoods = [dict[@"SaleChannel"] integerValue]/10;
    
    self.startPrice = [dict safeObjectForKey:@"StartMoney"];
    self.appendMoney = [dict safeObjectForKey:@"AppendMoney"];
    self.endTime = [dict safeObjectForKey:@"EndDate"];
    self.startTime = [dict safeObjectForKey:@"StartDate"];;
    self.securityDeposit = [dict safeObjectForKey:@"SecurityDeposit"];
    self.isSecurityDeposit = [[dict safeObjectForKey:@"IsSecurtyDeposit"] integerValue];
    self.delayMinute = [[dict safeObjectForKey:@"DelayMinute"] integerValue];
    self.isBidEntrustPrice = [dict[@"IsEntrustPrice"] integerValue];
    self.BidEntrustPrice = [dict safeObjectForKey:@"EntrustPrice"];
    self.telephone = [dict safeObjectForKey:@"Tel"];
}

- (void)goodsForBidHistroy:(NSDictionary *)dict
{
    
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
    self.auctionCode = [dict safeObjectForKey:@"AuctionCode"];
    self.auctionName = [dict safeObjectForKey:@"AuctionName"];
    
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

- (void)goodsModelFromAuctionDetail:(NSDictionary *)dict
{
    self.GoodsCode = [dict safeObjectForKey:@"GoodsCode"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
    self.AppendPrice = [[dict safeObjectForKey:@"Price"] floatValue];
    self.picURL = [dict safeObjectForKey:@"ImgUrl"];
    self.auctionCode = [dict safeObjectForKey:@"ActionCode"];
    self.auctionName = [dict safeObjectForKey:@"ActionName"];
    self.ArtName = [dict safeObjectForKey:@"ArtName"];
    self.biddingNum = [dict safeObjectForKey:@"BiddingNum"];
    self.endTime = [dict safeObjectForKey:@"EndDate"];
    self.startTime = [dict safeObjectForKey:@"StartDate"];
    self.status = [dict safeObjectForKey:@"Status"];
    self.RemainingTime = [dict safeObjectForKey:@"RemainingTime"];
}
- (void)goodsModelFromMarginList:(NSDictionary*)dict
{
    self.GoodsCode = [dict safeObjectForKey:@"GoodsCode"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
    self.auctionName = [dict safeObjectForKey:@"AuctionName"];
    self.picURL = [dict safeObjectForKey:@"ImageUrl"];
    self.securityDeposit=[dict safeObjectForKey:@"SecurtyDeposit"];
    self.status = [dict safeObjectForKey:@"Status"];
    self.startTime = [dict safeObjectForKey:@"ReceiveTime"];
    self.endTime = [dict safeObjectForKey:@"RefundTime"];
    self.CreateTime = [dict safeObjectForKey:@"DealTime"];
    self.auctionCode = [dict safeObjectForKey:@"AuctionCode"];
}
- (void)goodsModelFromRecordList:(NSDictionary*)dict
{
    self.GoodsCode = [dict safeObjectForKey:@"GoodsCode"];
    self.GoodsName = [dict safeObjectForKey:@"GoodsName"];
    self.ArtName = [dict safeObjectForKey:@"ArtName"];
    self.auctionCode =[dict safeObjectForKey:@"AuctionCode"];
    self.auctionName = [dict safeObjectForKey:@"AuctionName"];
    self.picURL = [dict safeObjectForKey:@"ImageUrl"];
    self.securityDeposit=[dict safeObjectForKey:@"SecurtyDeposit"];
    self.startPrice =[dict safeObjectForKey:@"CurrentPrice"];
    self.maxMoney =[dict safeObjectForKey:@"MyMaxPrice"];
    self.startTime = [dict safeObjectForKey:@"BeginTime"];
    self.endTime = [dict safeObjectForKey:@"ReminingTime"];
    self.status = [dict safeObjectForKey:@"Status"];
    self.BidEntrustPrice = [dict safeObjectForKey:@"ENTRUSTMONEY"];
}

@end

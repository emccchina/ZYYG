//
//  GoodsModel.h
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//商品模型
@interface GoodsModel : NSObject

@property (nonatomic, strong) NSString      *GoodsCode;//商品编码
@property (nonatomic, strong) NSString      *GoodsName;//商品名
@property (nonatomic, strong) NSString      *GoodsIntro;//商品简介
@property (nonatomic, assign) CGFloat       AppendPrice;//价格
@property (nonatomic, strong) NSString      *ArtName;//艺术家名称
@property (nonatomic, strong) NSString      *AuthorIntro;//作者简介
@property (nonatomic, strong) NSString      *CategoryName;//分类名称
@property (nonatomic, strong) NSString      *CreationStyle;//创作风格
@property (nonatomic, assign) NSNumber      *GoodsNum;//商品数量
@property (nonatomic, strong) NSString      *defaultImageUrl;//默认的图片
@property (nonatomic, strong) NSMutableArray       *ImageUrl;//图片路径
@property (nonatomic, strong) NSString      *Intro;//商品简介
@property (nonatomic, strong) NSNumber      *IsCollect;//是否收藏 1标示收藏 0表示没收藏
@property (nonatomic, strong) NSString      *LimitedSale;//限量
@property (nonatomic, strong) NSString      *SpecDesc;//尺寸
@property (nonatomic, strong) NSString      *picURL;//默认图片
@property (nonatomic, strong) NSString      *CollectCode;//收藏编号
@property (nonatomic, strong) NSString      *SaleChannel;//商品种类
@property (nonatomic, strong) NSString      *CreateTime;//创建时间
@property (nonatomic, strong) NSString      *UpShelfTime;//创建时间
@property (nonatomic, strong) NSString      *Nstatus;//在售状态
@property (nonatomic, strong) NSString      *centificateIntro;//证书简介
@property (nonatomic, strong) NSString      *telephone;//电话


@property (nonatomic, assign) NSInteger     biddingStatus;//竞拍状态: 10已成交 20流拍  0有效
@property (nonatomic, strong) NSString      *startPrice;
@property (nonatomic, strong) NSString      *auctionCode;//拍卖场次code
@property (nonatomic, strong) NSString      *auctionName;//拍卖场次name
@property (nonatomic, strong) NSString      *endTime; //结束时间
@property (nonatomic, strong) NSString      *startTime; // 开始时间
@property (nonatomic, strong) NSString      *status; //拍卖状态 10已成交20流拍  0有效
@property (nonatomic, strong) NSString      *biddingNum;//竞拍次数
@property (nonatomic, strong) NSString      *appendMoney;//加价
@property (nonatomic, assign) NSInteger     delayMinute;
@property (nonatomic, assign) NSInteger     isBidEntrustPrice;//是否最高价格
@property (nonatomic, strong) NSString      *BidEntrustPrice;//最高价格
@property (nonatomic, strong) NSString      *securityDeposit;//保证金
@property (nonatomic, assign) NSInteger     isSecurityDeposit;//是否交保证金 -1:没有；0：待付款；10：已付款；
@property (nonatomic, strong) NSString      *maxMoney;//当前价格
@property (nonatomic, strong) NSString      *bidHistory;//出价历史
@property (nonatomic, strong) NSString      *addCartCount;
@property (nonatomic, assign) BOOL          valid;//失效与否
@property (nonatomic, assign) NSInteger     typeForGoods;//(0 平价交易 1 线上竞价 2 私人定制 3 私人洽购 4 线下拍卖)
- (void)goodsModelWith:(NSDictionary *)dict;//详情页面
- (void)goodsForBidHistroy:(NSDictionary*)dict;
- (void)goodsModelFromCart:(NSDictionary*)dict;//购物车解析
- (void)goodsModelFromHomePage:(NSDictionary*)dict;//首页解析
- (void)goodsModelFromCollect:(NSDictionary *)dict;//我的收藏解析
- (void)goodsModelFromSearch:(NSDictionary *)dict;//搜索结果解析
- (void)goodsModelFromOrder:(NSDictionary *)dict;//搜索结果解析
- (void)goodsModelFromAuctionDetail:(NSDictionary*)dict;//从竞价搜索中解析
- (void)goodsModelFromMarginList:(NSDictionary*)dict;//从保证金中解析
- (void)goodsModelFromRecordList:(NSDictionary*)dict;//从保证金中解析
@end

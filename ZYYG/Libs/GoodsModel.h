//
//  GoodsModel.h
//  ZYYG
//
//  Created by champagne on 14-12-9.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property (nonatomic, assign) NSNumber      *IsCollect;//是否收藏 1标示收藏 0表示没收藏
@property (nonatomic, strong) NSString      *LimitedSale;//限量
@property (nonatomic, strong) NSString      *SpecDesc;//尺寸
+(id)goodsModelWith:(NSDictionary *)dict;
@end

//
//  SelectInfo.h
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAttributeCode          @"attribute"
#define kAuthorCode             @"author"
#define kStyleCode              @"creationStyle"
#define kMakeStyleCode          @"firingMode"
#define kHeightCode             @"height"
#define kCountoyCode            @"nationality"
#define kPrice1Code             @"price1"
#define kPrice2Code             @"price2"
#define kSpec1Code              @"spec1"
#define kSpec2Cpde              @"spec2"
#define kSpeciesCode            @"species"
#define kVersionsCode           @"versionNumber"

//筛选内容
@interface SelectInfo : NSObject

@property (nonatomic, strong) NSString *categaryCode;//
@property (nonatomic, strong) NSString *price;//价格，此价格为筛选价格
@property (nonatomic, strong) NSString *classifyPrice;//分类中的价格 ，再次筛选的时候 有此选择条件
@property (nonatomic, strong) NSString *size;//
@property (nonatomic, strong) NSString *squareFoot;//平尺
@property (nonatomic, strong) NSString *sytle;//风格
@property (nonatomic, strong) NSString *artorName;//作者
@property (nonatomic, strong) NSString *country;//国籍
@property (nonatomic, strong) NSString *height;//高度
@property (nonatomic, strong) NSString *versionNumber;
@property (nonatomic, strong) NSString *species;
@property (nonatomic, assign) NSInteger  shotPrice;//底价
@property (nonatomic, assign) NSInteger shotDate;//日期
@property (nonatomic, assign) NSInteger shotQuantity;//库存参数:0,全部; 1,待售; 2,已售
@property (nonatomic, assign) NSInteger num;//分页条数
@property (nonatomic, assign) NSInteger page;//分页页数
@property (nonatomic, strong) NSString  *attrible;//简介
@property (nonatomic, strong) NSString *makeStyle;//创作风格
@property (nonatomic, strong) NSString *searchKey;//关键字
@property (nonatomic, assign) BOOL      sell;//0待售 1已售
@property (nonatomic, assign) NSInteger searchType;//接口不同  0分类搜索  1关键字搜索
- (void)recoverInfo;//筛选 复原

- (NSDictionary*)createURLDict;

- (void)setInfoWithType:(NSString*)type content:(NSDictionary*)content;

- (void)setSorteType:(NSInteger)type;//0价格  1时间   2待售 3已售

@end

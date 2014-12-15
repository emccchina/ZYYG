//
//  SearchFrameVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

typedef  enum{
    kSquareM = 1,//平米
    kSquareS,//平尺
    kStyle,//创作风格
    kMakeStyle,//烧成方式
    kType,//种类
    kVersion,//版数
    kCountry,//国籍
    kArthor,//艺术家
    kFiveMillions,//500万以上
    kThree,//30万以上
}kSearchType;

//平价交易首页的搜索
@interface SearchFrameVC : BaseViewController

@property (nonatomic, assign) kSearchType  searchType;

@end

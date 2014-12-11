//
//  SearchVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^ChooseFactorFinised) (NSInteger type, id content);

//分类后面显示商品的搜索
@interface SearchVC : BaseViewController

@property (nonatomic, assign) NSInteger         searchType;//0艺术家   1尺寸  2国籍  3价格
@property (nonatomic, copy)   ChooseFactorFinised       chooseFinished;
@end

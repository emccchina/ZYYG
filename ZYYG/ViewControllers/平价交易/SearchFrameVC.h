//
//  SearchFrameVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^SelectedKeysFinished)(NSString *key);

//平价交易首页的搜索
@interface SearchFrameVC : BaseViewController

@property (nonatomic, copy) SelectedKeysFinished finished;
@property (nonatomic, assign) NSInteger  searchType;//从哪里来的 1从首页 0从分类
@end

//
//  ArtDetailVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

//艺术品详情
@interface ArtDetailVC : BaseViewController

@property (nonatomic, assign) BOOL          hiddenBottom;//隐藏底部的购物车view
@property (nonatomic, strong) NSString      *productID;//
@property (nonatomic, assign) BOOL          type;//0一般的详情   1私人洽购里的详情
@end

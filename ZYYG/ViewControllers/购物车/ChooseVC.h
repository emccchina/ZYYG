//
//  ChooseVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^ChooseTypeFinshed) (NSInteger type ,id content);
//保证金支付选择， 支付选择， 配送选择， 发票选择
@interface ChooseVC : BaseViewController

@property (nonatomic, assign) NSInteger   typeChoose;//0 保证金，1 支付， 2 配送， 3 发票
@property (nonatomic, copy) ChooseTypeFinshed  chooseFinished;
@end

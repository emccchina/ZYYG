//
//  TalkBuy.h
//  ZYYG
//
//  Created by EMCC on 14/12/5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "ChooseView.h"
//私人洽购
@interface TalkBuyVC : BaseViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *talkBuyTableView;
@property (weak, nonatomic) IBOutlet ChooseView *chooseView;

@end

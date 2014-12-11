//
//  FairPriceVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "BaseViewController.h"
#import "CycleScrollView.h"
//平价交易
@interface FairPriceVC : BaseViewController
<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTB;

//@property (weak, nonatomic) IBOutlet CycleScrollView *scrollVIew;


@end

//
//  MarginMoneyVC.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "HMSegmentedControl.h"
@interface MyAccountVC : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *maybeMoney;
@property (weak, nonatomic) IBOutlet UILabel *frozen;
@property (weak, nonatomic) IBOutlet HMSegmentedControl *segView;
@property (weak, nonatomic) IBOutlet UITableView *marginMoneyTableView;
@end

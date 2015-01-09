//
//  CompeteRecordVC.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "HMSegmentedControl.h"

@interface CompeteRecordVC : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet HMSegmentedControl *segmentView;
@property (weak, nonatomic) IBOutlet UITableView *competeTableView;
@end

//
//  RecommendedVC.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface MarginMoneyVC : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *recommendedTableView;
@end

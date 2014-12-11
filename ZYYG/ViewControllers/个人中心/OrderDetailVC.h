//
//  OrderDetailVC.h
//  ZYYG
//
//  Created by champagne on 14-12-4.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface OrderDetailVC : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;
@property (weak, nonatomic) IBOutlet UIButton *checkDelivery;
@property (weak, nonatomic) IBOutlet UIButton *confirmDelivery;
@end

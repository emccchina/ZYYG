//
//  OrderDetailVC.h
//  ZYYG
//
//  Created by champagne on 14-12-4.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
//订单详情
@interface OrderDetailVC : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *orderMoney;
@property (weak, nonatomic) IBOutlet UIButton *checkDelivery;
@property (weak, nonatomic) IBOutlet UIButton *confirmDelivery;
@property (retain, nonatomic)  NSString *orderCode;
@property (assign, nonatomic)  NSInteger orderType;

@end

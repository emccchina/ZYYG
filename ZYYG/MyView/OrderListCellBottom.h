//
//  OrderListCellBottom.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListVC.h"
#import "OrderModel.h"
//订单列表 4 底部cell
@interface OrderListCellBottom : UITableViewCell<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cancelTime;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancellButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (nonatomic,strong) OrderModel *order;
@property (nonatomic,strong) OrderListVC* orderlistVc;
//取消支付
- (IBAction)cancelOrder:(UIButton *)sender;
//支付订单
- (IBAction)payOrder:(UIButton *)sender;


@end

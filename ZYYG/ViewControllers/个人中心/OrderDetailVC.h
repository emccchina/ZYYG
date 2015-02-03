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
{
    
}
@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *orderMoney;
@property (weak, nonatomic) IBOutlet UIButton *checkDelivery;
@property (weak, nonatomic) IBOutlet UIButton *confirmDelivery;
@property (retain, nonatomic)  NSString *orderCode;
@property (retain, nonatomic)  NSString *auctionCode;
@property (assign, nonatomic)  NSInteger orderType;//0平价详情    2竞价详情

- (IBAction)payOrder:(id)sender;
- (IBAction)cancelOrder:(id)sender;
@end

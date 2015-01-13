//
//  OrderListVC.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "OrderModel.h"
#import "PaaCreater.h"
//订单列表
@interface OrderListVC : BaseViewController
<UITableViewDataSource,UITableViewDelegate,APayDelegate>

@property (retain, nonatomic)  NSString *orderType;

@property (weak, nonatomic) IBOutlet UITableView *orderListTabelView;
- (void)requestFinished;
-(void)requestOrderList:(NSString *)ortype ordState:(NSString *)orstate ordSize:(NSInteger )size  ordNum:(NSInteger )num;
-(void)cancellOrder:(OrderModel *)order_id;
-(void)payOrder:(OrderModel *)order;
@end

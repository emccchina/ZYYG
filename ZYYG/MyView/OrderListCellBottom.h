//
//  OrderListCellBottom.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderListVC.h"
@interface OrderListCellBottom : UITableViewCell<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cancelTime;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancellButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (nonatomic,strong) NSString *orderCode;
@property (nonatomic,strong) OrderListVC* orderlistVc;

- (IBAction)cancelOrder:(UIButton *)sender;
- (IBAction)payOrder:(UIButton *)sender;


@end

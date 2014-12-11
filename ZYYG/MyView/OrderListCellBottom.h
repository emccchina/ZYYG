//
//  OrderListCellBottom.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCellBottom : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cancelTime;
@property (weak, nonatomic) IBOutlet UIButton *cancellButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

- (IBAction)cancelOrder:(UIButton *)sender;
- (IBAction)payOrder:(UIButton *)sender;


@end

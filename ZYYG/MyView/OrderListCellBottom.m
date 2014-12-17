//
//  OrderListCellBottom.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderListCellBottom.h"

@implementation OrderListCellBottom

- (void)awakeFromNib {
    // Initialization code
    self.payButton.layer.cornerRadius=4;
    self.cancellButton.layer.cornerRadius=4;
    self.payButton.layer.backgroundColor=kRedColor.CGColor;
    self.cancellButton.layer.backgroundColor=kRedColor.CGColor;
  
    
    createBottomLine
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cancelOrder:(UIButton *)sender {
    NSLog(@"取消订单");
}

- (IBAction)payOrder:(UIButton *)sender {
    NSLog(@"支付订单");
}
@end

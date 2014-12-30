//
//  OrderListCellBottom.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderListCellBottom.h"
#import "UserInfo.h"

@implementation OrderListCellBottom 
{
    UserInfo *user;
    
}

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
    NSLog(@"取消订单  %@",self.order);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定取消订单吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"不取消",nil];
    [alertView show];
   
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self.orderlistVc cancellOrder:self.order];
            break;
        case 1://NO应该做的事
            break;
    }
}
- (IBAction)payOrder:(UIButton *)sender {
    NSLog(@"支付订单");
     [self.orderlistVc payOrder:self.order];
}
@end

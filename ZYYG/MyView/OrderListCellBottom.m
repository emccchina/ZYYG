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
    NSLog(@"取消订单  %@",self.orderCode);
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self.orderlistVc];
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@DeleteOrder.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",self.orderCode, @"order_id"  ,nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self.orderlistVc parseResults:responseObject];
        if (result) {
            if([@"0" isEqualToString:result[@"errno"]]){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"订单取消成功!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"取消订单出错! %@",result[@"msg"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
            NSLog(@"%@",result);
            [self.orderlistVc.orderArray removeAllObjects];
            [self.orderlistVc requestOrderList:@"0" ordState:@"" ordSize:5 ordNum:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.orderlistVc showAlertView:kNetworkNotConnect];
    }];

}

- (IBAction)payOrder:(UIButton *)sender {
    NSLog(@"支付订单");
}
@end

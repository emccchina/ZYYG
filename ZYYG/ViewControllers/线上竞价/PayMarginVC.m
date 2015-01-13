//
//  PayMarginVC.m
//  ZYYG
//
//  Created by champagne on 15-1-9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "PayMarginVC.h"
#import "PayMarginCell.h"


@implementation PayMarginVC
{
    UserInfo *user;
    NSDictionary            *_resultDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showBackItem];
    [self.PayMarginTabelView registerNib:[UINib nibWithNibName:@"PayMarginCell" bundle:nil] forCellReuseIdentifier:@"PayMarginCell"];
    self.payButton.layer.backgroundColor=kRedColor.CGColor;
    self.payButton.layer.cornerRadius=2;
    [self.payButton setTitle:@"立即支付" forState:UIControlStateNormal];
    self.PayMarginTabelView.delegate = self;
    self.PayMarginTabelView.dataSource = self;
    self.marginMoneyLab.text = self.goods.securityDeposit;
}
#pragma mark --tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 145;
      }else{
          return 46;
      }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        PayMarginCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PayMarginCell" forIndexPath:indexPath];
        [cell.goodsImage setImageWithURL:[NSURL URLWithString:self.goods.picURL]];
   
        cell.goodsName.text=self.goods.GoodsName;
        cell.competeCode.text=[NSString stringWithFormat:@" %.2f",self.goods.AppendPrice];
        cell.artistName.text=self.goods.ArtName;
        cell.createStyle.text=self.goods.CreationStyle;
        cell.size.text=self.goods.SpecDesc;
        cell.MarginMoney.text=self.goods.securityDeposit;
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PayWay"];
        cell.textLabel.text=@"支付方式";
        cell.detailTextLabel.text=@"在线支付";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}
//
- (IBAction)pressPay:(id)sender {
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BidSecurtyDeposit.ashx",kServerDomain];
    NSLog(@"url %@", url);
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",self.auctionCode, @"AuctionCode",self.goods.GoodsCode, @"GoodsCode", @"60" , @"PaymentType",nil];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",@"1501080937178720", @"AuctionCode",@"1412191714231983", @"GoodsCode", @"60" , @"PaymentType",nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            if(![result[@"errno"] integerValue]){
                _resultDict=result;
                NSInteger money = (NSInteger)([_resultDict[@"SecurtyDeposit"] floatValue]*100);
                NSString *moneyString = [NSString stringWithFormat:@"%ld",(long)money];
                [APay startPay:[PaaCreater createrWithOrderNo:_resultDict[@"SecurtyDepositCode"] productName:_resultDict[@"GoodsName"] money:@"1" type:2 shopNum:_resultDict[@"MerchantID"] key:_resultDict[@"PayKey"]] viewController:self delegate:self mode:kPayMode];
            }
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
   
}
- (void)requestFinished
{
    [self dismissIndicatorView];
}
- (void)APayResult:(NSString*)result
{
    NSLog(@"%@",result);
    [self showAlertView:[Utities doWithPayList:result]];
}
@end

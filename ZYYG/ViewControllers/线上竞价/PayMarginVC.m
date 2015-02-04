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
    NSDictionary            *_MerchantID;
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
    [self getMerchantID];
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
        [cell.goodsImage setImageWithURL:[NSURL URLWithString:self.goods.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
   
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
    MutableOrderedDictionary *newDict=[self dictWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            if(![result[@"errno"] integerValue]){
                _resultDict=result;
                NSInteger money = (NSInteger)([_resultDict[@"SecurtyDeposit"] floatValue]*100);
                NSString *moneyString = [NSString stringWithFormat:@"%ld",(long)money];
                [APay startPay:[PaaCreater createrWithOrderNo:_resultDict[@"SecurtyDepositCode"] productName:_resultDict[@"GoodsName"] money:moneyString type:2 shopNum:_MerchantID[@"MerchantID"] key:_MerchantID[@"PayKey"] time:_resultDict[@"ApplyTime"]] viewController:self delegate:self mode:kPayMode];
            }
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
   
}

- (void)getMerchantID {
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@GetUserInfo.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        NSLog(@"aes de %@", aesde);
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            if(![result[@"errno"] integerValue]){
                _MerchantID=result;
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

//加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"PaymentType"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO] forKey:@"AuctionCode" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO] forKey:@"GoodsCode" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"PaymentType"] aes:NO] forKey:@"PaymentType" atIndex:3];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:4];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:5];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}

@end

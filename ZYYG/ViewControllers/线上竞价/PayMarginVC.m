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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showBackItem];
    [self.PayMarginTabelView registerNib:[UINib nibWithNibName:@"PayMarginCell" bundle:nil] forCellReuseIdentifier:@"PayMarginCell"];
    self.payButton.layer.backgroundColor=kRedColor.CGColor;
    self.payButton.layer.cornerRadius=5;
    [self.payButton setTitle:@"立即支付" forState:UIControlStateNormal];
    self.PayMarginTabelView.delegate = self;
    self.PayMarginTabelView.dataSource = self;
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
        [cell.goodsImage setImage:[UIImage imageNamed:@"competeOrder"]];
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PayWay"];
        cell.textLabel.text=@"支付方式";
        cell.detailTextLabel.text=@"在线支付";
        return cell;
    }
}
//
- (IBAction)pressPay:(id)sender {
    [self performSegueWithIdentifier:@"paySuccess" sender:self];
}
@end

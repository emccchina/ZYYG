//
//  MarginMoneyVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MarginMoneyVC.h"
#import "MyAccountCell.h"
#import "AccountModel.h"


@interface MarginMoneyVC ()
{
    NSMutableArray *accountArray;
    UserInfo *user;
}

@end

@implementation MarginMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    accountArray=[NSMutableArray array];
    self.marginMoneyTableView.delegate = self;
    self.marginMoneyTableView.dataSource = self;
    [self.marginMoneyTableView registerNib:[UINib nibWithNibName:@"MyAccountCell" bundle:nil] forCellReuseIdentifier:@"MyAccountCell"];
    [self requestAccountList:@"-1" pageNumber:@"1"];
    [self segViewInit] ;
    // Do any additional setup after loading the view.
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segViewInit
{
    self.segView.sectionTitles=@[@"全部", @"收入", @"支出"];
    self.segView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
     NSLog(@"不晓得成功没");
   
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedContr {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedContr.selectedSegmentIndex);
    if(segmentedContr.selectedSegmentIndex==1){
        [self requestAccountList:@"1" pageNumber:@"1" ];
    }else if(segmentedContr.selectedSegmentIndex==2){
        [self requestAccountList:@"0" pageNumber:@"1" ];
    }else{
        [self requestAccountList:@"-1" pageNumber:@"1" ];
    }
    
}




-(void)requestAccountList:(NSString *)dr  pageNumber:(NSString *)num
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@MyAccount.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",num,@"num",dr,@"dr", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [accountArray removeAllObjects];
            NSArray *accounts=result[@"data"];
            NSString *MaybeMoney=result[@"MaybeMoney"];
            self.maybeMoney.text=[NSString stringWithFormat:@"$%@",MaybeMoney];
            NSString *Frozen=result[@"Frozen"];
            self.frozen.text=[NSString stringWithFormat:@"$%@",Frozen];
            for (int i=0; i<accounts.count; i++) {
                AccountModel *account =[AccountModel accountWithDict:accounts[i]];
                [accountArray addObject:account];
                NSLog(@"账户信息读取成功");
            }
            [self.marginMoneyTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
}

#pragma mark -tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return accountArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountModel *account=accountArray[indexPath.row];
    MyAccountCell *cell = (MyAccountCell*)[tableView dequeueReusableCellWithIdentifier:@"MyAccountCell" forIndexPath:indexPath];
    cell.BillCode.text=account.BillCode; //账单号
    cell.Direction.text=account.Direction; //收入支出
    cell.BillType.text=account.BillType; //业务类型
    cell.MoneyType.text=account.MoneyType;  //操作类型
    cell.OperMoney.text=account.OperMoney;    //金额
    cell.ReceiveNickName.text=account.ReceiveNickName;//接收方
    cell.AuditTime.text=account.AuditTime;    //生成时间
    cell.Remark.text=account.Remark;   //备注
    return cell;
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

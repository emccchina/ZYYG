//
//  RecommendedVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MarginMoneyVC.h"
#import "MarginMoneyCell.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"


@interface MarginMoneyVC ()
{
    NSMutableArray *marginArray;
    UserInfo *user;
    NSInteger pageSize;
    NSInteger pageNum;
    BOOL                refreshFooter;//是否是上拉刷新
}

@end

@implementation MarginMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    marginArray= [[NSMutableArray alloc] init];
    pageSize=5;
    pageNum=1;
    [self requestMarginList:pageSize pageNum:pageNum];
    [self.marginTableView registerNib:[UINib nibWithNibName:@"MarginMoneyCell" bundle:nil] forCellReuseIdentifier:@"MarginMoneyCell"];
    self.marginTableView.delegate = self;
    self.marginTableView.dataSource = self;
    [self addFootRefresh];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)addFootRefresh
{
    [self.marginTableView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageNum = 1;
        refreshFooter = NO;
        [self requestMarginList:pageSize pageNum:pageNum];
    }];
    [self.marginTableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageNum=pageNum+1;
        refreshFooter = YES;
        [self requestMarginList:pageSize pageNum:pageNum];
    }];
}
-(void)requestMarginList:(NSInteger )size  pageNum:(NSInteger )num
{
    pageSize=size;
    pageNum=num;
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@MyDeposit.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",[NSString stringWithFormat:@"%ld",(long)size] , @"num", [NSString stringWithFormat:@"%ld",(long)num] , @"page" ,nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            //            NSLog(@"%@",result);
            NSMutableArray *marginList=result[@"DepositList"];
            if (!marginList ||[marginList isKindOfClass:[NSNull class]]|| marginList.count<1) {
                [self showAlertView:@"无新数据!"];
            }else{
                if (!refreshFooter) {
                    [marginArray removeAllObjects];
                }
                for (int i=0; i<marginList.count; i++) {
                    GoodsModel *mar=[[GoodsModel alloc] init];
                    [mar goodsModelFromMarginList:marginList[i]];
                    [marginArray addObject:mar];
                }
            }
            [self requestFinished];
            [self.marginTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    refreshFooter = NO;
    [self dismissIndicatorView];
    [self.marginTableView footerEndRefreshing];
    [self.marginTableView    headerEndRefreshingWithResult:JHRefreshResultSuccess];
}

#pragma mark -tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return marginArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *goods=marginArray[indexPath.row];
    MarginMoneyCell *cell = (MarginMoneyCell*)[tableView dequeueReusableCellWithIdentifier:@"MarginMoneyCell" forIndexPath:indexPath];
    [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
     
    cell.goodsName.text=goods.GoodsName;
    cell.marginMoney.text=goods.securityDeposit;
    cell.marginState.text=goods.status;
    cell.freezeTime.text=goods.startTime;
    cell.thawTime.text=goods.endTime;
    cell.spendTime.text=goods.CreateTime;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsModel *goods=marginArray[indexPath.row];
    [self presentDetailVC:goods];
}

- (void)presentDetailVC:(GoodsModel*)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
        [detailVC setValue:@(2) forKey:@"type"];
        [detailVC setValue:@(0) forKey:@"hiddenBottom"];
        [detailVC setValue:info.auctionCode forKey:@"auctionCode"];
        [detailVC setValue:info.GoodsCode forKey:@"productID"];
        detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
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

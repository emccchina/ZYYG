//
//  CompeteRecordVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CompeteRecordVC.h"
#import "CompeteRecordCell.h"
#import "CompeteRecordCellTop.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"
@interface CompeteRecordVC ()
{
    NSMutableArray *recordArray;
    NSInteger pageNum;
    NSInteger pageSize;
    NSInteger status;
    UserInfo *user;
    BOOL                refreshFooter;//是否是上拉刷新
}

@end

@implementation CompeteRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    recordArray=[[NSMutableArray alloc] init];
    pageNum=1;
    pageSize=5;
    status=0;
    user=[UserInfo shareUserInfo];
    [self.competeTableView registerNib:[UINib nibWithNibName:@"CompeteRecordCell" bundle:nil] forCellReuseIdentifier:@"CompeteRecordCell"];
    [self.competeTableView registerNib:[UINib nibWithNibName:@"CompeteRecordCellTop" bundle:nil] forCellReuseIdentifier:@"CompeteRecordCellTop"];
    
    [self requestRecordList:status page:pageSize panum:pageNum];
    [self addFootRefresh];
    self.segmentView.sectionTitles = @[@"竞价中", @"已结束"];
    self.segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.competeTableView.delegate = self;
    self.competeTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)addFootRefresh
{
    [self.competeTableView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = NO;
        pageNum = 1;
        [self requestRecordList:status page:pageSize panum:pageNum];
    }];
    [self.competeTableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = YES;
        pageNum=pageNum+1;
         [self requestRecordList:status page:pageSize panum:pageNum];
    }];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [recordArray removeAllObjects];
    //  @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"]; @"", @"0",@"20", @"30" ,@"40"
    pageNum=1;
    if (0==segmentedControl.selectedSegmentIndex) {
        status=0;
    }else if(1==segmentedControl.selectedSegmentIndex) {
        status=10;
    }else{
        status=0;
    }
    [recordArray removeAllObjects];
    [self requestRecordList:status page:pageSize panum:1];
    
}
-(void)requestRecordList:(NSInteger)Austatus  page:(NSInteger )size  panum:(NSInteger )num
{
    status=Austatus;
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
    NSString *url = [NSString stringWithFormat:@"%@MyBiddingList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",[NSString stringWithFormat:@"%ld",(long)status], @"AuctionStatus",[NSString stringWithFormat:@"%ld",(long)size] , @"num", [NSString stringWithFormat:@"%ld",(long)num] , @"page" ,nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            //            NSLog(@"%@",result);
            NSMutableArray *records=result[@"BiddingList"];
            if (!records ||[records isKindOfClass:[NSNull class]]|| records.count<1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"无新数据!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }else{
                if (!refreshFooter) {
                    [recordArray removeAllObjects];
                }
                for (int i=0; i<records.count; i++) {
                    GoodsModel *rgoods=[[GoodsModel alloc]init ];
                    [rgoods  goodsModelFromRecordList:records[i]];
                    [recordArray addObject:rgoods];
                }
            }
            [self.competeTableView reloadData];
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
    [self.competeTableView footerEndRefreshing];
    [self.competeTableView headerEndRefreshingWithResult:JHRefreshResultSuccess];
}


#pragma mark -tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return recordArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 25;
    }
    return 160;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *goods=recordArray[indexPath.section];
    if (indexPath.row == 0) {
        CompeteRecordCellTop *topCell = (CompeteRecordCellTop *)[tableView dequeueReusableCellWithIdentifier:@"CompeteRecordCellTop" forIndexPath:indexPath];
        topCell.orderType.text = goods.status;
        topCell.startPrice.text = [NSString stringWithFormat:@"起拍价:%@" ,goods.startPrice];
        topCell.startPrice.hidden=YES;
        return topCell;
    }else{
        CompeteRecordCell *cell = (CompeteRecordCell *)[tableView dequeueReusableCellWithIdentifier:@"CompeteRecordCell" forIndexPath:indexPath];
        [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
        cell.goodsName.text=goods.GoodsName;
        cell.yourPrice.text=goods.maxMoney;
        cell.highestPrice.text=goods.startPrice;
        cell.beginTime.text=goods.startTime;
        cell.endTime.text=goods.endTime;
        
        if (status==0) {
            cell.redLab.hidden=YES;
            [cell.bidButton setTitle:@"出价" forState:UIControlStateNormal];
            cell.bidButton.hidden=NO;
        }else{
            cell.redLab.hidden=NO;
            cell.redLab.numberOfLines=0;
            cell.redLab.text=@"请在竞价订单中查看结果或者付款!";
            cell.bidButton.hidden=YES;
        }
        return cell;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     GoodsModel *goods=recordArray[indexPath.section];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
    
    if ([detailVC isKindOfClass:[ArtDetailVC class]]) {
        ArtDetailVC *vc = (ArtDetailVC*)detailVC;
        [vc setHiddenBottom:YES];
        [vc setProductID:goods.GoodsCode];
        [vc setAuctionCode:goods.auctionCode];
        [vc setType:2];
    }
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

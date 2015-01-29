//
//  AuctionDetialVC.m
//  ZYYG
//
//  Created by EMCC on 15/1/8.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "AuctionDetialVC.h"
#import "AuctionArtCell.h"
#import "GoodsModel.h"
#import "ChooseView.h"
#import "SearchVC.h"
#import "ArtDetailVC.h"

@interface AuctionDetialVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    SelectInfo          *_selectInfo;//查询条件
    NSMutableArray      *results;//查询结果
    NSString           *selectedProductID;//跳到详情页面
    NSDictionary        *selectType;//选择的跳到SearchVC
    NSArray             *searchCondition;//筛选条件 是否已经存在， 不存在请求
    NSMutableArray      *details;//已经选择的条件,显示在chooseview 上的
    BOOL                refreshFooter;//是否是上拉刷新
    NSMutableArray      *_timerArr;
    ArtDetailVC         *artDetailVC;
}

@property (weak, nonatomic) IBOutlet UITableView *auctionTB;
@property (weak, nonatomic) IBOutlet ChooseView *chooseView;
@end

@implementation AuctionDetialVC

static NSString * auctionCell = @"auctionCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    _selectInfo.searchType = 2;
    _timerArr = [[NSMutableArray alloc] init];
    results = [[NSMutableArray alloc] init];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"筛选" target:self action:@selector(doRightButton:)];
    details = [[NSMutableArray alloc] init];
    
    self.auctionTB.delegate = self;
    self.auctionTB.dataSource = self;
    [self.auctionTB registerNib:[UINib nibWithNibName:@"AuctionArtCell" bundle:nil] forCellReuseIdentifier:auctionCell];
    [self addheadRefresh];
    
    
    [self.chooseView setChooseFinised:^(id selected){
        if ([selected isKindOfClass:[NSDictionary class]]) {
//            [self presentSearchVC:selected];
        }else if ([selected isKindOfClass:[UIEvent class]]){
//            [self doRightButton:nil];
        }
        
    }];
    
    [self.chooseView setChooseFinised:^(id selected){
        if ([selected isKindOfClass:[NSDictionary class]]) {
            [self presentSearchVC:selected];
        }else if ([selected isKindOfClass:[UIEvent class]]){
            [self doRightButton:nil];
        }
        
    }];
    
    [self requestForResult];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (artDetailVC) {
        [artDetailVC releaseTimer];
        [artDetailVC.view removeFromSuperview];
        artDetailVC = nil;
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)releaseTimer
{
    [_timerArr makeObjectsPerformSelector:@selector(invalidate)];
    [_timerArr removeAllObjects];
}

- (void)back
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addheadRefresh
{
    [self.auctionTB addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = NO;
        [self requestForResult];
    }];
    [self.auctionTB addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = YES;
        [self requestForResult];
    }];
}


- (void)doRightButton:(UIBarButtonItem*)item
{
    if (!self.chooseView.hidden) {//隐藏 同时 筛选
        [self presentChooseView:nil];
        [self requestForResult];
        return;
    }
    [_selectInfo recoverInfo];
    if (searchCondition && searchCondition.count) {
        
        [self recoverDetails];
        [self presentChooseView:searchCondition];
        return;
    }
    
    [self requestForSearchItem];
    
}

- (void)presentChooseView:(NSArray*)arr
{
    self.chooseView.hidden = !self.chooseView.hidden;
    NSString *titleItem = self.chooseView.hidden ? @"筛选" : @"确定";
    self.navigationItem.rightBarButtonItem.title = titleItem;
    [self.chooseView reloadTitles:arr details:details];
    if (!self.chooseView.hidden) {
        self.chooseView.alpha = 0;
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.chooseView.alpha = 1;
        } completion:^(BOOL finished){
            
        }];
    }
}
- (void)recoverDetails
{
    [details removeAllObjects];
    for (int i = 0; i < searchCondition.count; i++) {
        [details addObject:@""];
    }
}

- (void)requestFinished
{
//    if (!refreshFooter) {
//        [self.auctionTB setContentOffset:CGPointZero];
//    }
    refreshFooter = NO;
    [self dismissIndicatorView];
    [self.auctionTB footerEndRefreshing];
    [self.auctionTB headerEndRefreshingWithResult:JHRefreshResultSuccess];
}


- (void)presentSearchVC:(id)selected
{
    selectType = selected;
    UIViewController* destVC = [[UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchVC"];
    destVC.hidesBottomBarWhenPushed = YES;
    if ([destVC isKindOfClass:[SearchVC class]]) {
        SearchVC *search = (SearchVC*)destVC;
        [search setTitles:selectType];
        //        [search setValue:@(_selectedIndex) forKey:@"searchType"];
        [search setChooseFinished:^(NSString *type, id content){
            NSLog(@"id content %@, %@",type, content);
            NSInteger index = [searchCondition indexOfObject:selectType];
            [details replaceObjectAtIndex:index withObject:content];
            [_selectInfo setInfoWithType:type content:content];
            [self.chooseView reloadTitles:searchCondition details:details];
        }];
        [self.navigationController pushViewController:search animated:YES];
    }
}


- (void)parseRequestResults:(NSArray*)arr
{
    if (!refreshFooter) {
        [results removeAllObjects];
    }
    if (!arr.count) {
        [self showAlertView:!refreshFooter ? @"没有相关艺术品，请改变条件" : @"没有更多了"];
        return;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        GoodsModel *model = [[GoodsModel alloc] init];
        [model goodsModelFromAuctionDetail:dict];
        [array addObject:model];
    }
    
    [results addObjectsFromArray:array];
}

- (void)requestForResult
{
    _selectInfo.page = (!refreshFooter ? 1 : (results.count-1)/20 + 2);
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BidTypeGoodsList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [_selectInfo createURLDict];
#ifdef DEBUG
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [self parseRequestResults:result[@"Goods"]];
            [self.auctionTB reloadData];
        }
        [self requestFinished];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (NSMutableDictionary*)createChooseArrForDealStaus
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"交易状态" forKey:@"Title"];
    [dict setObject:kDealStatus forKey:@"Code"];
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@{@"Code":@"1",@"Name":@"全部"}];
    [arr addObject:@{@"Code":@"2",@"Name":@"尚未开始"}];
    [arr addObject:@{@"Code":@"3",@"Name":@"进行中"}];
    [arr addObject:@{@"Code":@"4",@"Name":@"已结束"}];
    [dict setObject:arr forKey:@"TypeInfo"];
    return dict;
}

- (void)requestForSearchItem
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SearchItems.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = nil;
    if (_selectInfo.categaryCode) {
        dict = @{@"CategoryCode":(_selectInfo.categaryCode?:@"")};
    }
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSMutableArray *arr = result[@"SearchItems"];
            if (!arr.count) {
                [self showAlertView:@"没有筛选条件"];
                return;
            }
            [arr insertObject:[self createChooseArrForDealStaus] atIndex:0];
            searchCondition = arr;
            [self recoverDetails];
            [self presentChooseView:searchCondition];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentDetailVC:(GoodsModel*)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
    if ([detailVC isKindOfClass:[ArtDetailVC class]]) {
        ArtDetailVC *vc = (ArtDetailVC*)detailVC;
        artDetailVC = vc;
        [vc setHiddenBottom:NO];
        [vc setProductID:info.GoodsCode];
        [vc setAuctionCode:info.auctionCode];
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

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return results.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    label.backgroundColor = [UIColor whiteColor];
    NSString *name = _selectInfo.auctionName?:@"竞价主题";
    label.text = [NSString stringWithFormat:@"   %@", name];
    label.textColor = kBlackColor;
    label.font = [UIFont boldSystemFontOfSize:20];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *model = results[indexPath.row];
    AuctionArtCell *cell = (AuctionArtCell*)[tableView dequeueReusableCellWithIdentifier:auctionCell forIndexPath:indexPath];
    cell.LFLabel.text = model.GoodsName;
//    cell.LSLabel.text =
    cell.RSLabel.text = model.endTime;
//    if (indexPath.row == 0) {
//        cell.RSLabel.endTime = @"2015/01/09 17:30:00";//model.endTime;
//        cell.RSLabel.startTime = @"2015/01/09 16:32:00";//model.startTime;
//        [cell.RSLabel start];
//    }else{
//        cell.RSLabel.endTime = @"2015/01/09 19:36:23";//model.endTime;
//        cell.RSLabel.startTime = @"2015/01/09 17:00:00";//model.startTime;
//        [cell.RSLabel start];
//    }
    
    cell.RSLabel.endTime = model.endTime;
    cell.RSLabel.startTime = model.startTime;
    [cell.RSLabel start];
    cell.RTLabel.text = [NSString stringWithFormat:@"￥%.2f",model.AppendPrice];
    cell.RBLabel.text = model.biddingNum;
    [cell.image setImageWithURL:[NSURL URLWithString:model.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
    if (cell.RSLabel.countDownTimer) {
        [_timerArr addObject:cell.RSLabel.countDownTimer];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsModel *model = results[indexPath.row];
    [self presentDetailVC:model];
}

@end

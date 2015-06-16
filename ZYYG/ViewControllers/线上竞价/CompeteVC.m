//
//  CompeteVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "CompeteVC.h"
#import "CompleteCell.h"
#import "AuctionModel.h"
#import "AuctionDetialVC.h"
#import "ClassilyVC.h"
#import "SelectInfo.h"
@interface CompeteVC()
<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *completeResults;
    AuctionDetialVC *auctionDetialVC;
}

@property (weak, nonatomic) IBOutlet UITableView *completeTB;

@end
@implementation CompeteVC

static NSString * completeCell = @"completeCell";
- (void)viewDidLoad
{
    [super viewDidLoad];
    completeResults = [[NSMutableArray alloc] init];
    self.completeTB.delegate = self;
    self.completeTB.dataSource = self;
    [self.completeTB registerNib:[UINib nibWithNibName:@"CompleteCell" bundle:nil] forCellReuseIdentifier:completeCell];
    [self addheadRefresh];
    [self requestForCompleteGoods];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (auctionDetialVC) {
        [auctionDetialVC releaseTimer];
        auctionDetialVC = nil;
    }
}

- (void)addheadRefresh
{
    [self.completeTB addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        [self requestForCompleteGoods];
    }];
}

- (NSArray*)parseForResult:(NSArray*)array
{
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        AuctionModel *model = [[AuctionModel alloc] init];
        [model parseFromAuctionResult:dict];
        [results addObject:model];
    }
    return results;
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.completeTB headerEndRefreshingWithResult:JHRefreshResultSuccess];
}

- (void)requestForCompleteGoods
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BiddingIndex.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [completeResults removeAllObjects];
            [completeResults addObjectsFromArray:[self parseForResult:result[@"data"]]];
            [self.completeTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (IBAction)doClassifyItem:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ClassifyVC"];
    vc.hidesBottomBarWhenPushed = YES;
    if ([vc isKindOfClass:[ClassilyVC class]]) {
        ClassilyVC *classVC = (ClassilyVC*)vc;
        [classVC setType:1];
        [self.navigationController pushViewController:classVC animated:YES];
    }
}
- (IBAction)doChooseItem:(id)sender {
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return completeResults.count;
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
    label.text = @"  竞价主题";
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
    AuctionModel *model = completeResults[indexPath.row];
    CompleteCell *cell = (CompleteCell*)[tableView dequeueReusableCellWithIdentifier:completeCell forIndexPath:indexPath];
    cell.LFLabel.text = model.auctionName;
    cell.type = 0;
    cell.LTLabel.text = model.auctionState;
    cell.LFoLabel.text = [model.auctionDate stringByReplacingOccurrencesOfString:@" " withString:@""];
    cell.fourLableState = YES;
    [cell.image setImageWithURL:[NSURL URLWithString:model.imageURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AuctionModel *model = completeResults[indexPath.row];
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AuctionVC"];
    vc.hidesBottomBarWhenPushed = YES;
    if ([vc isKindOfClass:[AuctionDetialVC class]]) {
        AuctionDetialVC * detailVC = (AuctionDetialVC*)vc;
        auctionDetialVC = detailVC;
        SelectInfo *info = [[SelectInfo alloc] init];
        info.auctionCode = model.auctionCode;
        info.auctionName = model.auctionName;
        detailVC.selectInfo = info;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}
@end

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

@interface CompeteVC()
<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *completeResults;
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
    cell.LFoLabel.text = model.auctionDate;
    cell.fourLableState = YES;
    [cell.image setImageWithURL:[NSURL URLWithString:model.imageURL]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

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
#import "ClassilyVC.h"
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat: @"yyyy/MM/dd HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
    NSDate *destDate= [dateFormatter dateFromString:@"2015/01/08 01:00:00"];
    NSLog(@"date is %@,,, %@",destDate, [self getNowDateFromatAnDate:[NSDate date]]);
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
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

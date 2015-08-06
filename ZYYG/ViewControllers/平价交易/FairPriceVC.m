//
//  FairPriceVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "FairPriceVC.h"
#import "ImageScrollCell.h"
#import "GoodsShowCell.h"
#import "TSPopoverController.h"
#import "ArtDetailVC.h"
#import <CommonCrypto/CommonDigest.h>
#import "GoodsModel.h"
#import "FMDatabase.h"
#import "SearchFrameVC.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"
@interface FairPriceVC()
<GoodsShowCellDelegate, UIActionSheetDelegate, SKStoreProductViewControllerDelegate>
{
    UIImage         *selectedImage;
//    BOOL    _refreshDirection;//0下拉   1上拉
    NSMutableArray  *images;//图片
    NSMutableArray  *goods;//商品
    NSString        *selectedProductID;//选择的id
    BOOL            turnToAppStroe;
}
@end

@implementation FairPriceVC

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    turnToAppStroe = NO;
    self.dataTB.delegate = self;
    self.dataTB.dataSource = self;
    [self.dataTB registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:@"scrollCell"];
    [self.dataTB registerNib:[UINib nibWithNibName:@"GoodsShowCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
    [self requestGoods:0];
    images = [[NSMutableArray alloc] init];
    goods = [[NSMutableArray alloc] init];
    [self addheadRefresh];
    [self requestForHotSearch];
    [self requestForVersion];
//    [self writeArr];
}



- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)addheadRefresh
{
    [self.dataTB addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        [self requestGoods:0];
    }];
}

- (void)parseGoodsInfo:(NSArray*)goodsArr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in goodsArr) {
        GoodsModel *model = [[GoodsModel alloc] init];
        [model goodsModelFromHomePage:dict];
        [array addObject:model];
    }
    [goods removeAllObjects];
    [goods addObjectsFromArray:array];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.dataTB headerEndRefreshingWithResult:JHRefreshResultSuccess];
}
- (BOOL)compareVersions:(NSDictionary*)dict
{
    NSArray *infoArray = [dict objectForKey:@"results"];
    if (infoArray.count) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *latestVersion = [releaseInfo objectForKey:@"version"];
        
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        
        NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];

        NSLog(@"%@,%@，，，，，%@,,, %f,,, %f", appVersion, latestVersion, infoDic, [appVersion floatValue],[latestVersion floatValue]);
        
        if ([appVersion floatValue] < [latestVersion floatValue]) {
            return YES;
        }
    }
    return NO;
}
- (void)requestForVersion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = APP_URL;
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            if ([self compareVersions:result]) {
                turnToAppStroe = YES;
                [self showAlertView:@"有新版本,请更新"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
    }];
}

- (void)doAlertView
{
    if (!turnToAppStroe) {
        return;
    }
    [self evaluate];
    exit(0);
}

- (void)evaluate{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/zhong-yi-yi-gou/id952611536?l=zh&ls=1&mt=8"]];
    
}

- (void)requestGoods:(NSInteger)number
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@index.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [images removeAllObjects];
            [goods removeAllObjects];
            [images addObjectsFromArray:result[@"Banners"]];
            [self parseGoodsInfo:result[@"Product_List"]];
            [self.dataTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestForHotSearch
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SearchKeyList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSArray *hotKeys = result[@"Keys"];
            if (hotKeys && hotKeys.count) {
                [hotKeys writeToFile:[Utities filePathName:kHotSearchArr] atomically:YES];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = segue.destinationViewController;
    vc.hidesBottomBarWhenPushed = YES;
    if ([(ArtDetailVC*)vc respondsToSelector:@selector(setProductID:)]) {
        [vc setValue:selectedProductID forKey:@"productID"];
    }else if ([vc isKindOfClass:[SearchFrameVC class]]){
        [(SearchFrameVC*)vc setSearchType:1];
    }
    
}
- (IBAction)doLeftBut:(id)sender {
    
}
- (IBAction)doRightBut:(id)sender {
    
}
- (void)scrollviewImageClick:(NSInteger)index
{
    NSDictionary *dict = images[index];
    BOOL  isLocal = [dict[@"IsLocal"] boolValue];
    if (isLocal) {
        NSString *URL = dict[@"Href"];
        NSArray *stringArr = [URL componentsSeparatedByString:@"="];
        NSString *productID = [stringArr lastObject];
        if (productID) {
            selectedProductID = productID;
            [self performSegueWithIdentifier:@"showArtDetail" sender:self];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"Href"]]];
    }
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return (goods.count + 1)/2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGRectGetWidth(tableView.frame) * 256 / 640;
    }else{
        return CGRectGetWidth(tableView.frame) * 3/ 4;
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ImageScrollCell *cell = (ImageScrollCell*)[tableView dequeueReusableCellWithIdentifier:@"scrollCell" forIndexPath:indexPath];
        cell.style = 0;
        cell.images = images;
        cell.click = ^(NSInteger index){
            [self scrollviewImageClick:index];
        };
        [cell reloadScrollViewData];
        return cell;
    }else{
        GoodsShowCell *cell = (GoodsShowCell*)[tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
        GoodsModel *goodsDetialLeft = goods[indexPath.row*2];
        if (goodsDetialLeft && ![goodsDetialLeft isKindOfClass:[NSNull class]]) {
            cell.LTLab.text = goodsDetialLeft.GoodsName;
            cell.LMLab.text = goodsDetialLeft.ArtName;
            cell.LBLab.text = [NSString stringWithFormat:@"￥%.2f",goodsDetialLeft.AppendPrice];
            [cell.leftImage setImageWithURL:[NSURL URLWithString:goodsDetialLeft.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
        }
        if (goods.count > indexPath.row*2+1) {
            GoodsModel* goodsDetialRight = goods[indexPath.row*2+1];
            if (goodsDetialRight && ![goodsDetialRight isKindOfClass:[NSNull class]]) {
                cell.showRight = YES;
                cell.RTLab.text = goodsDetialRight.GoodsName;
                cell.RMLab.text = goodsDetialRight.ArtName;
                cell.RBLab.text = [NSString stringWithFormat:@"￥%.2f",goodsDetialRight.AppendPrice];
                [cell.rightImage setImageWithURL:[NSURL URLWithString:goodsDetialRight.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
            }else{
                cell.showRight = NO;
            }
        }
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell;
    }
}


#pragma mark - GoodsShowCellDelegate
- (void)imageViewPressed:(NSIndexPath *)indexPath position:(BOOL)position
{
    selectedProductID = [goods[indexPath.row*2+position] GoodsCode];
    [self performSegueWithIdentifier:@"showArtDetail" sender:self];
}

@end

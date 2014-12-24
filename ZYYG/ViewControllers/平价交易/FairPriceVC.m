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

@interface FairPriceVC()
<GoodsShowCellDelegate, UIActionSheetDelegate>
{
    UIImage         *selectedImage;
//    BOOL    _refreshDirection;//0下拉   1上拉
    NSMutableArray  *images;//图片
    NSMutableArray  *goods;//商品
    NSString        *selectedProductID;//选择的id
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
    self.dataTB.delegate = self;
    self.dataTB.dataSource = self;
    [self.dataTB registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:@"scrollCell"];
    [self.dataTB registerNib:[UINib nibWithNibName:@"GoodsShowCell" bundle:nil] forCellReuseIdentifier:@"myCell"];
    [self requestGoods:0];
    images = [[NSMutableArray alloc] init];
    goods = [[NSMutableArray alloc] init];
    [self addheadRefresh];
    [self requestForHotSearch];
//    [self writeArr];
}

//- (void)writeArr
//{
//    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"adress.db"];
//    FMDatabase *db     = [FMDatabase databaseWithPath:dbPath];
//    [db open];
////    BOOL success = [db open];
//    NSString *sql = [NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement, %@_id integer, %@_name text);"
//                     "create table %@ (id integer primary key autoincrement, %@_id integer, %@_name text, %@_zipCode text, %@_id text);"
//                     "create table %@ (id integer primary key autoincrement, %@_id integer, %@_name text, %@_id text);"
//                     , kProvinceAdress, kProvinceAdress, kProvinceAdress, kCityAdress, kCityAdress,kCityAdress, kCityAdress, kProvinceAdress, kTownAdress, kTownAdress, kTownAdress, kCityAdress];
//    BOOL success = [db executeStatements:sql];
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"erp_province_code" ofType:@"json"];
//    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    id ss = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    NSArray *provinces = ss[@"RECORDS"];
//    
//    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"erp_city_code" ofType:@"json"];
//    NSString *s1 = [NSString stringWithContentsOfFile:path1 encoding:NSUTF8StringEncoding error:nil];
//    id ss1 = [NSJSONSerialization JSONObjectWithData:[s1 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    NSArray *provinces1 = ss1[@"RECORDS"];
//    
//    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"erp_district_code" ofType:@"json"];
//    NSString *s2 = [NSString stringWithContentsOfFile:path2 encoding:NSUTF8StringEncoding error:nil];
//    id ss2 = [NSJSONSerialization JSONObjectWithData:[s2 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    NSArray *provinces2 = ss2[@"RECORDS"];
//    
//    if (success) {
//        int i = 0;
//        for (NSDictionary *dict in provinces) {
//            
//            NSString *string = [NSString stringWithFormat:@"insert into %@ (%@_id, %@_name) values ('%d', '%@');", kProvinceAdress, kProvinceAdress, kProvinceAdress, [dict[@"PROVINCE_ID"] integerValue], dict[@"PROVINCE_NAME"]];
//            [db executeStatements:string withResultBlock:^int(NSDictionary *resultsDictionary) {
//                NSLog(@"%d", [resultsDictionary[@"count"] integerValue]);
//                return NO;
//            }];
//        }
//       
//        for (NSDictionary *dict in provinces1) {
//            i++;
//            NSString *string = [NSString stringWithFormat:@"insert into %@ (%@_id, %@_name, %@_zipCode, %@_id) values ('%d', '%@', '%@', '%d');", kCityAdress, kCityAdress, kCityAdress, kCityAdress,kProvinceAdress, [dict[@"CITY_ID"] integerValue], dict[@"CITY_NAME"], dict[@"ZIPCODE"], [dict[@"PROVINCE_ID"] integerValue]];
//            [db executeStatements:string];
//        }
//        
//        for (NSDictionary *dict in provinces2) {
//            NSString *string = [NSString stringWithFormat:@"insert into %@ (%@_id, %@_name, %@_id) values ('%d', '%@', '%d');", kTownAdress, kTownAdress, kTownAdress, kCityAdress, [dict[@"DISTRICT_ID"] integerValue], dict[@"DISTRICT_NAME"], [dict[@"CITY_ID"] integerValue]];
//            [db executeStatements:string];
//        }
//         NSLog(@"%ld", (long)i);
//    }
//    
//}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
            [cell.leftImage setImageWithURL:[NSURL URLWithString:goodsDetialLeft.picURL]];
        }
        if (goods.count > indexPath.row*2+1) {
            GoodsModel* goodsDetialRight = goods[indexPath.row*2+1];
            if (goodsDetialRight && ![goodsDetialRight isKindOfClass:[NSNull class]]) {
                cell.showRight = YES;
                cell.RTLab.text = goodsDetialRight.GoodsName;
                cell.RMLab.text = goodsDetialRight.ArtName;
                cell.RBLab.text = [NSString stringWithFormat:@"￥%.2f",goodsDetialRight.AppendPrice];
                [cell.rightImage setImageWithURL:[NSURL URLWithString:goodsDetialRight.picURL]];
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

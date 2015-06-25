//
//  MyCollectionVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyCollectionVC.h"
#import "MyCollectionCell.h"
#import "HMSegmentedControl.h"
#import "UserInfo.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"
//我的收藏
@interface MyCollectionVC ()
{
//    HMSegmentedControl *segmentView;// table view title
    NSMutableArray *collections;
    UserInfo *user;
    NSInteger pageN;
    NSInteger pageS;
    BOOL                refreshFooter;//是否是上拉刷新
}


@end

@implementation MyCollectionVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.myCollectionTableView registerNib:[UINib nibWithNibName:@"MyCollectionCell" bundle:nil] forCellReuseIdentifier:@"MyCollectionCell"];
    collections=[NSMutableArray array];
    pageN=1;
    pageS=5;
    [self requestCollections:pageN pageSize:pageS];
    [self showBackItem];
    self.myCollectionTableView.delegate=self;
    self.myCollectionTableView.dataSource=self;
    
    
    [self addFootRefresh];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

//- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
//    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
//    
//    [self.myCollectionTableView reloadData];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFootRefresh
{
    [self.myCollectionTableView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = NO;
        pageN=1;
        [self requestCollections:pageN pageSize:pageS];
    }];
    [self.myCollectionTableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageN=pageN+1;
        refreshFooter = YES;
        [self requestCollections:pageN pageSize:pageS];
    }];
}


-(void)requestCollections:(NSInteger)page pageSize:(NSInteger)num
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@favoriteList.ashx",kServerDomain];
    NSLog(@"url   %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user.userKey, @"key", [NSString stringWithFormat:@"%ld",(long)num],@"num",[NSString stringWithFormat:@"%ld",(long)page], @"page", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSArray *carray=result[@"data"];
            if (!carray ||[carray isKindOfClass:[NSNull class]]||carray.count<1) {
                [self showAlertView:@"无新数据!"];
            }else{
                if (!refreshFooter) {
                    [collections removeAllObjects];
                }
                for (int i=0; i<carray.count; i++) {
                    GoodsModel *model=[[GoodsModel alloc] init];
                    [model goodsModelFromCollect:carray[i]];
                    [collections addObject:model];
                }
            }
            [self.myCollectionTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.myCollectionTableView footerEndRefreshing];
    [self.myCollectionTableView headerEndRefreshingWithResult:JHRefreshResultSuccess];
}



#pragma mark -tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (segmentView) {
//        return segmentView;
//    }
//    segmentView = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"全部", @"艺术品", @"拍卖会",@"艺术家"]];
//    segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
//    segmentView.frame = CGRectMake(0, 0, 320, 40);
//    segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
//    segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
//    segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
//    [segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//    return segmentView;
//    
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return collections.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *goods=collections[indexPath.row];
    MyCollectionCell *cell = (MyCollectionCell*)[tableView dequeueReusableCellWithIdentifier:@"MyCollectionCell" forIndexPath:indexPath];
   [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
    cell.goodsName.text=goods.GoodsName;
    cell.Lab1.text=[NSString stringWithFormat:@"作者:%@",goods.ArtName];
        cell.Lab3.text=[NSString stringWithFormat:@"模式:%@",goods.SaleChannel];
//    cell.Lab4.text=[NSString stringWithFormat:@"状态:%@",goods.Nstatus];
    return cell;
   
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsModel *goods=collections[indexPath.row];
    [self presentDetailVC:goods];
}

- (void)presentDetailVC:(GoodsModel*)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
     if ([info.SaleChannel isEqualToString:@"拍卖"]) {
         [detailVC setValue:@(2) forKey:@"type"];
         [detailVC setValue:@(0) forKey:@"hiddenBottom"];
     }else if([info.SaleChannel isEqualToString:@"私人洽购"]){
         [detailVC setValue:@(1) forKey:@"type"];
         [detailVC setValue:@(0) forKey:@"hiddenBottom"];
     }else{
         [detailVC setValue:@(0) forKey:@"type"];
         [detailVC setValue:@(0) forKey:@"hiddenBottom"];
     }
    [detailVC setValue:info.auctionCode forKey:@"auctionCode"];
    [detailVC setValue:info.GoodsCode forKey:@"productID"];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        [dataArra removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        //        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        [self.adressTB reloadData];
        [self requestForDeleteCollect:indexPath];
    }
}

- (void)requestForDeleteCollect:(NSIndexPath*)indexPath
{
    GoodsModel *collect=collections[indexPath.row];
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@Delfavorite.ashx",kServerDomain];
    NSLog(@"url %@", url);

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",collect.GoodsCode,@"product_id", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            //                [self.adressTB reloadData];
            if([@"0" isEqualToString:[result safeObjectForKey:@"errno"]])
            {
                [self showAlertView:@"已取消收藏"];
                [collections removeObject:collect];
            }else{
                [self showAlertView:@"取消收藏失败"];
            }
            [self.myCollectionTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
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

//
//  MyCollectionVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyCollectionVC.h"
#import "RecommendedListCell.h"
#import "HMSegmentedControl.h"
#import "UserInfo.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"

@interface MyCollectionVC ()
{
//    HMSegmentedControl *segmentView;// table view title
    NSMutableArray *collections;
    UserInfo *user;
}


@end

@implementation MyCollectionVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    collections=[NSMutableArray array];
    [self requestCollections:0];
    [self showBackItem];
    self.myCollectionTableView.delegate=self;
    self.myCollectionTableView.dataSource=self;
    [self.myCollectionTableView registerNib:[UINib nibWithNibName:@"RecommendedListCell" bundle:nil] forCellReuseIdentifier:@"RecommendedListCell"];
    
   
    // Do any additional setup after loading the view.
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

-(void)requestCollections:(NSInteger)collectType
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
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:user.userKey, @"key", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSArray *carray=result[@"data"];
            for (int i=0; i<carray.count; i++) {
                GoodsModel *model=[[GoodsModel alloc] init];
                [model goodsModelFromCollect:carray[i]];
                [collections addObject:model];
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
    RecommendedListCell *cell = (RecommendedListCell*)[tableView dequeueReusableCellWithIdentifier:@"RecommendedListCell" forIndexPath:indexPath];
    cell.collectButton.hidden=YES;
    cell.collectionLabel.hidden=NO;
   [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.picURL]];
    cell.goodsName.text=goods.GoodsName;
    cell.fristLabel.text=[NSString stringWithFormat:@"作者:%@",goods.ArtName];
    cell.secondLabel.text=[NSString stringWithFormat:@"停售日期:%@",goods.UpShelfTime];
    cell.collectionLabel.text=[NSString stringWithFormat:@"状态:%@",goods.Nstatus];
    return cell;
   
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *goods=collections[indexPath.row];
    [self presentDetailVC:goods.GoodsCode];
}

- (void)presentDetailVC:(id)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
    if ([(ArtDetailVC*)detailVC respondsToSelector:@selector(setHiddenBottom:)]) {
        [detailVC setValue:@(1) forKey:@"hiddenBottom"];
    }
    if ([(ArtDetailVC*)detailVC respondsToSelector:@selector(setProductID:)]) {
        [detailVC setValue:(NSString*)info forKey:@"productID"];
    }
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

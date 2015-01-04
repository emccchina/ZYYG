//
//  TalkBuy.m
//  ZYYG
//
//  Created by EMCC on 14/12/5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "TalkBuyVC.h"
#import "RecommendedListCell.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"


@interface TalkBuyVC ()
{
    NSMutableArray *goodsArray;//查询结果
    NSInteger pageNum;
   
    NSMutableArray    *allArtist;//筛选作者名 是否已经存在， 不存在请求
    NSString      *artistName;//已经选择的艺术家名,显示在chooseview 上的

}

@end

@implementation TalkBuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pageNum=1;
    artistName=@"";
    goodsArray=[NSMutableArray array];
    allArtist=[NSMutableArray array];
    self.title = @"私人洽购";
//    [self showBackItem];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"筛选" target:self action:@selector(doSelectButton:)];
    [self requestTalkBuy:pageNum artistName:artistName];
    [self addFootRefresh];
    [self.talkBuyTableView registerNib:[UINib nibWithNibName:@"RecommendedListCell" bundle:nil] forCellReuseIdentifier:@"RecommendedListCell"];
    self.talkBuyTableView.dataSource=self;
    self.talkBuyTableView.delegate=self;
    
    self.chooseView.type = 1;
    [self.chooseView setChooseFinised:^(id selected){
        if ([selected isKindOfClass:[NSDictionary class]]) {
            [goodsArray removeAllObjects];
            [self presChooseView:nil];
            [self requestTalkBuy:1 artistName:selected[@"Code"]];
        }else if ([selected isKindOfClass:[UIEvent class]]){
            [self doSelectButton:nil];
        }
        
    }];

}


- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//私人洽购筛选 (条件只能选择作者)
- (void)doSelectButton:(UIBarButtonItem*)item
{
    if (!self.chooseView.hidden) {//隐藏 同时 筛选
        [self presChooseView:nil];
        return;
    }
    if (allArtist && allArtist.count) {
        [self presChooseView:allArtist];
        return;
    }
    [self requestForArtist];
}
//选择效果
- (void)presChooseView:(NSMutableArray *)arr
{
    self.chooseView.hidden = !self.chooseView.hidden;
    NSString *titleItem = self.chooseView.hidden ? @"筛选" : @"确定";
    self.navigationItem.rightBarButtonItem.title = titleItem;
    [self.chooseView reloadTitles:arr details:nil];
    if (!self.chooseView.hidden) {
        self.chooseView.alpha = 0;
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.chooseView.alpha = 1;
        } completion:^(BOOL finished){
            
        }];
    }
}
//请求作者列表
- (void)requestForArtist
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SearchItems.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"type",@"author",nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSMutableArray *rarray =result[@"SearchItems"];
            for (NSDictionary *dict in rarray) {
                if ([dict[@"Code"] isEqualToString:@"author"]) {
                   NSMutableArray *darray =dict[@"TypeInfo"];
                    NSDictionary *dict = @{@"Code":@"", @"Name":@"全部"};
                    [allArtist addObject:dict];
                    [allArtist addObjectsFromArray:darray];
                }
            }
            [self presChooseView:allArtist];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];

        [self showAlertView:kNetworkNotConnect];
    }];
}
//上拉刷新
- (void)addFootRefresh
{
    [goodsArray removeAllObjects];
    [self.talkBuyTableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageNum=pageNum+1;
        [self requestTalkBuy:pageNum artistName:artistName];
    }];
}
//私人洽购请求
-(void)requestTalkBuy:(NSInteger)page artistName:(NSString *)name
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@PrivateSalesList.ashx",kServerDomain];
    NSLog(@"url   %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"20",@"num",[NSString stringWithFormat:@"%ld",(long)page],@"page",name,@"AuthorCode", nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSMutableArray *carray=result[@"Goods"];
            if (!carray ||[carray isKindOfClass:[NSNull class]]|| carray.count < 1 ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"无新数据!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }else{
                for (int i=0; i<carray.count; i++) {
                    GoodsModel *model=[[GoodsModel alloc] init];
                    [model goodsModelFromSearch:carray[i]];
                    [goodsArray addObject:model];
                }
            }
            [self.talkBuyTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.talkBuyTableView footerEndRefreshing];
}

#pragma -mark tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return goodsArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *goods=goodsArray[indexPath.row];
   RecommendedListCell *cell = (RecommendedListCell*)[tableView dequeueReusableCellWithIdentifier:@"RecommendedListCell" forIndexPath:indexPath];
    cell.collectButton.hidden=YES;
    cell.collectionLabel.hidden=YES;
    [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.picURL]];
    cell.goodsName.text=goods.GoodsName;
    cell.fristLabel.text=[NSString stringWithFormat:@"作者:%@",goods.ArtName];
    cell.secondLabel.text=[NSString stringWithFormat:@"商品编码:%@",goods.GoodsCode];
//    [cell.collectButton setTitle:@"收藏" forState:UIControlStateNormal];
//    [cell.collectButton setTitle:@"收藏" forState:UIControlStateHighlighted];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsModel *goods=goodsArray[indexPath.row];
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
    if ([(ArtDetailVC*)detailVC respondsToSelector:@selector(setType:)]) {
        [detailVC setValue:@(1) forKey:@"type"];
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

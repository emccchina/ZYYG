//
//  ArtDetailVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ArtDetailVC.h"
#import "ImageScrollCell.h"
#import "CollectCell.h"
#import "ArtInfoCell.h"
#import "SpreadCell.h"
#import "GoodsModel.h"
#import "AppDelegate.h"
#import "KDPreView.h"

@interface ArtDetailVC ()
<UITableViewDataSource, UITableViewDelegate, CycleScrollViewDatasource, CycleScrollViewDelegate>
{
    BOOL                _spreadArtist;//艺术家简介展开
    BOOL                _spreadArt;//作品简介展开
    BOOL                _spreadCertification;//证书展开
    GoodsModel          *goods;
    CycleScrollView     *scrollview;
}
@property (weak, nonatomic) IBOutlet UITableView *detailTB;
@property (weak, nonatomic) IBOutlet UIButton *addCartBut;
@property (weak, nonatomic) IBOutlet UIButton *cartBut;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation ArtDetailVC

static NSString *imageCell = @"ImageScrollCell";
static NSString *collectCell = @"CollectCell";
static NSString *artInfoCell = @"ArtInfoCell";
static NSString *spreadCell = @"SpreadCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    CGFloat TBBottom = self.hiddenBottom ? 0 : 50;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.detailTB attribute:NSLayoutAttributeBottom multiplier:1 constant:TBBottom]];

    self.bottomView.hidden = self.hiddenBottom;
    
    self.detailTB.delegate = self;
    self.detailTB.dataSource = self;
    [self.detailTB registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:imageCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"CollectCell" bundle:nil] forCellReuseIdentifier:collectCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"ArtInfoCell" bundle:nil] forCellReuseIdentifier:artInfoCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"SpreadCell" bundle:nil] forCellReuseIdentifier:spreadCell];
    
    self.addCartBut.layer.cornerRadius = 3;
    self.addCartBut.layer.backgroundColor = kRedColor.CGColor;
    
    CGFloat width = CGRectGetWidth(self.countLab.frame);
    self.countLab.layer.cornerRadius = width/2;
    self.countLab.layer.backgroundColor = kRedColor.CGColor;
    [self setCountLabCount:0];
    
    NSLog(@"product id %@", self.productID);
    
    
}

- (void)addScrollForImageToWindow:(NSArray*)images
{
    if (!scrollview) {
        UIWindow *window = [(AppDelegate*)[UIApplication sharedApplication].delegate window];
        scrollview = [[CycleScrollView alloc] initWithFrame:self.navigationController.view.bounds];
        scrollview.delegate = self;
        scrollview.datasource = self;
        [window addSubview:scrollview];
    }
    scrollview.hidden = NO;
}

- (void)setCountLabCount:(NSInteger)count
{
    self.countLab.hidden = count ? NO : YES;
    self.countLab.text = [NSString stringWithFormat:@"%ld", (long)count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestDetialInfo];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)doRightButton:(UIBarButtonItem*)item
{
    [Utities presentLoginVC:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addToCartPressed:(id)sender {
    if (![UserInfo shareUserInfo].isLogin) {
        [Utities presentLoginVC:self];
        return;
    }
    [self requestAddCart];
}
- (IBAction)goToCartPressed:(id)sender {
    [self.tabBarController setSelectedIndex:3];
}

- (void)reloadTableViewSection:(NSInteger)section spread:(BOOL)spread
{
    NSIndexSet *indexSection = [[NSIndexSet alloc] initWithIndex:section];
    if (spread) {
        CGPoint offset = self.detailTB.contentOffset;
        offset.y += 50;
        [self.detailTB setContentOffset:offset];
    }
    [self.detailTB reloadSections:indexSection withRowAnimation:UITableViewRowAnimationLeft];
    
}

- (void)requestDetialInfo
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@Detail.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"product_id", nil];
    if ([[UserInfo shareUserInfo] isLogin]) {
        [dict setObject:[UserInfo shareUserInfo].userKey forKey:@"key"];
    }
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        
        if (result) {
            goods =[GoodsModel goodsModelWith:result];
            [self.detailTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];

}

- (void)requestAddCart
{
    NSNumber *state12 = goods.GoodsNum;
    if (![state12 integerValue]) {
        [self showAlertView:@"该商品已售,无法加入购物车"];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@AddCart.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.productID,@"product_id",[UserInfo shareUserInfo].userKey,@"key", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
       
        id result = [self parseResults:responseObject];
        if (result) {
            [self showAlertView:@"添加成功"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestForCollect:(BOOL)collect
{
    if (![UserInfo shareUserInfo].isLogin) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = collect ? [NSString stringWithFormat:@"%@favorite.ashx",kServerDomain] : [NSString stringWithFormat:@"%@Delfavorite.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.productID,@"Product_id",[UserInfo shareUserInfo].userKey,@"key",@"0",@"AUCTION_CODE",@"0",@"SALE_CHANNEL", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            goods.IsCollect = @(![goods.IsCollect integerValue]);
            [self.detailTB reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}
#pragma mark - scrollview cycle
- (NSInteger)numberOfPages
{
    return goods.ImageUrl.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    CGRect rect = scrollview.bounds;
    KDPreView *imageView = [[KDPreView alloc] initWithFrame:rect];
    if (goods.ImageUrl.count > index) {
        NSString *url =  goods.ImageUrl[index];
        imageView.imageURL = url;
        [imageView imageShow];
    }
    return imageView;
}

- (void)didClickPage:(CycleScrollView *)csView atIndex:(NSInteger)index
{
    scrollview.hidden = YES;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return (indexPath.row == 0) ? (CGRectGetWidth(tableView.frame) / 2) : 75;
        case 1:
            return 110;
        case 2:{
            NSString *text =goods.AuthorIntro;
            if (![text isKindOfClass:[NSNull class]] && ![text isEqualToString:@""] && _spreadArtist) {
                CGSize size = [Utities sizeWithUIFont:[UIFont systemFontOfSize:17] string:text rect:CGSizeMake(CGRectGetWidth(tableView.frame) - 20, CGFLOAT_MAX)];
                return size.height +70;
            }
            
            return  50;
        }
        case 3:{
            NSString *text =goods.GoodsIntro;
            if (text && ![text isEqualToString:@""] && _spreadArt) {
                CGSize size = [Utities sizeWithUIFont:[UIFont systemFontOfSize:17] string:text rect:CGSizeMake(CGRectGetWidth(tableView.frame) - 20, CGFLOAT_MAX)];
                return size.height +70;
            }
            return 50;
        }
//        case 4:
//        {
//            NSString *text = detailDict[@"AuthorIntro"];
//            if (![text isKindOfClass:[NSNull class]] && ![text isEqualToString:@""] && _spreadCertification) {
//                CGSize size = [Utities sizeWithUIFont:[UIFont systemFontOfSize:17] string:text rect:CGSizeMake(CGRectGetWidth(tableView.frame) - 20, CGFLOAT_MAX)];
//                return size.height +70;
//            }
//            return 50;
//        }
        default:
            return 44;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 10;
    }else
    {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0) {
                ImageScrollCell *cell = (ImageScrollCell*)[tableView dequeueReusableCellWithIdentifier:imageCell forIndexPath:indexPath];
                cell.style = 1;
                cell.images = goods.ImageUrl;
                [cell reloadScrollViewData];
                cell.click = ^(){
                    [self addScrollForImageToWindow:goods.ImageUrl];
                };
                return cell;
            }else{
                CollectCell *cell = (CollectCell*)[tableView dequeueReusableCellWithIdentifier:collectCell forIndexPath:indexPath];
                cell.spread = YES;
                NSNumber *colloct =goods.IsCollect;
                NSLog(@"%@", colloct);
                cell.collectState = [colloct integerValue];
                cell.topLab.text =goods.GoodsName;
                cell.botLab.text = @"价格:";
                cell.botRightLab.text = [NSString stringWithFormat:@"￥%.2f",goods.AppendPrice];
                cell.colloct = ^(BOOL collect11){
                    [self requestForCollect:collect11];
                };
                return cell;
            }
        }
        case 1:{
            ArtInfoCell *cell = (ArtInfoCell*)[tableView dequeueReusableCellWithIdentifier:artInfoCell forIndexPath:indexPath];
            cell.left1Lab.text = [NSString stringWithFormat:@"作者:%@",goods.ArtName];
            cell.left2Lab.text = [NSString stringWithFormat:@"分类:%@",goods.CreationStyle];
            NSNumber *state12 = goods.GoodsNum;
            cell.left3Lab.text = [NSString stringWithFormat:@"尺寸:%@",goods.SpecDesc ];
            cell.left4Lab.text = [NSString stringWithFormat:@"编号:%@", goods.GoodsCode];
            cell.R1Lab.text = [NSString stringWithFormat:@"材质:%@",goods.CategoryName];
            cell.R2Lab.text = [NSString stringWithFormat:@"状态:%@", [state12 integerValue] ? @"待售" : @"已售"];
            return cell;
        }
        case 2:{
            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
            cell.titleLab.text = @"艺术家简介";
            cell.detailLab.text =goods.AuthorIntro;
            cell.spreadState = _spreadArtist;
            cell.reloadHeight = ^(BOOL spread){
                _spreadArtist = spread;
                [self reloadTableViewSection:indexPath.section spread:spread];
            };
            return cell;
        }
        case 3:{
            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
            cell.titleLab.text = @"作品简介";
            cell.detailLab.text =goods.GoodsIntro;
            //            [detailDict safeObjectForKey:@"GoodsIntro"];
            cell.spreadState = _spreadArt;
            cell.reloadHeight = ^(BOOL spread){
                //                NSLog(@"spread is %d", spread);
                _spreadArt = spread;
                [self reloadTableViewSection:indexPath.section spread:spread];
            };
            return cell;
        }
        //        case 4:{
        //            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
        //            cell.titleLab.text = @"布罗德根艺术指数证书";
        //            cell.detailLab.text = @"null";
        //            cell.spreadState = _spreadCertification;
        //            cell.reloadHeight = ^(BOOL spread){
        ////                NSLog(@"spread is %d", spread);
        //                _spreadCertification = spread;
        //                [self reloadTableViewSection:indexPath.section spread:spread];
        //            };
        //            return cell;
        //        }
        default:
        return nil;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end

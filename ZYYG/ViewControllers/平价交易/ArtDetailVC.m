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
#import "BiddingInfoCell.h"
#import "MarginChooseView.h"
#import "PayMarginVC.h"

@interface ArtDetailVC ()
<UITableViewDataSource, UITableViewDelegate, CycleScrollViewDatasource, CycleScrollViewDelegate>
{
    BOOL                _spreadArtist;//艺术家简介展开
    CGFloat             _heightArtist;
    BOOL                _spreadArt;//作品简介展开
    CGFloat             _heightArt;
    BOOL                _spreadCertification;//证书展开
    CGFloat             _heightCertification;//
    GoodsModel          *goods;
    CycleScrollView     *scrollview;
    NSMutableArray      *historyArr;
    BOOL                _spreadHistory;
    MarginChooseView    *_marginView1;
    CGFloat             _heightHistory;
    NSMutableArray      *_timerArr;//定时器释放 否则会内存泄露
    BOOL                _isReleaseTimer;
    NSInteger                isBegin;//竞价中 拍卖是否开始
    BOOL                isCompare;//竞价中底部view 状态 通过刷新0  还是 加减1,比较是否最大值 可否提交出价
    
}
@property (weak, nonatomic) IBOutlet UITableView *detailTB;
@property (weak, nonatomic) IBOutlet UIButton *addCartBut;
@property (weak, nonatomic) IBOutlet UIButton *cartBut;
@property (weak, nonatomic) IBOutlet UILabel *countLab;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *marginView;

@end

@implementation ArtDetailVC

static NSString *imageCell = @"ImageScrollCell";
static NSString *collectCell = @"CollectCell";
static NSString *artInfoCell = @"ArtInfoCell";
static NSString *spreadCell = @"SpreadCell";
static NSString *biddingInfoCell = @"biddingInfoCell";

- (void)awakeFromNib
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    NSLog(@"%@,,%@",self.parentViewController, self.navigationController.parentViewController);
    self.navigationController.delegate = self;
    CGFloat TBBottom = self.hiddenBottom ? 0 : 50;
    self.bottomView.hidden = self.hiddenBottom;
    goods = [[GoodsModel alloc] init];
    if (self.type == 2) {
        TBBottom = self.hiddenBottom ? 0 : 85;
        self.bottomView.hidden = YES;
        _marginView.hidden = self.hiddenBottom;
    }
    CGFloat addButWidth = (self.type == 1 ? 150 : 95);
    [self.addCartBut addConstraint:[NSLayoutConstraint constraintWithItem:self.addCartBut attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:addButWidth]];
    
    historyArr = [[NSMutableArray alloc] init];
    _heightArt = 0;
    _heightArtist = 0;
    isCompare = NO;
    _timerArr = [[NSMutableArray alloc] init];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.detailTB attribute:NSLayoutAttributeBottom multiplier:1 constant:TBBottom]];
    
    
    
    self.detailTB.delegate = self;
    self.detailTB.dataSource = self;
    [self.detailTB registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:imageCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"CollectCell" bundle:nil] forCellReuseIdentifier:collectCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"ArtInfoCell" bundle:nil] forCellReuseIdentifier:artInfoCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"SpreadCell" bundle:nil] forCellReuseIdentifier:spreadCell];
    [self.detailTB registerNib:[UINib nibWithNibName:@"BiddingInfoCell" bundle:nil] forCellReuseIdentifier:biddingInfoCell];
    self.addCartBut.layer.cornerRadius = 3;
    self.addCartBut.layer.backgroundColor = kRedColor.CGColor;
    if (self.type == 1) {
        self.cartBut.hidden = YES;
        [self.addCartBut setTitle:@"致电:" forState:UIControlStateNormal];
    }else{
        self.cartBut.hidden = NO;
    }
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MarginChooseView" owner:_marginView options:nil];
    UIView *view = nib[0];
    _marginView1 = (MarginChooseView*)view;
    [self.marginView addSubview:_marginView1];
    _marginView1.frame = self.marginView.bounds;
    __block ArtDetailVC *weakSelf = self;
    _marginView1.changeMoney = ^(BOOL add){
        [weakSelf doWithMoneyCount];
    };
    _marginView1.gotoMargin = ^(NSInteger state, BOOL hightest){
        switch (state) {
            case 0:
                [weakSelf presentPayMarginVC];
                break;
            case 1:
                break;
            case 2:
            case 5:{
                if (hightest) {
                    [weakSelf requestForHightestPrice];
                }else{
                    [weakSelf requestForUpLoadMyPrice];
                }
            }break;
            default:
                break;
        }
        
    };
    
    CGFloat width = CGRectGetWidth(self.countLab.frame);
    self.countLab.layer.cornerRadius = width/2;
    self.countLab.layer.backgroundColor = kRedColor.CGColor;
    [self setCountLabCount:0];
}

- (void)doWithMoneyCount
{
    if (![[UserInfo shareUserInfo] isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    if (!_marginView1.type) {
        [self showAlertView:@"请先交保证金"];
        return;
    }
    isCompare = YES;
    [self requestForHistory];
}

- (void)presentPayMarginVC
{
    if (![[UserInfo shareUserInfo] isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    PayMarginVC *vc = (PayMarginVC *)[[UIStoryboard storyboardWithName:@"CompeteStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PayMarginVC"];
    vc.goods=goods;
    vc.auctionCode = self.auctionCode;
    
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)releaseTimer
{
    [_timerArr makeObjectsPerformSelector:@selector(invalidate)];
    [_timerArr removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)back
{
    [self releaseTimer];
    [self.navigationController popViewControllerAnimated:YES];
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
    if (self.type == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", goods.telephone]]];
        return;
    }else{
        if (![UserInfo shareUserInfo].isLogin) {
        [Utities presentLoginVC:self];
        return;
        }
        [self requestAddCart];
    }
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

- (BOOL)artOwn:(NSArray*)array
{
    if (![[UserInfo shareUserInfo] isLogin]) {
        return NO;
    }
    if (array.count > 0) {
        NSDictionary *dict = array[0];
        if ([dict[@"UserCode"] isEqualToString:[UserInfo shareUserInfo].userKey]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)setBottomState
{
    if (isCompare) {
        double price = [_marginView1.inputTF.text doubleValue];
        if (price <= [goods.maxMoney floatValue]) {
            [self showAlertView:@"已有用户出更高价格"];
        }
        return;
    }
    
    if (goods.biddingStatus == 20) {
        _marginView1.type = 4;
    }else if(goods.biddingStatus == 10){
        _marginView1.type = 3;
        if ([self artOwn:historyArr]) {
            [self showAlertView:@"您已拍下此艺术品,请在十分钟内付款"];
        }
    }else{
        if (goods.isBidEntrustPrice) {
            _marginView1.type = 5;
            _marginView1.appendMoney = [goods.appendMoney doubleValue];
            _marginView1.minMoney = [goods.maxMoney doubleValue];
            return;
        }
        if (goods.isSecurityDeposit == 10) {
            if (!isBegin) {
                _marginView1.type = 1;
            }else{
                _marginView1.type = 2;
                _marginView1.appendMoney = [goods.appendMoney doubleValue];
                _marginView1.minMoney = [goods.maxMoney doubleValue];
            }
        }else{
           _marginView1.type = 0;
        }
    }
    
    
}

- (void)requestDetialInfo
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = (self.type == 2?[NSString stringWithFormat:@"%@BidDetail.ashx",kServerDomain]:[NSString stringWithFormat:@"%@Detail.ashx",kServerDomain]);
    NSLog(@"url %@", url);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"product_id", nil];
    if ([[UserInfo shareUserInfo] isLogin]) {
        [dict setObject:[UserInfo shareUserInfo].userKey forKey:@"key"];
    }
    if (self.auctionCode) {
        [dict setObject:self.auctionCode forKey:@"AuctionCode"];
    }
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [goods goodsModelWith:result];
            if (self.type == 2) {
                [self setBottomState];
                [self requestForHistory];
            }
            if (self.type == 1) {
                NSString *telTitle = [NSString stringWithFormat:@"致电:%@",goods.telephone];//goods.telephone;
                [self.addCartBut setTitle:telTitle forState:UIControlStateNormal];
            }
            [self.detailTB reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
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
   MutableOrderedDictionary *newDict = [self addWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"Product_id",[UserInfo shareUserInfo].userKey,@"key", nil];

    [dict setObject:(self.auctionCode?:@"") forKey:@"AUCTION_CODE"];
    [dict setObject:[NSString stringWithFormat:@"%ld", (long)goods.typeForGoods*10] forKey:@"SALE_CHANNEL"];
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

- (void)requestForHistory
{
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BidHistory.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"goodsCode", nil];
    if (self.auctionCode) {
        [dict setObject:self.auctionCode forKey:@"auctionCode"];
    }
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        
        if (result) {
            goods.maxMoney = result[@"MaxMoeny"];
            goods.bidHistory = result[@"Table"];
            goods.biddingStatus = [result[@"Status"] integerValue];
            [historyArr removeAllObjects];
            [historyArr addObjectsFromArray:result[@"data"]];
            if (self.type == 2) {
                [self setBottomState];
            }
            [self.detailTB reloadData];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];

}

- (void)requestForHightestPrice
{
    if (![UserInfo shareUserInfo].isLogin) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BidEntrustPrice.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"GoodsCode",[UserInfo shareUserInfo].userKey,@"key",self.auctionCode,@"AuctionCode",_marginView1.inputTF.text,@"Price",@"1",@"type", nil];
    MutableOrderedDictionary *newDict=[self priceWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];

}

- (void)requestForUpLoadMyPrice
{
    if (![UserInfo shareUserInfo].isLogin) {
        [Utities presentLoginVC:self];
        return;
    }
    isCompare = YES;
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@BiddingSave.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.productID,@"GoodsCode",[UserInfo shareUserInfo].userKey,@"key",self.auctionCode,@"AuctionCode",_marginView1.inputTF.text,@"bidMoney", nil];
    MutableOrderedDictionary *newDict=[self dictWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [self showAlertView:@"出价成功"];
            [self setBottomState];
            isCompare = NO;
            [self requestForHistory];
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
    return 5+(self.type==2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
//        case 5:
//            return _spreadHistory?3:1;//historyArr.count+1;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.1;
            break;
            
        default:
            return 10;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return (indexPath.row == 0) ? (CGRectGetWidth(tableView.frame) / 2) : (self.type == 2 ? 185 : 75);
        case 1:
            return 120;
        case 2:{
            return  50+(_spreadArtist?_heightArtist:0);
        }
        case 3:{
            return 50+(_spreadArt?_heightArt:0);
        }
        case 4:
        {
            return 50+(_spreadCertification?_heightCertification:0);
        }
        case 5:{
            return 50+(_spreadHistory?_heightHistory:0);
        }
        default:
            return 44;
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
                cell.click = ^(NSInteger index){
                    [self addScrollForImageToWindow:goods.ImageUrl];
                };
                [_timerArr addObject:cell.scrollView.animationTimer];
                return cell;
            }else{
                if (self.type == 2) {
                    BiddingInfoCell *cell = (BiddingInfoCell*)[tableView dequeueReusableCellWithIdentifier:biddingInfoCell forIndexPath:indexPath];
                    cell.LTLabel.text = goods.GoodsName;
                    cell.LSLabel.text = goods.startPrice;
                    cell.LThirstLabel.text = goods.maxMoney;//@"no data";
                    cell.LFourthLabel.text = goods.securityDeposit;
                    cell.RSLabel.text = goods.appendMoney;
                    cell.RThirstLabel.text = [NSString stringWithFormat:@"%ld",(long)goods.delayMinute];
                    if (goods.biddingStatus == 20) {
                        cell.LFifthLabel.text = @"已流拍";
                    }else if (goods.biddingStatus == 10){
                        cell.LFifthLabel.text = @"已成交";
                    }else{
                        cell.LFifthLabel.startTime = goods.startTime;
                        cell.LFifthLabel.endTime = goods.endTime;
                        [cell.LFifthLabel start];
                        isBegin = cell.LFifthLabel.status;
                    }
                    cell.collectState = [goods.IsCollect integerValue];
                    cell.Lfinished = ^(){
                        [self requestForCollect:YES];
                    };
                    cell.Rfinished = ^(){
                        if (![UserInfo shareUserInfo].isLogin) {
                            [Utities presentLoginVC:self];
                            return;
                        }
                        isCompare = NO;
                        [self requestForHistory];
                    };
                    if (cell.LFifthLabel.countDownTimer) {
                        [_timerArr addObject:cell.LFifthLabel.countDownTimer];
                    }
//                    NSLog(@",,,,%p,,,,,,%p",cell.LFifthLabel, cell.LFifthLabel.countDownTimer);
                    return cell;
                }else{
                    CollectCell *cell = (CollectCell*)[tableView dequeueReusableCellWithIdentifier:collectCell forIndexPath:indexPath];
                    cell.spread = YES;
                    NSNumber *colloct =goods.IsCollect;
                    NSLog(@"11 %@", colloct);
                    if (!colloct || [colloct isKindOfClass:[NSNull class]]) {
                        colloct = @(0);
                    }
                    cell.collectState = [colloct integerValue];
                    cell.topLab.text =goods.GoodsName;
                    cell.botLab.text = @"价格:";
                    cell.botRightLab.text = goods.typeForGoods ? @"洽谈" : [NSString stringWithFormat:@"￥%.2f",goods.AppendPrice];
                    cell.colloct = ^(BOOL collect11){
                        [self requestForCollect:collect11];
                    };
                    return cell;
                }
            }
        }
        case 1:{
            ArtInfoCell *cell = (ArtInfoCell*)[tableView dequeueReusableCellWithIdentifier:artInfoCell forIndexPath:indexPath];
            cell.left1Lab.text = goods.ArtName;
            NSNumber *state12 = goods.GoodsNum;
            cell.left2Lab.text = goods.CategoryName;
            cell.left3Lab.text = goods.LimitedSale;
            cell.left4Lab.text =  goods.GoodsCode;
            cell.R1Lab.text =  [state12 integerValue] ? @"待售" : @"已售";
            cell.R2Lab.text = goods.SpecDesc;
            return cell;
        }
        case 2:{
            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
            cell.titleLab.text = @"艺术家简介";
            if (goods.AuthorIntro && ![goods.AuthorIntro isKindOfClass:[NSNull class]]) {
                [cell.detailWebView loadHTMLString:goods.AuthorIntro baseURL:nil];
                [cell.detailWebView setScalesPageToFit:NO];
            }
            
            cell.spreadState = _spreadArtist;
            cell.reloadHeight = ^(BOOL spread, CGFloat height){
                _spreadArtist = spread;
                _heightArtist = height;
                [self reloadTableViewSection:indexPath.section spread:spread];
            };
            return cell;
        }
        case 3:{
            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
            cell.titleLab.text = @"作品简介";
            if (goods.GoodsIntro && ![goods.GoodsIntro isKindOfClass:[NSNull class]]) {
                [cell.detailWebView loadHTMLString:goods.GoodsIntro baseURL:nil];
                [cell.detailWebView setScalesPageToFit:NO];
            }
            cell.spreadState = _spreadArt;
            cell.reloadHeight = ^(BOOL spread, CGFloat height){
                _spreadArt = spread;
                _heightArt = height;
                [self reloadTableViewSection:indexPath.section spread:spread];
            };
            return cell;
        }
        case 4:{
            SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
            cell.titleLab.text = @"布罗德根艺术指数证书";
            if (goods.centificateIntro && ![goods.centificateIntro isKindOfClass:[NSNull class]]) {
                [cell.detailWebView loadHTMLString:goods.centificateIntro baseURL:nil];
                [cell.detailWebView setScalesPageToFit:NO];
            }
            cell.spreadState = _spreadCertification;
            cell.reloadHeight = ^(BOOL spread, CGFloat height){
                _spreadCertification = spread;
                _heightCertification = height;
                [self reloadTableViewSection:indexPath.section spread:spread];
            };
            return cell;
        }
        case 5:{
//            if (indexPath.row > 0) {
//                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
//                UILabel *label1 = (UILabel*)[cell viewWithTag:1];
//                label1.text = @"用户";
//                UILabel *label2 = (UILabel*)[cell viewWithTag:2];
//                label2.text = @"出价";
//                UILabel *label3 = (UILabel*)[cell viewWithTag:3];
//                label3.text = @"当前状态";
//                return cell;
//            }else{
                SpreadCell *cell = (SpreadCell*)[tableView dequeueReusableCellWithIdentifier:spreadCell forIndexPath:indexPath];
                cell.titleLab.text = @"出价历史";
                if (goods.bidHistory && ![goods.bidHistory isKindOfClass:[NSNull class]]) {
                    [cell.detailWebView loadHTMLString:goods.bidHistory baseURL:nil];
                }
                cell.spreadState = _spreadHistory;
                cell.reloadHeight = ^(BOOL spread, CGFloat height){
                    _spreadHistory = spread;
                    _heightHistory = height;
                    [self reloadTableViewSection:indexPath.section spread:spread];
                };
                return cell;
            }
//        }
        default:
        return nil;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//保证金加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"bidMoney"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO] forKey:@"AuctionCode" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO] forKey:@"GoodsCode" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"bidMoney"] aes:NO] forKey:@"bidMoney" atIndex:3];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:4];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:5];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}
//我要出价加密
-(MutableOrderedDictionary *)priceWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Price"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"type"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"AuctionCode"] aes:NO] forKey:@"AuctionCode" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"GoodsCode"] aes:NO] forKey:@"GoodsCode" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Price"] aes:YES] forKey:@"Price" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"type"] aes:NO] forKey:@"type" atIndex:4];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:5];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:6];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}


//添加购物车加密
-(MutableOrderedDictionary *)addWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"product_id"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"product_id"] aes:NO] forKey:@"product_id" atIndex:1];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:2];
    [orderArr insertObject:ARC4RANDOM_MAX  forKey:@"t" atIndex:3];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}


@end

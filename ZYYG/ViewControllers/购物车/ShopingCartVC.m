//
//  ShopingCartVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "ShopingCartVC.h"
#import "CartCell.h"
#import "ArtDetailVC.h"
#import "PayForArtVC.h"
#import "GoodsModel.h"
@interface ShopingCartVC()
<UITableViewDataSource, UITableViewDelegate>
{
    BOOL            _selectedButState;//底部选择按钮状态
    BOOL            _type;          //0  结算，   1删除
    NSInteger       _selectedAccount;//选中了几个
    NSMutableArray  *_shopCart;//购物车列表
    NSMutableDictionary  *_selectDict;//选中的row
    NSString        *selectProductID;//选中的，查看详情跳到详情页面
    CGFloat         totalPriceCount;
}

@property (weak, nonatomic) IBOutlet UITableView *cartTB;
@property (weak, nonatomic) IBOutlet UIButton *selectedGoodBut;//选中
@property (weak, nonatomic) IBOutlet UIButton *settleAccountBut;//结算
@property (weak, nonatomic) IBOutlet UILabel *priceLab;

@end
@implementation ShopingCartVC

static NSString *cartCell = @"CartCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.rightBarButtonItem
    _shopCart = [[NSMutableArray alloc] init];
    _selectDict = [[NSMutableDictionary alloc] init];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"删除" target:self action:@selector(doRightItem:)];
    self.cartTB.delegate = self;
    self.cartTB.dataSource = self;
    
    [self.cartTB registerNib:[UINib nibWithNibName:@"CartCell" bundle:nil] forCellReuseIdentifier:cartCell];
    _type = 0;
    [self restoreData];
    self.settleAccountBut.layer.cornerRadius = 2;
    [self addheadRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//不要频繁请求
//    if (![UserInfo shareUserInfo].cartsArr || ![UserInfo shareUserInfo].cartsArr.count) {
//        [self requestshopCart];
//    }else{
//        [_shopCart removeAllObjects];
//        [_shopCart addObjectsFromArray:[UserInfo shareUserInfo].cartsArr];
//        [self.cartTB reloadData];
//    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestshopCart];
}

- (void)doRightItem:(UIBarButtonItem*)item
{
    _type = !_type;
    [self restoreData];
}

//还原数据，viewdidAppear  导航栏右键 重新请求 都会触发此事件
- (void)restoreData
{
    _selectedAccount = 0;
    [_selectDict removeAllObjects];
    totalPriceCount = 0;
    [self changeType];
    [self settleButEnable:YES];
    [self changeSelectedGoodsButState:NO];
    [self.cartTB reloadData];
}

- (void)settleButEnable:(BOOL)enable
{
    if (_type) {
        enable = YES;
    }
    self.settleAccountBut.enabled = enable;
    self.settleAccountBut.layer.backgroundColor = enable ? kRedColor.CGColor : kLightGrayColor.CGColor;
}

- (void)changeType
{
    self.navigationItem.rightBarButtonItem.title = _type ? @"取消" : @"删除";
    self.priceLab.hidden = _type;
    [self.selectedGoodBut setTitle:(_type ? @"全选" : @"") forState:UIControlStateNormal];
    [self changeSettleAccount:NO price:0];
}
- (void)addheadRefresh
{
    [self.cartTB addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        [self requestshopCart];
    }];
}

- (void)requestCartFinised:(NSArray*)carts
{
    [[UserInfo shareUserInfo] parseCartArr:carts];
    [_shopCart removeAllObjects];
    [_shopCart addObjectsFromArray:[UserInfo shareUserInfo].cartsArr];
    [self restoreData];
    if (_shopCart.count == 0) {
        [self showAlertView:@"购物车中无商品"];
    }
}

- (void)doAlertViewTwo
{
    [Utities presentLoginVC:self];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.cartTB headerEndRefreshingWithResult:JHRefreshResultSuccess];
}
- (void)requestshopCart
{
    if (![[UserInfo shareUserInfo] isLogin]) {
//        [Utities presentLoginVC:self];
        [self showAlertViewTwoBut:@"温馨提示" message:@"请先登录或注册" actionTitle:@"确定"];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@ShoopCart.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self requestFinished];
        id result = [self parseResults:responseObject];
        if (result) {
            [self requestCartFinised:result[@"data"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestDeleteCart
{
    if (!_selectDict.count) {
        [self showAlertView:@"请选择"];
        return;
    }
    NSMutableString *productString = [NSMutableString string];
    NSArray *selectKey = [_selectDict allKeys];
    for (NSNumber *number in selectKey) {
         GoodsModel*model = _shopCart[[number integerValue]];
        if ([number isEqual:[selectKey lastObject]]) {
            [productString appendString:[NSString stringWithFormat:@"%@", model.GoodsCode]];
        }else{
            [productString appendString:[NSString stringWithFormat:@"%@,", model.GoodsCode]];
        }
    }
    NSLog(@"product string %@", productString);
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@DelCart.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",productString,@"product_id", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self requestFinished];
        id result = [self parseResults:responseObject];
        if (result) {
            [self requestFinishedDelete];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestFinishedDelete
{
    NSArray *selectKey = [_selectDict allKeys];
    NSMutableArray *selectArray = [NSMutableArray array];
    for (NSNumber *number in selectKey) {
        [selectArray addObject:(_shopCart[[number integerValue]])];
    }
    
    [_shopCart removeObjectsInArray:selectArray];
    [[UserInfo shareUserInfo].cartsArr removeObjectsInArray:selectArray];
    _selectedAccount = 0;
    [self changeSettleAccount:NO price:0];
    [_selectDict removeAllObjects];
    [self.cartTB reloadData];
}

- (void)changeSettleAccount:(BOOL)selected price:(CGFloat)price
{
    if (!selected) {
        _selectedAccount -= (_selectedAccount > 0 ? 1 : 0);
        totalPriceCount -= (totalPriceCount>0) ? price : 0;
    }else{
        _selectedAccount++;
        totalPriceCount += price;
    }
    NSString *title = (_type ? [NSString stringWithFormat:@"确认删除%ld", (long)_selectedAccount] : [NSString stringWithFormat:@"去结算%ld", (long)_selectedAccount]);
    [self.settleAccountBut setTitle:title forState:UIControlStateNormal];
    self.priceLab.text = [NSString stringWithFormat:@"￥ %.2f",totalPriceCount];
    
}

- (void)changeSelectedGoodsButState:(BOOL)selected
{
    UIImage *image = selected ? [UIImage imageNamed:@"frameSelected"] : [UIImage imageNamed:@"frameUnSelected"];
    [self.selectedGoodBut setImage:image forState:UIControlStateNormal];
    [self settleButEnable:YES];
}

- (IBAction)selectedGoodsButPressed:(id)sender
{
    _selectedButState = !_selectedButState;
    [self changeSelectedGoodsButState:_selectedButState];
    [_selectDict removeAllObjects];
    _selectedAccount = 0;
    totalPriceCount = 0;
    if (_selectedButState){
        for (int i = 0; i < _shopCart.count; i++) {
            GoodsModel *model = _shopCart[i];
            if (model.valid) {
                [_selectDict setObject:@(1) forKey:@(i)];
                ++_selectedAccount;
                totalPriceCount += model.AppendPrice;
            }
        }
        ++_selectedAccount;
    }
    [self changeSettleAccount:NO price:0];
    [self.cartTB reloadData];

}
- (IBAction)toSettleAccount:(id)sender {
    
    if (!_selectDict.count && !_type) {
        [self showAlertView:@"请选择"];
        return;
    }
    int i = 0;
    for (NSNumber *selected in [_selectDict allKeys]) {
        if ([_selectDict[selected] integerValue]) {
            i++;
        }
    }
    if (i==0) {
        [self showAlertView:@"请选择"];
        return;
    }
    if (_type) {
        [self requestDeleteCart];
        return;
    }
    [self performSegueWithIdentifier:@"ToPaySegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = segue.destinationViewController;
    destVC.hidesBottomBarWhenPushed = YES;
    if ([(PayForArtVC*)destVC respondsToSelector:@selector(setProducts:)]) {
        NSMutableArray* products = [NSMutableArray array];
        NSArray *keys = [_selectDict allKeys];
        for (NSNumber *number in keys) {
            [products addObject:_shopCart[[number integerValue]]];
        }
        [(PayForArtVC*)destVC setTotalPrice:totalPriceCount];
        [(PayForArtVC*)destVC setProducts:(NSArray*)products];
    }
}

- (void)presentDetailVC:(id)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
    if ([(ArtDetailVC*)detailVC respondsToSelector:@selector(setHiddenBottom:)]) {
        [detailVC setValue:@(1) forKey:@"hiddenBottom"];
    }
    if ([(ArtDetailVC*)detailVC respondsToSelector:@selector(setProductID:)]) {
        [detailVC setValue:selectProductID forKey:@"productID"];
    }
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (BOOL)selectAllList
{
    for (int i = 0; i < _shopCart.count; i++) {
        GoodsModel *model = _shopCart[i];
        if (!model.valid) {
            continue;
        }
        NSNumber *selected = _selectDict[@(i)];
        if (![selected integerValue]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _shopCart.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsModel *model = _shopCart[indexPath.row];
    CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:cartCell forIndexPath:indexPath];
    [cell.iconImage setImageWithURL:[NSURL URLWithString:model.picURL]];
    cell.LTLab.text = model.GoodsName;
    cell.RTLab.text = model.ArtName;
    cell.RSecondLab.text = model.GoodsCode;
    cell.RThirdLab.text = model.SpecDesc;
    cell.RBLab.text = [NSString stringWithFormat:@"￥%.2f", model.AppendPrice];
    cell.bottomLab.text = [NSString stringWithFormat:@"此艺术品已被%@人加入购物车", model.addCartCount];
    cell.selectState = [[_selectDict safeObjectForKey:@(indexPath.row)] integerValue];
    cell.cellType = NO;
    if (_type) {
        cell.valid = YES;
    }else{
        cell.valid = model.valid;
    }
    cell.doSelected = ^(NSIndexPath *cellIndexPath, BOOL selected){
        [_selectDict setObject:@(selected) forKey:@(indexPath.row)];
        [self changeSettleAccount:selected price:model.AppendPrice];
        _selectedButState = [self selectAllList];
        [self changeSelectedGoodsButState:_selectedButState];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsModel*model = _shopCart[indexPath.row];
    selectProductID = model.GoodsCode;
    [self presentDetailVC:nil];
    
}


@end

//
//  OrderListVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderListVC.h"
#import "OrderListCellTop.h"
#import "OrderListCellGoods.h"
#import "OrderListCellSum.h"
#import "OrderListCellBottom.h"
#import "HMSegmentedControl.h"
#import "UserInfo.h"
#import "GoodsModel.h"
#import "OrderDetailVC.h"
#import "PaaCreater.h"


@interface OrderListVC ()
{
    NSMutableArray *orderArray;
    UserInfo *user;
    OrderModel *currentOrder;
    NSString *orderState;
    NSInteger pageSize;
    NSInteger pageNum;
    NSDictionary  *_MerchantID;
    BOOL                refreshFooter;//是否是上拉刷新
    NSArray         *titles;//顶部titles
}
@property (retain, nonatomic) IBOutlet HMSegmentedControl *segmentView;
@end

@implementation OrderListVC

static NSString *orderTopCell = @"OrderListTopCell";
static NSString *orderGoodsCell = @"OrderListGoodsCell";
static NSString *orderSumCell = @"OrderListSumCell";
static NSString *orderBottomCell = @"OrderListBottomCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    if ([_orderType intValue] ==0) {
       self.title=@"平价订单";
    }else{
        self.title=@"竞价订单";
        
    }
    
    orderArray=[NSMutableArray array];
    [orderArray removeAllObjects];
    orderState=@""; // 20 :已支付,30:已发货,40:已签收,50:已取消,-1删除,10:审核,0:创建
    pageSize=5;
    pageNum=1;
    [self.orderListTabelView registerNib:[UINib nibWithNibName:orderTopCell bundle:nil] forCellReuseIdentifier:orderTopCell];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:orderGoodsCell bundle:nil] forCellReuseIdentifier:orderGoodsCell];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:orderSumCell bundle:nil] forCellReuseIdentifier:orderSumCell];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:orderBottomCell bundle:nil] forCellReuseIdentifier:orderBottomCell];
    
    self.segmentView.font = [UIFont fontWithName:@"Helvetica" size:14.0];
//    self.segmentView.sectionTitles = @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"];//  @"", @"0",@"20", @"30" ,@"40"
    self.segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [self requestOrderList:_orderType ordState:orderState ordSize:pageSize ordNum:pageNum];
    self.orderListTabelView.delegate = self;
    self.orderListTabelView.dataSource = self;
    [self addFootRefresh];
    [self getMerchantID];
    NSLog(@"交易订单");
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//上拉刷新
- (void)addFootRefresh
{
    
    [self.orderListTabelView addRefreshHeaderViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        refreshFooter = NO;
        pageNum = 1;
        [self requestOrderList:_orderType ordState:orderState ordSize:pageSize ordNum:pageNum];
    }];
    [self.orderListTabelView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageNum=pageNum+1;
        refreshFooter = YES;
        [self requestOrderList:_orderType ordState:orderState ordSize:pageSize ordNum:pageNum];
    }];
}
//状态标签按钮
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
   //  @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"]; @"", @"0",@"20", @"30" ,@"40"
    pageNum=1;
//    if (0==segmentedControl.selectedSegmentIndex) {
//        orderState=@"";
//    }else if(1==segmentedControl.selectedSegmentIndex) {
//        orderState=@"1";
//    }else if(2==segmentedControl.selectedSegmentIndex) {
//        orderState=@"2";
//    }else if(3==segmentedControl.selectedSegmentIndex) {
//        orderState=@"3";
//    }else if(4==segmentedControl.selectedSegmentIndex) {
//        orderState=@"4";
//    }else{
//        orderState=@"";
//    }
    [orderArray removeAllObjects];
    NSDictionary *d = titles[segmentedControl.selectedSegmentIndex];
    [self requestOrderList:_orderType ordState:d[@"Key"] ordSize:pageSize ordNum:1];

}
//订单列表请求

-(void)requestOrderList:(NSString *)ortype ordState:(NSString *)orstate ordSize:(NSInteger )size  ordNum:(NSInteger )num
{
    _orderType =ortype;
    orderState=orstate;
    pageSize=size;
    pageNum=num;
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@OrderList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",ortype, @"type",orstate, @"status",[NSString stringWithFormat:@"%ld",(long)size] , @"num", [NSString stringWithFormat:@"%ld",(long)num] , @"page" ,nil];
    NSLog(@"dict %@", dict);
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
//            NSLog(@"%@",result);
            NSMutableArray *orders=result[@"Orders"];
            if (!orders ||[orders isKindOfClass:[NSNull class]]|| orders.count<1) {
                [self showAlertView:@"无新订单!"];
            }else{
                if (!refreshFooter) {
                    [orderArray removeAllObjects];
                }
                for (int i=0; i<orders.count; i++) {
                    OrderModel *order=[OrderModel orderModelWithDict:orders[i]];
                    [orderArray addObject:order];
                }
            }
            titles = result[@"StatusDic"];
            NSMutableArray *sections = [NSMutableArray array];
            [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *d = (NSDictionary*)obj;
                [sections addObject:d[@"Value"]];
            }];
            self.segmentView.sectionTitles = sections;
            [self.segmentView setNeedsDisplay];
            [self.orderListTabelView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}
NSInteger soredArray2(id model1, id model2, void *context)
{
    NSDictionary *d1 = (NSDictionary*)model1;
    NSDictionary *d2 = (NSDictionary*)model2;
    return ([d2[@"Key"] integerValue] < [d1[@"Key"] integerValue]);
}

- (void)requestFinished
{
    refreshFooter = NO;
    [self dismissIndicatorView];
    [self.orderListTabelView footerEndRefreshing];
    [self.orderListTabelView headerEndRefreshingWithResult:JHRefreshResultSuccess];
}





#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return orderArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    OrderModel *order=orderArray[section];
    return 3+order.Goods.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return 1;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderModel *order=orderArray[indexPath.section];
    CGFloat hight=110;
    if(indexPath.row ==0){
        hight=32;
    }else if(indexPath.row == (order.Goods.count+1)){
        hight=32;
    }else if(indexPath.row == (order.Goods.count+2)){
        hight=120;
    }
    return hight;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderModel *order=orderArray[indexPath.section];
    if(indexPath.row ==0){
        OrderListCellTop   *topCell=(OrderListCellTop*)[tableView dequeueReusableCellWithIdentifier:orderTopCell forIndexPath:indexPath];
        topCell.orderNO.text=order.OrderCode;
        topCell.orderState.text=order.OrderStatus;
        topCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return topCell;
    }else if(indexPath.row == (order.Goods.count+1)){
        OrderListCellSum *sumCell=(OrderListCellSum*)[tableView dequeueReusableCellWithIdentifier:orderSumCell forIndexPath:indexPath];
        sumCell.goodsSum.text =[NSString stringWithFormat:@"(%lu)",(unsigned long)order.Goods.count];
        if ([_orderType intValue] ==0) {
        sumCell.priceSum.text=[NSString stringWithFormat:@"￥%@",order.OrderMoney];
         }else{
             sumCell.priceSum.text=[NSString stringWithFormat:@"￥%@",order.PayMoney];
         }
        sumCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return sumCell;
    }else if(indexPath.row == (order.Goods.count+2)){
        OrderListCellBottom *bottomCell=(OrderListCellBottom*)[tableView dequeueReusableCellWithIdentifier:orderBottomCell forIndexPath:indexPath];
        
        bottomCell.cancelTime.text=[NSString stringWithFormat:@"订单生成时间:%@",order.CreateTime];
        bottomCell.redLabel.numberOfLines=0;
        [self setButton:bottomCell orderMod:order];
        bottomCell.order=order;
        bottomCell.orderlistVc=self;
        bottomCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return bottomCell;
    }else {
        GoodsModel *goods=order.Goods[indexPath.row-1];
        OrderListCellGoods   *goodsCell=(OrderListCellGoods*)[tableView dequeueReusableCellWithIdentifier:orderGoodsCell forIndexPath:indexPath];
        [goodsCell.goodsImage setImageWithURL:[NSURL URLWithString:goods.defaultImageUrl] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
        goodsCell.goodsName.text=goods.GoodsName;
        goodsCell.goodsPrice.text=[NSString stringWithFormat:@"￥%.2f" ,goods.AppendPrice];
        goodsCell.goodsCount.text=@"1";
        if ([_orderType intValue] ==0) {
            goodsCell.marginLab.hidden=YES;
            goodsCell.marginPrice.hidden=YES;
        }else{
            goodsCell.marginLab.hidden=NO;
            goodsCell.marginPrice.hidden=NO;
            goodsCell.marginLab.text=@"尾款:";
            goodsCell.marginPrice.text=[NSString stringWithFormat:@"%@(已扣除保证金)(%@)" ,order.PayMoney,order.PaidMoney];
            
        }
        return goodsCell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentOrder=orderArray[indexPath.section];
    if (indexPath.row != 0  && indexPath.row != currentOrder.Goods.count+2) {
        [self performSegueWithIdentifier:@"OrderDetail" sender:self];
    }
}
//跳转详情
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"查看订单详细");
    if(currentOrder){
        NSString *orderCode=currentOrder.OrderCode;
        UIViewController *detailVC = segue.destinationViewController;
        detailVC.hidesBottomBarWhenPushed = YES;
        if ([detailVC isKindOfClass:[OrderDetailVC class]]) {
            OrderDetailVC *vc = (OrderDetailVC*)detailVC;
            [vc setOrderCode:orderCode];
            
            if ([_orderType intValue] ==0) {
                [vc setOrderType:0];
            }else{
                [vc setOrderType:2];
            }
        }
    }else{
        NSLog(@"选择某一行");
    }
}
//判断状态 给出按钮
-(void)setButton:(OrderListCellBottom *)bottomCell orderMod:(OrderModel *)ord
{
    bottomCell.canStar.hidden=NO;
    bottomCell.labStar.hidden=NO;
    bottomCell.cancellButton.hidden=YES;
    bottomCell.payButton.hidden=YES;
    bottomCell.redLabel.text=@"";
    if (0 == ord.state || 10 == ord.state) {
        //创建状态 可支付  可取消
        if ([_orderType intValue] ==0 ) {
            
            bottomCell.redLabel.text=[NSString stringWithFormat:@"提醒:请您在%@分钟内完成支付,否则订单将自动取消",ord.TimeSpan];
        }else{
            bottomCell.redLabel.text=[NSString stringWithFormat:@"提醒:请您在%@小时内完成支付,否则订单将自动取消,并扣除您的保证金!",ord.TimeSpan];
        }
        bottomCell.cancellButton.hidden=NO;
        bottomCell.payButton.hidden=NO;
        //创建状态 可支付  可取消
    }else if(20 ==ord.state){
        bottomCell.redLabel.text=@"已成功支付";
    }else if(30 == ord.state){
        bottomCell.redLabel.text=@"恭喜您已经购买到了此艺术品!艺术品已经发往您填写的接收地址!如果有疑问可以查看物流信息或者联系我们!";
        bottomCell.payButton.hidden=NO;
        [bottomCell.payButton setTitle:@"确认收货" forState:UIControlStateNormal];
    }else if(50 == ord.state){
        if ([_orderType intValue] ==0) {
            bottomCell.redLabel.text=@"该订单已经被取消无法继续操作,而且您已经丢失本次购买此商品的机会!";
        }else{
            bottomCell.redLabel.text=@"该订单已经被取消无法继续操作,而且您已经丢失本次购买此商品的机会!已经扣除了您的保证金!";
        }
        bottomCell.canStar.hidden=NO;
        bottomCell.labStar.hidden=NO;
        bottomCell.cancellButton.hidden=YES;
        bottomCell.payButton.hidden=YES;
    }else {
       
    }
    
}
//取消订单
-(void)cancellOrder:(OrderModel *)order
{
    if (0 == order.state || 10 == order.state) {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@DeleteOrder.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",order.OrderCode, @"order_id"  ,nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSLog(@"%@",result);
            [orderArray removeAllObjects];
            [self requestOrderList:_orderType ordState:orderState ordSize:5 ordNum:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertView:[NSString stringWithFormat:@"取消订单出错! %@",error]];
    }];
    }else {
      NSLog(@"错误操作错误操作");
    }


}
//支付
-(void)payOrder:(OrderModel *)order
{   //创建状态 可支付  可取消
    if (0 == order.state || 10 == order.state) {
        if ([self.orderType intValue]) {
            currentOrder = order;
            [self performSegueWithIdentifier:@"OrderDetail" sender:self];
        }else{
            NSMutableString *names = [NSMutableString string];
            for (GoodsModel *name in order.Goods) {
                [names appendString:[NSString stringWithFormat:@"%@,",name.GoodsName]];
            }
            NSString *string = [NSString stringWithFormat:@"%ld", (long)([order.OrderMoney floatValue]*100)];
            [APay startPay:[PaaCreater createrWithOrderNo:order.OrderCode productName:names money:string type:1 shopNum:_MerchantID[@"MerchantID"] key:_MerchantID[@"PayKey"] time:order.CreateTime] viewController:self delegate:self mode:kPayMode];
        }
    }else if(30 == order.state){
        NSLog(@"确认收货确认收货确认收货");
        [self requestForConfirmGoods:order.OrderCode];
    }else {
        NSLog(@"错误操作错误操作");
    }

}

- (void)requestForConfirmGoods:(NSString*)orderCode
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@OrderSigning.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.userKey, @"key",orderCode,@"OrderCode", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSString *message = [@"0" isEqual:result[@"errno"]] ? @"确认收货成功!" : @"确认收货失败!";
            [self showAlertView:message];
            [self requestOrderList:_orderType ordState:orderState ordSize:pageSize ordNum:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)getMerchantID {
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@GetUserInfo.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        NSLog(@"aes de %@", aesde);
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            if(![result[@"errno"] integerValue]){
                _MerchantID=result;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
    
}


#pragma mark - payDelegate
- (void)APayResult:(NSString*)result
{
    NSLog(@"%@",result);
    [self showAlertView:[Utities doWithPayList:result]];
    [orderArray removeAllObjects];
    [self requestOrderList:_orderType ordState:orderState ordSize:pageSize ordNum:1];
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

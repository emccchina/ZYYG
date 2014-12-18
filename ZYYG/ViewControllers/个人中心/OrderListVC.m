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
#import "OrderModel.h"
#import "UserInfo.h"
#import "GoodsModel.h"
#import "OrderDetailVC.h"

@interface OrderListVC ()
{
    NSMutableArray *orderArray;
    UserInfo *user;
    OrderModel *currentOrder;
    NSString *orderType;
    NSString *orderState;
    NSInteger pageSize;
    NSInteger pageNum;
    
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
    orderArray=[NSMutableArray array];
    [orderArray removeAllObjects];
    orderType =@"0"; //平价订单
    orderState=@""; // 20 :已支付,30:已发货,40:已签收,50:已取消,-1删除,10:审核,0:创建
    pageSize=5;
    pageNum=1;
    [self requestOrderList:orderType ordState:orderState ordSize:pageSize ordNum:pageNum];
    
    self.orderListTabelView.delegate = self;
    self.orderListTabelView.dataSource = self;
    
    self.segmentView.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.segmentView.sectionTitles = @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"];//  @"", @"0",@"20", @"30" ,@"40"
    self.segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [self addFootRefresh];
    NSLog(@"交易订单");
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFootRefresh
{
    [orderArray removeAllObjects];
    [self.orderListTabelView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
       NSInteger newSize=((pageNum+1)*pageSize);
        [self requestOrderList:orderType ordState:orderState ordSize:newSize ordNum:pageNum];
    }];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [orderArray removeAllObjects];
   //  @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"]; @"", @"0",@"20", @"30" ,@"40"
    pageNum=0;
    if (0==segmentedControl.selectedSegmentIndex) {
        orderState=@"";
    }else if(1==segmentedControl.selectedSegmentIndex) {
        orderState=@"0";
    }else if(2==segmentedControl.selectedSegmentIndex) {
        orderState=@"20";
    }else if(3==segmentedControl.selectedSegmentIndex) {
        orderState=@"30";
    }else if(4==segmentedControl.selectedSegmentIndex) {
        orderState=@"40";
    }else{
        orderState=@"";
    }
    [self requestOrderList:orderType ordState:orderState ordSize:pageSize ordNum:pageNum];

}



//key
//status
//type
//num
//page

-(void)requestOrderList:(NSString *)ortype ordState:(NSString *)orstate ordSize:(NSInteger )size  ordNum:(NSInteger )num
{
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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",ortype, @"type",orstate, @"status",[NSString stringWithFormat:@"%d",size] , @"num", [NSString stringWithFormat:@"%d",num] , @"page" ,nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSLog(@"%@",result);
            NSArray *orders=result[@"Orders"];
            if (!orders ||orders.count<1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"无该状态订单!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }
            for (int i=0; i<orders.count; i++) {
                OrderModel *order=[OrderModel orderModelWithDict:orders[i]];
                NSLog(@"订单读取成功");
                [orderArray addObject:order];
            }
            [self.orderListTabelView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.orderListTabelView footerEndRefreshing];

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
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderModel *order=orderArray[indexPath.section];
    CGFloat hight=100;
    if(indexPath.row ==0){
        hight=35;
    }else if(indexPath.row == (order.Goods.count+1)){
        hight=25;
    }else if(indexPath.row == (order.Goods.count+2)){
        hight=110;
    }
    return hight;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderModel *order=orderArray[indexPath.section];
    if(indexPath.row ==0){
        OrderListCellTop   *topCell=(OrderListCellTop*)[tableView dequeueReusableCellWithIdentifier:orderTopCell forIndexPath:indexPath];
        topCell.orderNO.text=order.OrderCode;
        topCell.orderType.text=order.OrderType;
        topCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return topCell;
    }else if(indexPath.row == (order.Goods.count+1)){
        OrderListCellSum *sumCell=(OrderListCellSum*)[tableView dequeueReusableCellWithIdentifier:orderSumCell forIndexPath:indexPath];
        sumCell.goodsSum.text =[NSString stringWithFormat:@"共计(%lu)商品",(unsigned long)order.Goods.count];
        sumCell.priceSum.text=[NSString stringWithFormat:@"实付:￥%@",order.OrderMoney];
        sumCell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        return sumCell;
    }else if(indexPath.row == (order.Goods.count+2)){
        OrderListCellBottom *bootomCell=(OrderListCellBottom*)[tableView dequeueReusableCellWithIdentifier:orderBottomCell forIndexPath:indexPath];
        bootomCell.cancelTime.text=order.CreateTime;
        bootomCell.selectionStyle=UITableViewCellSelectionStyleNone;
        return bootomCell;
    }else {
        GoodsModel *goods=order.Goods[indexPath.row-1];
        OrderListCellGoods   *goodsCell=(OrderListCellGoods*)[tableView dequeueReusableCellWithIdentifier:orderGoodsCell forIndexPath:indexPath];
        [goodsCell.goodsImage setImageWithURL:[NSURL URLWithString:goods.defaultImageUrl]];
        goodsCell.goodsName.text=goods.GoodsName;
        goodsCell.goodsCount.text=@"1";
        goodsCell.goodsPrice.text=[NSString stringWithFormat:@"%.2f" ,goods.AppendPrice];
        
        return goodsCell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    currentOrder=orderArray[indexPath.section];
    if (indexPath.row != 0 && indexPath.row != currentOrder.Goods.count+1 && indexPath.row != currentOrder.Goods.count+2) {
        [self performSegueWithIdentifier:@"OrderDetail" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"查看订单详细");
    if(currentOrder){
        NSString *orderCode=currentOrder.OrderCode;
        UIViewController *vc = segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
        if ([(OrderDetailVC*)vc respondsToSelector:@selector(setOrderCode:)]) {
            [vc setValue:orderCode forKey:@"orderCode"];
        }
    }else{
        NSLog(@"选择某一行");
    }
    
    
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

//
//  OrderDetailVC.m
//  ZYYG
//
//  Created by champagne on 14-12-4.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderDetailVC.h"
#import "OrderListCellGoods.h"
#import "GoodsModel.h"
#import "AdressModel.h"
#import "OrderModel.h"
#import "InvoiceModel.h"
#import "ArtDetailVC.h"
#import "CartCell.h"
#import "OrderDetailCell.h"
#import "PaaCreater.h"
#import "ClassifyModel.h"
#import "CartCell.h"
#import "ChooseVC.h"
#import "InvoiceVC.h"
#import "AdressVC.h"
#import "OrderSubmitModel.h"
#import "RequestManager.h"
@interface OrderDetailVC ()
<APayDelegate>
{
    UserInfo *user;
    OrderModel *order;
    AdressModel *addr;
    InvoiceModel *invoice;
    NSDictionary  *_MerchantID;
    OrderSubmitModel        *_orderModel;//
    BOOL          submit;//是否是可以提交订单的地址 配送这些东西，竞价中使用
    NSDictionary *_resultDict;
    BOOL            isBack;
}
@end

@implementation OrderDetailVC

static NSString *topCell = @"topCell";
static NSString *nomalCell = @"nomalCell";
static NSString *adressCell = @"AdressCell";
static NSString *ticketCell = @"TicketCell";
static NSString *cartCell = @"CartCell";
static NSString *ODCell = @"OrderDetailCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    addr=[[AdressModel alloc] init];
    [self.orderDetailTableView registerNib:[UINib nibWithNibName:@"CartCell" bundle:nil] forCellReuseIdentifier:cartCell];
    [self.orderDetailTableView registerNib:[UINib nibWithNibName:ODCell bundle:nil] forCellReuseIdentifier:ODCell];
    
    // Do any additional setup after loading the view.
    [self showBackItem];
    _orderModel = [[OrderSubmitModel alloc] init];
    self.confirmDelivery.layer.backgroundColor = kRedColor.CGColor;
    self.confirmDelivery.layer.cornerRadius = 3;
    self.confirmDelivery.hidden=YES;
    
    self.checkDelivery.layer.backgroundColor = kRedColor.CGColor;
    self.checkDelivery.layer.cornerRadius = 3;
    self.checkDelivery.hidden=YES;
    
    [self getMerchantID];
    
    if (![UserInfo shareUserInfo].addressManager && self.orderType == 2) {
        [self requestForAddressList];
    }else{
        [self requestLetterList:self.orderCode];
        if ([UserInfo shareUserInfo].addressManager) {
            [UserInfo shareUserInfo].addressManager.defaultAddressIndex = -1;
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.orderDetailTableView reloadData];
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

- (void)requestForAddressList
{
    [RequestManager requestForAddressListInManager:^(BOOL success) {
        [self dismissIndicatorView];
        if (success) {
            [UserInfo shareUserInfo].addressManager.defaultAddressIndex = -1;
            NSLog(@"success for list");
            [self.orderDetailTableView reloadData];
            [self requestLetterList:self.orderCode];
        }else{
            [self showAlertView:kNetworkNotConnect];
        }
        
    }];
}

- (void)setProductsIDForGoods:(NSArray*)goods
{
    if (!goods && goods.count <= 0) {
        return;
    }
    NSMutableString *productIDs = [NSMutableString string];
    for (GoodsModel *model in goods) {
        if ([model isEqual:[goods lastObject]]) {
            [productIDs appendString:[NSString stringWithFormat:@"%@", model.GoodsCode]];
        }else{
            [productIDs appendString:[NSString stringWithFormat:@"%@,", model.GoodsCode]];
        }
    }
    [_orderModel setProductIDs:productIDs];
}

-(void)requestLetterList:(NSString *)orderCode
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@OrderDetail.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",orderCode,@"OrderCode", nil];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSString *aesResult = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        NSLog(@"%@", aesResult);
        self.orderDetailTableView.delegate = self;
        self.orderDetailTableView.dataSource = self;
        id result = [self parseResults:[aesResult dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [addr addressFromOrder:result[@"Addr"]];
            _orderModel.invoiceInfo = result[@"Invoice"];
            order = [OrderModel orderModelWithDict:result];
            [self setProductsIDForGoods:order.Goods];
            ClassifyModel *delivery = [[ClassifyModel alloc] init];
            [delivery deliveryFromDict:result[@"Delivery"]];
            _orderModel.delivery = delivery;
            ClassifyModel * package = [[ClassifyModel alloc] init];
            [package packingFromDict:result[@"Packing"]];
            _orderModel.packing = package;
            [self setButton:order];
            NSLog(@"订单商品解析完成");
            [self.orderDetailTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
}

- (void)requestSubmitOrder
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    if (!userInfo.addressManager || userInfo.addressManager.defaultAddressIndex < 0) {
        [self showAlertView:@"请输入地址!"];
        return;
    }
    if(!_orderModel.delivery){
        [self showAlertView:@"请选择配送方式!"];
        return;
    }
    if(!_orderModel.packing){
        [self showAlertView:@"请选择包装方式!"];
        return;
    }
    if (!_orderModel.invoiceInfo) {
        [self showAlertView:@"请选择发票方式"];
        return;
    }
     _orderModel.orderCode=order.OrderCode;
    [_orderModel setAddressID:userInfo.addressManager.defaultAddressCode];
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@UpdateOrder.ashx",kServerDomain];
    NSLog(@"url %@", url);
    MutableOrderedDictionary* rdict = [_orderModel updatedictWithAES];
    [manager POST:url parameters:rdict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"result %@", result);
        if (result) {
            _resultDict = result;
            [self showAlertViewTwoBut:@"提交成功" message:[NSString stringWithFormat:@"订单号:%@\n应付总额:%@",_resultDict[@"OrderCode"], _resultDict[@"PayMoney"]] actionTitle:@"支付"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}


-(void)setButton:(OrderModel *)ord
{
    submit = NO;
    //订单状态 20 支付 30已发货 40已签收 50已取消 -1删除 10审核 0创建
    if (!self.orderType) {
        self.orderMoney.text=[NSString stringWithFormat:@"￥%@",ord.PayMoney];
    }else{
        CGFloat price = 0;
        for (GoodsModel *model in order.Goods) {
            price += model.AppendPrice;
        }
        price -= [order.PaidMoney floatValue];
        _orderModel.totalPrice = price;
        [_orderModel calculatePrice];
        self.orderMoney.text = [NSString stringWithFormat:@"%.2f", _orderModel.dealPrice];
    }
    if (0 == ord.state || 10 == ord.state) {
        //创建状态 可支付  可取消
        submit = self.orderType ? YES : NO;
        self.checkDelivery.hidden= !self.orderType;
        [self.checkDelivery setTitle:@"取消订单" forState:UIControlStateNormal];
        self.confirmDelivery.hidden=!self.orderType;
//        if(submit){
//        [self.confirmDelivery setTitle:@"确认订单" forState:UIControlStateNormal];
//        }else{
//            [self.confirmDelivery setTitle:@"支付订单" forState:UIControlStateNormal];
//        }
    }else if(30 == ord.state){
        self.confirmDelivery.hidden=YES;
        self.checkDelivery.hidden=NO;
        [self.checkDelivery setTitle:@"确认收货" forState:UIControlStateNormal];
    }else {
        self.confirmDelivery.hidden=YES;
        self.checkDelivery.hidden=YES;
    }
}
- (void)doAlertView
{
    if (!isBack) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doAlertViewTwo
{
    CGFloat money = [_resultDict[@"PayMoney"] floatValue];
    NSString *meneyString = [NSString stringWithFormat:@"%ld",(long)(money*100)];//换成分
    NSMutableString *names = [NSMutableString string];
    for (GoodsModel *name in order.Goods) {
        [names appendString:[NSString stringWithFormat:@"%@,",name.GoodsName]];
    }
    [APay startPay:[PaaCreater createrWithOrderNo:_resultDict[@"OrderCode"] productName:names money:meneyString type:1 shopNum:_MerchantID[@"MerchantID"] key:_MerchantID[@"PayKey"] time:_resultDict[@"CreateTime"]] viewController:self delegate:self mode:kPayMode];
}
- (void)APayResult:(NSString *)result
{
    NSLog(@"%@",result);
    isBack = YES;
    [self showAlertView:[Utities doWithPayList:result]];

}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)        return order.Goods.count+2;
    else if(section ==6)     return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
            return 100;
            break;
        case 2:
            return indexPath.row == 0 ? 44 : 125;
            break;
        case 6:
            return indexPath.row ? 100 : 44;
            break;
        default:
            return 44;
            break;
            
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.5;
            break;
        default:
            return 5;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:{
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:topCell];
            cell.textLabel.text=order.OrderStatus;
            cell.detailTextLabel.text=order.OrderCode;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;

        }case 1:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:adressCell forIndexPath:indexPath];
            UIView *viewBG = [cell viewWithTag:1];
            viewBG.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:175.0/255.0 alpha:1.0].CGColor;
            viewBG.layer.borderWidth = 10;
            UILabel *topLabel = (UILabel*)[cell viewWithTag:2];
            UILabel *bottomLabel = (UILabel*)[cell viewWithTag:3];
            if (!submit) {
                topLabel.text =[NSString stringWithFormat:@"%@   %@",addr.name,addr.mobile];
                bottomLabel.text = addr.defaultAdress;
            }else{
                UserInfo* userInfo = [UserInfo shareUserInfo];
                AddressManager *manager = [userInfo addressManager];
                NSString *textTop = @"请添加地址";
                NSString *textBut = @"";
                if (manager && manager.defaultAddressIndex < manager.addresses.count && manager.defaultAddressIndex > -1 ) {
                    AdressModel *model = manager.addresses[manager.defaultAddressIndex];
                    textTop = [NSString stringWithFormat:@"%@  %@", model.name, model.mobile];
                    textBut = [NSString stringWithFormat:@"%@%@%@%@", model.provinceName, model.cityName, model.townName, model.detailAdress];
                }
                topLabel.text = textTop;
                bottomLabel.text = textBut;
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }case 2:{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
                cell.textLabel.text = @"商品清单";
                cell.detailTextLabel.text = order.OrderType;
                cell.accessoryType =  UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else if(indexPath.row == (order.Goods.count+1)){
                OrderDetailCell *orCell=(OrderDetailCell*)[tableView dequeueReusableCellWithIdentifier:ODCell forIndexPath:indexPath];
                orCell.createTime.text=order.CreateTime;
                orCell.redLab.numberOfLines=0;
                if (0 == order.state || 10 == order.state) {
                    //创建状态 可支付  可取消
                    if(self.orderType ==0){
                        orCell.redLab.text=@"提醒:请您在自订单生成后的45分钟内进行付款!否则本次交易订单会自动取消!";
                    }else{
                        orCell.redLab.text=@"提醒:请您在自订单生成后的72小时内进行付款!否则本次交易订单会自动取消!并会扣除您的保证金!";
                    }
                }else if(20 ==order.state){
                    orCell.redLab.text=@"恭喜您已经购买到了此艺术品!我们会尽快为你装配并发货!";
                }else if(30 == order.state){
                    orCell.redLab.text=@"恭喜您已经购买到了此艺术品!艺术品已经发往您填写的接收地址!如果有疑问可以查看物流信息或者联系我们!";
                }else if(50 == order.state){
                    if (self.orderType ==0) {
                        orCell.redLab.text=@"该订单已经被取消无法继续操作,而且您已经丢失本次购买此商品的机会!";
                    }else{
                        orCell.redLab.text=@"该订单已经被取消无法继续操作,而且您已经丢失本次购买此商品的机会!已经扣除了您的保证金!";
                    }
                }else {
                    
                }
                return orCell;

            }else{
                GoodsModel *model=order.Goods[indexPath.row -1];
                CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:cartCell forIndexPath:indexPath];
                [cell.iconImage setImageWithURL:[NSURL URLWithString:model.defaultImageUrl] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
                cell.LTLab.text = model.GoodsName;
                cell.RTLab.text = model.ArtName;
                cell.RSecondLab.text = model.GoodsCode;
                cell.RThirdLab.text = model.SpecDesc;
                cell.RBLab.text = [NSString stringWithFormat:@"￥%.2f", model.AppendPrice];
                cell.cellType = YES;
                return cell;
            }
         }
            break;
        case 3:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            NSString *title = @"";
            NSString *detail = @"";
            title = @"在线支付";
            detail = @"在线支付";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 4:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            cell.textLabel.text = @"配送方式";
            cell.detailTextLabel.text = _orderModel.delivery.name;
            cell.selectionStyle = submit ? UITableViewCellSelectionStyleGray :UITableViewCellSelectionStyleNone;
            cell.accessoryType = submit ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 5:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            cell.textLabel.text = @"包装方式";
            cell.detailTextLabel.text = _orderModel.packing.name;
            cell.selectionStyle = submit ? UITableViewCellSelectionStyleGray :UITableViewCellSelectionStyleNone;
            cell.accessoryType = submit ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 6:{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
                cell.textLabel.text = @"发票信息";
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ticketCell forIndexPath:indexPath];
                UILabel *topLabel = (UILabel*)[cell viewWithTag:1];
                UILabel *midLabel = (UILabel*)[cell viewWithTag:2];
                UILabel *botLabel = (UILabel*)[cell viewWithTag:3];
                NSArray *invoiceType = @[@"不开发票",@"普通发票"];
                NSString *ticketsTitle = @"";
                if (_orderModel.invoiceInfo) {
                    ticketsTitle = invoiceType[[_orderModel.invoiceInfo[@"InvoiceType"] integerValue]/10];
                }
                topLabel.text = [NSString stringWithFormat:@"发票类型:%@", ticketsTitle];
                midLabel.text = [NSString stringWithFormat:@"发票抬头:%@",(_orderModel.invoiceInfo[@"InvoiceTitle"] ?:@"")];
                botLabel.text = @"";
                cell.selectionStyle = submit ? UITableViewCellSelectionStyleGray :UITableViewCellSelectionStyleNone;
                cell.accessoryType = submit ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
                return cell;
            }
            break;
            
        }
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==2 && indexPath.row!=0 && indexPath.row != (order.Goods.count+1)) {
        GoodsModel *goods=order.Goods[indexPath.row-1];
        [self presentDetailVC:goods];
    }
    if (!submit) {
        return;
    }
    switch (indexPath.section) {
        case 1:{//地址
            [self presentInfoVC:@"AdressVC" type:-1];
        }
            break;
        case 4://配送
            [self presentInfoVC:@"ChooseVC" type:2];
            break;
        case 5:{//包装
            [self presentInfoVC:@"ChooseVC" type:3];
        }break;
        case 6:{//发票信息
            [self presentInfoVC:@"InvoiceVC" type:-1];
        }break;
        
        default:
            break;
    }
   
}

- (void)chooseFinished:(NSInteger)type content:(id) content
{
    ClassifyModel *sendContent = content;
    switch (type) {
        case 0:{
            
        }
            break;
        case 1:{
        }break;
        case 2:{
            _orderModel.delivery = sendContent;
//            _orderModel.delivPrice=[sendContent.price floatValue];
            [_orderModel calculatePrice];
            self.orderMoney.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderDetailTableView reloadData];
        }break;
        case 3:{
            _orderModel.packing = sendContent;
//            _orderModel.packPrice=[sendContent.price floatValue];
            [_orderModel calculatePrice];
            self.orderMoney.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderDetailTableView reloadData];
        }break;
        default:
            break;
    }
}

- (void)presentInfoVC:(NSString*)segue type:(NSInteger)type
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShopCartStoryboard" bundle:nil];
    UIViewController* destVC = [storyboard instantiateViewControllerWithIdentifier:segue];
    [self.navigationController pushViewController:destVC animated:YES];
    if ([destVC isKindOfClass:[ChooseVC class]]) {
        [(ChooseVC*)destVC setTypeChoose:type];
        [(ChooseVC*)destVC setChooseFinished:^(NSInteger type,id conente){
            NSLog(@"choose type %ld,%@", (long)type, conente);
            [self chooseFinished:type content:conente];
        }];
    }else if ([destVC isKindOfClass:[AdressVC class]]){
        [(AdressVC*)destVC setChange:^(BOOL change){
            if (addr) {
                addr.isExist = NO;
            }
        }];
    }else if ([destVC isKindOfClass:[InvoiceVC class]]){
        [(InvoiceVC*)destVC setFinished:^(NSDictionary* invoiceD){
            _orderModel.invoiceInfo = [NSDictionary dictionaryWithDictionary:invoiceD];
            [_orderModel calculatePrice];
            self.orderMoney.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderDetailTableView reloadData];
        }];
    }
    
}

- (void)presentDetailVC:(id)info
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FairPriceStoryboard" bundle:nil];
    UIViewController* detailVC = [storyboard instantiateViewControllerWithIdentifier:@"ArtDetailVC"];
    
    if ([detailVC isKindOfClass:[ArtDetailVC class]]) {
        ArtDetailVC *vc = (ArtDetailVC*)detailVC;
        [vc setHiddenBottom:YES];
        [vc setProductID:((GoodsModel *)info).GoodsCode];
        [vc setAuctionCode:((GoodsModel *)info).auctionCode];
        [vc setType:self.orderType];
    }
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)requestForConfirmGoods:(NSString*)orderCode
{
    [self showIndicatorView:kNetworkConnecting];
    UserInfo *userInfo = [UserInfo shareUserInfo];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@OrderSigning.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.userKey, @"key",orderCode,@"OrderCode", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        [self dismissIndicatorView];
        if (result) {
            NSString *message = [@"0" isEqual:result[@"errno"]] ? @"确认收货成功!" : @"确认收货失败!";
            [self showAlertView:message];
            [self requestLetterList:self.orderCode];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (IBAction)payOrder:(id)sender {
    //创建状态 可支付  可取消
    if (0 == order.state || 10 == order.state) {
        [self requestSubmitOrder];
    }else if(30 == order.state){
        NSLog(@"确认收货确认收货确认收货");
        [self requestForConfirmGoods:self.orderCode];
    }else {
        NSLog(@"错误操作错误操作");
    }

}

- (IBAction)cancelOrder:(id)sender {
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
                [self requestLetterList:self.orderCode];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showAlertView:[NSString stringWithFormat:@"取消订单出错! %@",error]];
        }];
    }else {
        [self requestForConfirmGoods:self.orderCode];
        NSLog(@"错误操作错误操作");
    }

}

- (void)getMerchantID {
//    [self showIndicatorView:kNetworkConnecting];
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
@end

//
//  PayForArtVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PayForArtVC.h"
#import "CartCell.h"
#import "ChooseVC.h"
#import "AdressVC.h"
#import "AdressModel.h"
#import "GoodsModel.h"
#import "InvoiceVC.h"
#import "PaaCreater.h"
#import "OrderedDictionary.h"
#import "ClassifyModel.h"
#import "OrderSubmitModel.h"


@interface PayForArtVC ()
<UITableViewDataSource, UITableViewDelegate, APayDelegate>
{
    NSInteger       _toPresentType;//转场页面标志  1 支付， 2 配送 3 包装
    OrderSubmitModel        *_orderModel;
    NSDictionary            *_resultDict;
    NSDictionary            *_MerchantID;
    BOOL                    isBack;
}
@property (weak, nonatomic) IBOutlet UITableView *orderTB;
@property (weak, nonatomic) IBOutlet UIButton *submitBut;
@property (weak, nonatomic) IBOutlet UILabel *countPayLab;
@end

@implementation PayForArtVC

static NSString *nomalCell = @"nomalCell";
static NSString *adressCell = @"AdressCell";
static NSString *ticketCell = @"TicketCell";
static NSString *cartCell = @"CartCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    [self.orderTB registerNib:[UINib nibWithNibName:@"CartCell" bundle:nil] forCellReuseIdentifier:cartCell];
    isBack = NO;

    self.submitBut.layer.cornerRadius = 3;
    self.submitBut.layer.backgroundColor = kRedColor.CGColor;
    self.orderTB.delegate = self;
    self.orderTB.dataSource = self;

    self.countPayLab.text = [NSString stringWithFormat:@"￥%.2f", self.totalPrice];
    _orderModel = [[OrderSubmitModel alloc] init];
    _orderModel.totalPrice = self.totalPrice;
    NSMutableString *productIDs = [NSMutableString string];
    for (GoodsModel *model in self.products) {
        if ([model isEqual:[self.products lastObject]]) {
            [productIDs appendString:[NSString stringWithFormat:@"%@", model.GoodsCode]];
        }else{
            [productIDs appendString:[NSString stringWithFormat:@"%@,", model.GoodsCode]];
        }
    }
    [self getMerchantID];
    _orderModel.productIDs = productIDs;
    if (![UserInfo shareUserInfo].addressManager) {
        [self requestForAddressList];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.orderTB reloadData];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)presentChooseVC
{
    [self performSegueWithIdentifier:@"ToChooseSegue" sender:self];
}

- (void)presentInvoiceVC
{
    [self performSegueWithIdentifier:@"InvoiceVC" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[ChooseVC class]]) {
        [(ChooseVC*)destVC setTypeChoose:_toPresentType];
        [(ChooseVC*)destVC setChooseFinished:^(NSInteger type,id conente){
            NSLog(@"choose type %ld,%@", (long)type, conente);
            [self chooseFinished:type content:conente];
        }];
    }else if ([destVC isKindOfClass:[AdressVC class]]){
        [(AdressVC*)destVC setChange:^(BOOL change){

        }];
    }else if ([destVC isKindOfClass:[InvoiceVC class]]){
        [(InvoiceVC*)destVC setFinished:^(NSDictionary* invoiceD){
            _orderModel.invoiceInfo = [NSDictionary dictionaryWithDictionary:invoiceD];
            [_orderModel calculatePrice];
            self.countPayLab.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderTB reloadData];
        }];
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
            [_orderModel setDelivery:sendContent];
            _orderModel.delivPrice=[sendContent.price floatValue];
            [_orderModel calculatePrice];
            self.countPayLab.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderTB reloadData];
        }break;
        case 3:{
            [_orderModel setPacking:sendContent];
            _orderModel.packPrice=[sendContent.price floatValue];
            [_orderModel calculatePrice];
            self.countPayLab.text = [NSString stringWithFormat:@"￥%.2f", _orderModel.dealPrice];
            [self.orderTB reloadData];
        }break;
        default:
            break;
    }
}

- (void)setDefaultAdress:(NSArray*)arr
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    [userInfo parseAddressArr:arr];
}


- (void)requestForAddressList
{
    NSLog(@"request for list");
    [self showIndicatorView:kNetworkConnecting];
    [RequestManager requestForAddressListInManager:^(BOOL success) {
        if (success) {
            NSLog(@"success for list");
            [self.orderTB reloadData];
        }else{
            [self showAlertView:kNetworkNotConnect];
        }
        [self dismissIndicatorView];
    }];
}

- (void)requestSubmitOrder
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    if (!userInfo.addressManager) {
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
    [_orderModel setAddressID:userInfo.addressManager.defaultAddressCode];
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@AddOrder.ashx",kServerDomain];
    NSLog(@"url %@", url);
    MutableOrderedDictionary* rdict = [_orderModel dictWithAES];
    [manager POST:url parameters:rdict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        NSLog(@"aes de %@", aesde);
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [UserInfo shareUserInfo].cartsArr = nil;
            _resultDict = result;
            [self showAlertViewTwoBut:@"提交成功" message:[NSString stringWithFormat:@"订单号:%@\n应付总额:%@",_resultDict[@"OrderCode"], _resultDict[@"PayMoney"]] actionTitle:@"支付"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
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
    NSDecimalNumber *money = [NSDecimalNumber decimalNumberWithString:_resultDict[@"PayMoney"]];
    NSDecimalNumber *hun = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSString *moneyString = [NSString stringWithFormat:@"%@",[money decimalNumberByMultiplyingBy:hun]];//换成分
    NSMutableString *names = [NSMutableString string];
    for (NSString *name in _resultDict[@"GoodsNames"]) {
        [names appendString:[NSString stringWithFormat:@"%@,",name]];
    }
    [APay startPay:[PaaCreater createrWithOrderNo:_resultDict[@"OrderCode"] productName:names money:moneyString type:1 shopNum:_MerchantID[@"MerchantID"] key:_MerchantID[@"PayKey"] time:_resultDict[@"CreateTime"]] viewController:self delegate:self mode:kPayMode];
}

- (IBAction)submitOrder:(id)sender {
    [self requestSubmitOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - payDelegate
- (void)APayResult:(NSString*)result
{
    NSLog(@"%@",result);
    isBack = YES;
    [self showAlertView:[Utities doWithPayList:result]];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 4) {
        return 2;
    }else if (section == 5){
        return self.products.count+1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 100;
        case 4:
            return indexPath.row == 0 ? 44 : 75;
        case 5:
            return indexPath.row == 0 ? 44 : 123;
        default:
            return 44;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.5;
        
        default:
            return 10;
            break;
    }
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:adressCell forIndexPath:indexPath];
            UIView *viewBG = [cell viewWithTag:1];
            viewBG.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:175.0/255.0 alpha:1.0].CGColor;
            viewBG.layer.borderWidth = 10;
            UserInfo* userInfo = [UserInfo shareUserInfo];
            AddressManager *manager = [userInfo addressManager];
            NSString *textTop = @"请添加地址";
            NSString *textBut = @"";
            if (manager && manager.defaultAddressIndex < manager.addresses.count && manager.defaultAddressIndex > -1) {
                AdressModel *model = manager.addresses[manager.defaultAddressIndex];
                textTop = [NSString stringWithFormat:@"%@  %@", model.name, model.mobile];
                textBut = [NSString stringWithFormat:@"%@%@%@%@", model.provinceName, model.cityName, model.townName, model.detailAdress];
            }
            UILabel *topLabel = (UILabel*)[cell viewWithTag:2];
            topLabel.text = textTop;
            UILabel *bottomLabel = (UILabel*)[cell viewWithTag:3];
            bottomLabel.text = textBut;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            
        case 1:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            NSString *title = @"支付方式";
            NSString *detail = @"在线支付";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            
        case 2:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            NSString *title = @"配送方式";
            NSString *detail = _orderModel.delivery.name?:@"";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            return cell;
        }
        
        case 3:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            NSString *title = @"作品包装";
            NSString *detail = _orderModel.packing.name ? :@"";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            return cell;
        }
            
        case 4:{
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
                NSArray *invoiceType = @[@"不开发票",@"普通发票"];
                NSString *ticketsTitle = @"";
                if (_orderModel.invoiceInfo) {
                    ticketsTitle = invoiceType[[_orderModel.invoiceInfo[@"InvoiceType"] integerValue]/10];
                }
                topLabel.text = [NSString stringWithFormat:@"发票类型:%@", ticketsTitle];
                midLabel.text = [NSString stringWithFormat:@"发票抬头:%@",(_orderModel.invoiceInfo[@"InvoiceTitle"] ?:@"")];
                return cell;
            }
           
        }case 5:{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
                cell.textLabel.text = @"商品清单";
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:cartCell forIndexPath:indexPath];
                GoodsModel*model = self.products[indexPath.row-1];
                [cell.iconImage setImageWithURL:[NSURL URLWithString:model.picURL] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
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
            
        default:
            break;
    }
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{//地址
            [self performSegueWithIdentifier:@"AdressSegue" sender:self];
        }
            break;
        case 1://选择页面
            break;
        case 2:
        case 3:{
            _toPresentType = indexPath.section;
            [self presentChooseVC];
        }break;
        case 4:{//发票信息
            [self presentInvoiceVC];
        }break;
        case 5:{//商品详情
            
        }
        default:
            break;
    }
    
}

- (void)getMerchantID {
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@GetUserInfo.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

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

@interface OrderDetailVC ()
{
    UserInfo *user;
    OrderModel *order;
    AdressModel *addr;
    InvoiceModel *invoice;
    NSDictionary  *_MerchantID;
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
    // Do any additional setup after loading the view.
    [self showBackItem];
    self.orderDetailTableView.delegate = self;
    self.orderDetailTableView.dataSource = self;
    [self.orderDetailTableView registerNib:[UINib nibWithNibName:@"CartCell" bundle:nil] forCellReuseIdentifier:cartCell];
    [self.orderDetailTableView registerNib:[UINib nibWithNibName:ODCell bundle:nil] forCellReuseIdentifier:ODCell];
    
    self.confirmDelivery.layer.backgroundColor = kRedColor.CGColor;
    self.confirmDelivery.layer.cornerRadius = 3;
    self.confirmDelivery.hidden=YES;
    
    self.checkDelivery.layer.backgroundColor = kRedColor.CGColor;
    self.checkDelivery.layer.cornerRadius = 3;
    self.checkDelivery.hidden=YES;
    
    [self requestLetterList:self.orderCode];
    [self getMerchantID];
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
        id result = [self parseResults:responseObject];
        if (result) {
            [addr addressFromOrder:result[@"Addr"]];
            invoice =[InvoiceModel invoiceWithDict:result[@"Invoice"]];
            order = [OrderModel orderModelWithDict:result];
            [self setButton:order];
            NSLog(@"订单商品解析完成");
            [self.orderDetailTableView reloadData];
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

-(void)setButton:(OrderModel *)ord
{
    self.orderMoney.text=[NSString stringWithFormat:@"￥%@",ord.PayMoney];
    if (0 == ord.state || 10 == ord.state) {
        //创建状态 可支付  可取消
        self.checkDelivery.hidden=NO;
        [self.checkDelivery setTitle:@"取消订单" forState:UIControlStateNormal];
        self.confirmDelivery.hidden=NO;
        [self.confirmDelivery setTitle:@"支付订单" forState:UIControlStateNormal];
    }else if(30 == ord.state){
        self.confirmDelivery.hidden=YES;
        self.checkDelivery.hidden=NO;
        [self.checkDelivery setTitle:@"确认收货" forState:UIControlStateNormal];
        
    }else {
        self.confirmDelivery.hidden=YES;
        self.checkDelivery.hidden=YES;
    }

}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)        return order.Goods.count+2;
    else if(section ==5)     return 2;
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
        case 5:
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
        default:
            return 5;
            break;
    }
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
            topLabel.text =[NSString stringWithFormat:@"%@   %@",addr.name,addr.mobile];
            UILabel *bottomLabel = (UILabel*)[cell viewWithTag:3];
            bottomLabel.text = addr.defaultAdress;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }case 2:{
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
                cell.textLabel.text = @"商品清单";
                cell.detailTextLabel.text = order.OrderType;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else if(indexPath.row == (order.Goods.count+1)){
                OrderDetailCell *orCell=(OrderDetailCell*)[tableView dequeueReusableCellWithIdentifier:ODCell forIndexPath:indexPath];
                orCell.createTime.text=order.CreateTime;
                orCell.cancellTime.text=order.RemainingTime;
                orCell.redLab.numberOfLines=0;
                orCell.redLab.text=@"请在订单失效之前付款否则交易将自动取消,并且您会丢失购买此商品的机会!如果有保证金会扣除您的保证金!";
                return orCell;

            }else{
                GoodsModel *model=order.Goods[indexPath.row -1];
                CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:cartCell forIndexPath:indexPath];
//                [cell.goodsImage setImageWithURL:[NSURL URLWithString:goods.defaultImageUrl]];
//                cell.goodsName.text=goods.GoodsName;
//                cell.goodsPrice.text=[NSString stringWithFormat:@"￥%.2f", goods.AppendPrice];
//                cell.goodsCount.text=@"1";
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
            NSString *title = @"";
            NSString *detail = @"";
            title = @"配送方式";
            detail = @"快递";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case 5:{
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
                topLabel.text = [NSString stringWithFormat:@"发票类型：%@",invoice.InvoiceType];
                midLabel.text = [NSString stringWithFormat:@"发票抬头：%@",invoice.InvoiceTitle];
                botLabel.text = [NSString stringWithFormat:@"发票内容：%@",invoice.InvoiceTaxNo];
                cell.accessoryType = UITableViewCellAccessoryNone;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)payOrder:(id)sender {
    //创建状态 可支付  可取消
    if (0 == order.state || 10 == order.state) {
        NSMutableString *names = [NSMutableString string];
        for (GoodsModel *name in order.Goods) {
            [names appendString:[NSString stringWithFormat:@"%@,",name.GoodsName]];
        }
        NSString *string = [NSString stringWithFormat:@"%ld", (long)([order.OrderMoney floatValue]*100)];
        [APay startPay:[PaaCreater createrWithOrderNo:order.OrderCode productName:names money:string type:1 shopNum:_MerchantID[@"MerchantID"] key:_MerchantID[@"PayKey"]] viewController:self delegate:self mode:kPayMode];
    }else if(30 == order.state){
        NSLog(@"确认收货确认收货确认收货");
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"取消订单出错! %@",error] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }];
    }else {
        NSLog(@"错误操作错误操作");
    }

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
@end

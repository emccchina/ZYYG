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

@interface PayForArtVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger       _toPresentType;//转场页面标志  1 支付， 2 配送
    NSMutableArray         *_adressArr;//
    NSMutableDictionary  *_orderDict;
    NSMutableDictionary     *_defualtAddressDict;//默认地址
    NSDictionary            *_invoiceRequest;//发票的提交信息
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
    self.orderTB.delegate = self;
    self.orderTB.dataSource = self;
    [self.orderTB registerNib:[UINib nibWithNibName:@"CartCell" bundle:nil] forCellReuseIdentifier:cartCell];

    self.submitBut.layer.cornerRadius = 3;
    self.submitBut.layer.backgroundColor = kRedColor.CGColor;
    self.countPayLab.text = [NSString stringWithFormat:@"￥%.2f", self.totalPrice];
    _orderDict = [[NSMutableDictionary alloc] init];
    [_orderDict setObject:[UserInfo shareUserInfo].userKey forKey:@"key"];
    [_orderDict setObject:@"0" forKey:@"InvoiceType"];//0不开发票  10 普通发票， 20 增值税发票
    NSMutableString *productIDs = [NSMutableString string];
    for (GoodsModel *model in self.products) {
        if ([model isEqual:[self.products lastObject]]) {
            [productIDs appendString:[NSString stringWithFormat:@"%@", model.GoodsCode]];
        }else{
            [productIDs appendString:[NSString stringWithFormat:@"%@,", model.GoodsCode]];
        }
    }
    [_orderDict setObject:productIDs forKey:@"product_id"];
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
            [self requestForAddressList];
        }];
    }else if ([destVC isKindOfClass:[InvoiceVC class]]){
        if (_invoiceRequest) {
            [(InvoiceVC*)destVC setInvoice:_invoiceRequest];
        }
        [(InvoiceVC*)destVC setFinished:^(NSDictionary* invoiceD){
            [_orderDict setValuesForKeysWithDictionary:invoiceD];
            _invoiceRequest = [[NSDictionary alloc] initWithDictionary:invoiceD];
            [self.orderTB reloadData];
        }];
    }
}

- (void)chooseFinished:(NSInteger)type content:(id) content
{
    switch (type) {
        case 0:{
            
        }
            break;
        case 1:{
            
        }break;
        case 2:{
            
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
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@addressList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [self setDefaultAdress:result[@"data"]];
            [self.orderTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestSubmitOrder
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    if (!userInfo.addressManager) {
        [self showAlertView:@"请输入地址"];
        return;
    }
    [_orderDict setObject:userInfo.addressManager.defaultAddressCode forKey:@"address_id"];
#ifdef DEBUG
    NSData *data = [NSJSONSerialization dataWithJSONObject:_orderDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", string);
#endif
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@AddOrder.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager POST:url parameters:_orderDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [UserInfo shareUserInfo].cartsArr = nil;
            [self showAlertView:@"提交成功"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (IBAction)submitOrder:(id)sender {
    [self requestSubmitOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3) {
        return 2;
    }else if (section == 4){
        return self.products.count+1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 100;
        case 3:
            return indexPath.row == 0 ? 44 : 75;
        case 4:
            return indexPath.row == 0 ? 44 : 123;
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
            if (manager) {
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
            NSString *title = @"";
            NSString *detail = @"";
            title = @"在线支付";
            detail = @"到付";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            return cell;
        }
            
        case 2:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nomalCell forIndexPath:indexPath];
            NSString *title = @"";
            NSString *detail = @"";
            title = @"配送方式";
            detail = @"快递";
            cell.textLabel.text = title;
            cell.detailTextLabel.text = detail;
            return cell;
        }
            
        case 3:{
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
                NSArray *invoiceType = @[@"不开发票",@"普通发票",@"增值税发票"];
                NSString *ticketsTitle = invoiceType[[_orderDict[@"InvoiceType"] integerValue]/10];
                topLabel.text = [NSString stringWithFormat:@"发票类型:%@", ticketsTitle];
                midLabel.text = [NSString stringWithFormat:@"发票抬头:%@",(_orderDict[@"InvoiceTitle"] ?:@"")];
                
                return cell;
            }
           
        }case 4:{
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
                [cell.iconImage setImageWithURL:[NSURL URLWithString:model.picURL]];
                cell.LTLab.text = model.ArtName;
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
        case 2:{
            _toPresentType = indexPath.section;
            [self presentChooseVC];
        }break;
        case 3:{//发票信息
            [self presentInvoiceVC];
        }break;
        case 4:{//商品详情
            
        }
        default:
            break;
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

//
//  AdressVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "AdressVC.h"
#import "MyButton.h"
#import "AddAdressVC.h"
@interface AdressVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger               _selectedIndex;//选择的哪一行地址 是否默认
    NSInteger               _toAddSelected;//跳到编辑页面 选择的是第几个
    BOOL                    _type;//是新建地址 还是编辑地址 0 新建    1编辑
    NSMutableArray          *_adressesNewArr;//为了删除而做
}
@property (weak, nonatomic) IBOutlet UITableView *adressTB;
@end

@implementation AdressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _adressesNewArr   = [UserInfo shareUserInfo].addressManager.addresses ? :[[NSMutableArray alloc] init];
    [self showBackItem];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"确定" target:self action:@selector(doRightBut:)];
    self.adressTB.delegate = self;
    self.adressTB.dataSource = self;
    _toAddSelected = -1;
    
    _selectedIndex = [UserInfo shareUserInfo].addressManager.defaultAddressIndex;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.adressTB reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = [segue destinationViewController];
    if ([(AddAdressVC*)destVC respondsToSelector:@selector(setAddress:)]) {
        AdressModel *model = _type ?  _adressesNewArr[_toAddSelected]: nil;
        [(AddAdressVC*)destVC setAddress:model];
        [(AddAdressVC*)destVC setFinished:^(){
            [self requestForAddressList];
        }];
    }
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    if (self.change) {
        self.change(YES);
    }
    if (_selectedIndex != [UserInfo shareUserInfo].addressManager.defaultAddressIndex) {
        [self requestUploadAdress];//默认地址变动
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)cellButtonCilck:(id)sender {
    MyButton *button = (MyButton*)sender;
    _selectedIndex = [(NSIndexPath*)button.mark row];
    [self.adressTB reloadData];
}

- (void)requestUploadAdress
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@AddressAdd.ashx",kServerDomain];
    NSLog(@"url %@", url);
    AdressModel *model = _adressesNewArr[_selectedIndex];
    NSDictionary *dict = [model getDict:YES];
    MutableOrderedDictionary *newDict=[self dictWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        [self dismissIndicatorView];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [UserInfo shareUserInfo].addressManager.defaultAddressIndex = _selectedIndex;
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
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
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        [self dismissIndicatorView];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [_adressesNewArr removeAllObjects];
            [[UserInfo shareUserInfo] parseAddressArr:result[@"AddressList"]];
            [_adressesNewArr addObjectsFromArray:[UserInfo shareUserInfo].addressManager.addresses];
            [self.adressTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestForDeleteAddress:(NSIndexPath*)index
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@DelAddress.ashx",kServerDomain];
    NSLog(@"url %@", url);
    AdressModel *model = _adressesNewArr[index.row];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",model.adressCode,@"id", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [_adressesNewArr removeObjectAtIndex:index.row];
            [self.adressTB deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self requestForDeleteAddress:indexPath];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : _adressesNewArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 1 : 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddAdressCell" forIndexPath:indexPath];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdressCell" forIndexPath:indexPath];
        MyButton *imageSelect = (MyButton*)[cell viewWithTag:1];
        UIImage *imageBG = (_selectedIndex == indexPath.row ? [UIImage imageNamed:@"circleSelected"] : [UIImage imageNamed:@"circleUnselected"]);
        [imageSelect setImage:imageBG forState:UIControlStateNormal];
        imageSelect.mark = indexPath;
        UILabel *topLabel = (UILabel*)[cell viewWithTag:2];
        AdressModel *model = _adressesNewArr[indexPath.row];
        topLabel.text = [NSString stringWithFormat:@"%@  %@", model.name, model.mobile];
        UILabel *bottomLabel = (UILabel *)[cell viewWithTag:3];
        bottomLabel.text = [NSString stringWithFormat:@"%@%@%@%@", model.provinceName, model.cityName, model.townName,model.detailAdress];
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _type = indexPath.section;
    
    _toAddSelected = indexPath.section ? indexPath.row : -1;
    
    [self performSegueWithIdentifier:@"AddAdressSegue" sender:self];
}

- (NSString*)aeskeyOrNot:(NSString*)value aes:(BOOL)aes
{
    NSString *string = nil;
    if ([value isEqualToString:@""] || !value) {
        return @"";
    }else if(!aes){
        return value;
    }
    else{
        string = [value AES256EncryptWithKey:kAESKey];
        return string;
    }
}

//加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Province_Code"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"city_Code"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"area_Code"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"zipcode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"status"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"address"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"name"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"tel"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"telPhone"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"addr_code"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Province_Code"] aes:NO] forKey:@"Province_Code" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"city_Code"] aes:NO] forKey:@"city_Code" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"area_Code"] aes:NO] forKey:@"area_Code" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"zipcode"] aes:NO] forKey:@"zipcode" atIndex:4];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"status"] aes:NO] forKey:@"status" atIndex:5];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"address"] aes:YES] forKey:@"address" atIndex:6];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"name"] aes:YES] forKey:@"name" atIndex:7];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"tel"] aes:YES] forKey:@"tel" atIndex:8];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"telPhone"] aes:YES] forKey:@"telPhone" atIndex:9];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"addr_code"] aes:NO] forKey:@"addr_code" atIndex:10];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:11];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:12];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
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

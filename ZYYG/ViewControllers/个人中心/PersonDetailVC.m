//
//  PersonDetailVC.m
//  ZYYG
//
//  Created by champagne on 14-12-8.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PersonDetailVC.h"
#import "UserInfo.h"
#import "EditPersonVC.h"
#import "AdressTextField.h"
#import "FMDatabase.h"

@interface PersonDetailVC ()
<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSMutableArray *detailArry;
    UserInfo *user;
    NSArray *titles;
    NSArray *placeholders;//占位符
    NSMutableArray *infos;//个人信息说明
    UITextField         *selectedField;//正在编辑的textField
    UIPickerView        *picker;//
    NSString            *provience;
    NSString            *city;
    NSString            *town;
    NSArray             *genderArr;
}

@end

@implementation PersonDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"保存" target:self action:@selector(doRightButton:)];
    titles = @[@"昵称:", @"真实姓名:", @"性别:", @"年收入:", @"手机号:", @"邮箱:", @"所在地:", @"详细地址:", @"邮编:"];
    placeholders = @[@"请输入昵称", @"请输入真实姓名", @"请选择性别", @"请输入年收入", @"手机号不可更改", @"邮箱不可更改", @"请输入所在地", @"请输入详细地址", @"请输入邮编"];
    genderArr = @[@"男", @"女"];
    user =[UserInfo shareUserInfo];
    infos = [[NSMutableArray alloc] init];
    [self setInfos];
    self.personDetailTableView.delegate = self;
    self.personDetailTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)readAdressFromDB
{
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"adress" ofType:@"db"];
    FMDatabase *dataBase = [FMDatabase databaseWithPath:dbPath];
    if (![dataBase open]) {
        NSLog(@"数据库读取失败");
        return;
    }
    __block int areaCount = 0;
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@_id=%ld;SELECT * FROM %@ WHERE %@_id=%ld;SELECT * FROM %@ WHERE %@_id=%ld;"
                     ,kProvinceAdress,kProvinceAdress,(long)[user.provideCode integerValue], kCityAdress, kCityAdress, (long)[user.cityCode integerValue], kTownAdress, kTownAdress, (long)[user.aeraCode integerValue]];
    __block BOOL success = NO;
    [dataBase executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
        NSLog(@"%@", dictionary);
        switch (areaCount) {
            case 0:{
                provience = dictionary[[NSString stringWithFormat:@"%@_name", kProvinceAdress]];
            }break;
            case 1:{
                city = dictionary[[NSString stringWithFormat:@"%@_name", kCityAdress]];
            }break;
            case 2:{
                town = dictionary[[NSString stringWithFormat:@"%@_name", kTownAdress]];
            }break;
            default:
                break;
        }
        areaCount++;
        success = YES;
        return 0;
    }];
    
    if (!success) {
        provience = @"";
        city = @"";
        town = @"";
    }
    provience = [self checkNull:provience];
    city = [self checkNull:city];
    town = [self checkNull:town];
    
    [dataBase close];
    
}

- (NSString*)checkNull:(id)checkString
{
    if ([checkString isKindOfClass:[NSNull class]] || !checkString) {
        return @"";
    }
    return checkString;
}



- (void)setInfos
{
    [infos addObject:user.nickName ? :@""];
    [infos addObject:user.realName ? :@""];
    [infos addObject:[user.gender integerValue] ? @"女" :@"男"];
    [infos addObject:user.income ? :@""];
    [infos addObject:user.mobile ? :@""];
    [infos addObject:user.email ? :@""];
    [self readAdressFromDB];
    [infos addObject:[NSString stringWithFormat:@"%@%@%@",provience,city,town]];
    [infos addObject:user.detailAddress ? :@""];
    [infos addObject:user.zipCode ? :@""];
}

- (void)userInfoFromInfos
{
    user = [UserInfo shareUserInfo];
    user.nickName = infos[0];
    user.realName = infos[1];
    user.gender = [infos[2] isEqualToString:@"女"] ? @"1" : @"0";
    user.income = infos[3];
    user.mobile = infos[4];
    user.email = infos[5];
    id x = infos[6];
    if ([x isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)x;
        user.provideCode = array[0][0];
        user.cityCode = array[1][0];
        user.aeraCode = array[2][0];
    }
    user.detailAddress = infos[7];
    user.zipCode = infos[8];
}

- (void)areasInfos:(AdressTextField *)textField
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:textField.provience];
    [array addObject:textField.city];
    [array addObject:textField.town];
    provience = textField.provience[1];
    city = textField.city[1];
    town = textField.town[1];
    [infos replaceObjectAtIndex:6 withObject:array];
}

- (void)doRightButton:(UIBarButtonItem*)item
{
    [self requestForSaveInfo];
}

- (NSDictionary*)createInfoDictForRequest
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:infos[0] forKey:@"Nickname"];
    [dict setObject:infos[1] forKey:@"RealName"];
    NSString * gender = [infos[2] isEqualToString:@"女"] ? @"1" : @"0";
    [dict setObject:gender forKey:@"Sex"];
    [dict setObject:infos[3] forKey:@"Income"];
    [dict setObject:infos[4] forKey:@"Mobile"];
    [dict setObject:infos[5] forKey:@"email"];
    id x = infos[6];
    if ([x isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray*)x;
        [dict setObject:array[0][0] forKey:@"ProvideCode"];
        [dict setObject:array[1][0] forKey:@"CityCode"];
        [dict setObject:array[2][0] forKey:@"AeraCode"];
    
    }else{
        [dict setObject:user.provideCode forKey:@"ProvideCode"];
        [dict setObject:user.cityCode forKey:@"CityCode"];
        [dict setObject:user.aeraCode forKey:@"AeraCode"];
    }
    [dict setObject:infos[7] forKey:@"DetailAddr"];
    [dict setObject:infos[8] forKey:@"Postcode"];
    [dict setObject:[UserInfo shareUserInfo].userKey forKey:@"Key"];
    return dict;
}

- (void)requestForSaveInfo
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SaveUserInfo.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [self createInfoDictForRequest];
    MutableOrderedDictionary *orderArr= [self dictWithAES:dict];
    [manager POST:url parameters:orderArr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject ];
        if (result) {
            [self userInfoFromInfos];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    NSLog(@"%@", infos);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertAddress:(UITextField*)field
{
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    [topView setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doFinish)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace, doneButton, nil];
    
    [topView setItems:buttonsArray];
    [field setInputAccessoryView:topView];
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    field.inputView = picker;
}

- (void)doFinish
{
    NSInteger row = [picker selectedRowInComponent:0];
    [infos replaceObjectAtIndex:2 withObject:genderArr[row]];
    [self.personDetailTableView reloadData];
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return genderArr[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}
#pragma mark tableView
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titles.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row == 6) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"AdressCell" forIndexPath:indexPath];
        AdressTextField *field = (AdressTextField*)[cell viewWithTag:2];
        field.placeholder = placeholders[indexPath.row];
        field.delegate = self;
        field.text = [NSString stringWithFormat:@"%@%@%@",provience,city,town];
        [field setEditFinished:^(AdressTextField *tf){
            NSLog(@"%@%@%@", tf.provience, tf.city, tf.town);
            [self areasInfos:tf];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell=[tableView dequeueReusableCellWithIdentifier:@"PersonDetailCell" forIndexPath:indexPath];
        UITextField *field = (UITextField*)[cell viewWithTag:2];
        field.placeholder = placeholders[indexPath.row];
        field.delegate = self;
        field.text = infos[indexPath.row];
        field.returnKeyType = UIReturnKeyDone;
        if (indexPath.row == 2) {
            [self insertAddress:field];
             cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 4||indexPath.row == 5){
            field.enabled = NO;
            
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = titles[indexPath.row];
    
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark -textField

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"fffffff");
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"bbbbb");
//    selectedField = textField;
    CGPoint point = [textField convertPoint:textField.frame.origin toView:self.view];
    //    NSLog(@"super view frame %@", NSStringFromCGPoint(point));
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 160) - 250;
    if (space < 0) {
        CGPoint offset = self.personDetailTableView.contentOffset;
        offset.y -= space;
        [self.personDetailTableView setContentOffset:offset];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"nnnnnn");
    [self.personDetailTableView setContentOffset:CGPointZero];
    NSInteger index = [placeholders indexOfObject:textField.placeholder];
    if (index != 2) {
        [infos replaceObjectAtIndex:index withObject:textField.text];
    }
    
}

//加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"RealName"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Nickname"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Sex"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Industry"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Income"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Mobile"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"ProvideCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"CityCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"AeraCode"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"DetailAddr"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Postcode"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Key"] aes:NO] forKey:@"Key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"RealName"] aes:YES] forKey:@"RealName" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Nickname"] aes:NO] forKey:@"Nickname" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Sex"] aes:NO] forKey:@"Sex" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Industry"] aes:NO] forKey:@"Industry" atIndex:4];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Income"] aes:YES] forKey:@"Income" atIndex:5];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Mobile"] aes:NO] forKey:@"Mobile" atIndex:6];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"ProvideCode"] aes:NO] forKey:@"ProvideCode" atIndex:7];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"CityCode"] aes:NO] forKey:@"CityCode" atIndex:8];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"AeraCode"] aes:NO] forKey:@"AeraCode" atIndex:9];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"DetailAddr"] aes:YES] forKey:@"DetailAddr" atIndex:10];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Postcode"] aes:NO] forKey:@"Postcode" atIndex:11];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:12];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:13];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}

@end

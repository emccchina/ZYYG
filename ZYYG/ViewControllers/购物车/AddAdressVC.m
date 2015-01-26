//
//  AddAdressVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "AddAdressVC.h"
#import "FMDatabase.h"

@interface AddAdressVC ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    FMDatabase          *dataBase;
    NSArray             *_userInfos;//收货人信息
    CGRect              _initFrame;//self.view 初始化frame 用于键盘 遮挡问题
    UITextField         *selectedField;//正在编辑的textField
    NSArray             *areaArr;//各个地区
    NSArray             *townArr;
    NSArray             *cityArr;
    NSMutableArray      *selectAreaArr;
    UIPickerView        *picker;//
    NSArray             *placeholderArr;//
    AdressModel         *addressMode;
    
}
@property (weak, nonatomic) IBOutlet UITableView *writeTB;
@property (weak, nonatomic) IBOutlet UIButton *saveBut;
@end

@implementation AddAdressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    addressMode = [[AdressModel alloc] init];
    if (self.address) {
        self.title = @"编辑地址";
        [addressMode setModelFromAddressModel:self.address];
    }
    [self showBackItem];
    [self readAdressFromDB];
    _initFrame = self.view.frame;
    _userInfos = @[@"收货人:", @"手机号码:", @"所在地区:", @"详细地址:"];
    placeholderArr = @[@"请输入姓名", @"请输入手机号", @"", @"请输入详细地址"];

    self.writeTB.delegate = self;
    self.writeTB.dataSource = self;
    self.writeTB.bounces = NO;
    self.saveBut.layer.cornerRadius = 3;
    self.saveBut.layer.backgroundColor = kRedColor.CGColor;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [dataBase close];
}

- (void)readAdressFromDB
{
    selectAreaArr = [[NSMutableArray alloc] init];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"adress" ofType:@"db"];
    dataBase = [FMDatabase databaseWithPath:dbPath];
    if (![dataBase open]) {
        NSLog(@"数据库读取失败");
        return;
    }
    NSMutableArray *provices = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kProvinceAdress];
    FMResultSet *provicesResult = [dataBase executeQuery:sql];
    while ([provicesResult next]) {
        NSInteger proviceID = [provicesResult intForColumn:@"province_id"];
        NSString  *proviceName = [provicesResult stringForColumn:@"province_name"];
        [provices addObject:@[@(proviceID), proviceName]];
    }
    areaArr = [[NSArray alloc] initWithArray:provices];
    [self restorePlaceArr];
    if (!self.address) {
        [self setModelAreaID];
    }
}

- (void)restorePlaceArr
{
    [selectAreaArr addObject:areaArr[0]];
    cityArr = [self arrayFromDB:kCityAdress upName:kProvinceAdress key:[(NSNumber*)(areaArr[0][0]) intValue]];
    [selectAreaArr addObject:cityArr[0]];
    townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[(NSNumber*)(cityArr[0][0]) integerValue]];
    [selectAreaArr addObject:townArr[0]];
}

- (void)setModelAreaID
{
    addressMode.provinceID = selectAreaArr[0][0];
    addressMode.provinceName = selectAreaArr[0][1];
    addressMode.cityID = selectAreaArr[1][0];
    addressMode.cityName = selectAreaArr[1][1];
    addressMode.townID = selectAreaArr[2][0];
    addressMode.townName = selectAreaArr[2][1];
    [self restorePlaceArr];
}

- (NSArray*)arrayFromDB:(NSString*)tableName upName:(NSString*)upName key:(NSInteger)key
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@_id=%ld", tableName, upName, (long)key];
    FMResultSet *s = [dataBase executeQuery:sql];
    while ([s next]) {
        NSInteger areaID = [s intForColumn:[NSString stringWithFormat:@"%@_id", tableName]];
        NSString  *areaName = [s stringForColumn:[NSString stringWithFormat:@"%@_name", tableName]];
        NSInteger UPID = [s intForColumn:[NSString stringWithFormat:@"%@_id", upName]];
        NSArray *arr = @[@(areaID), areaName, @(UPID)];
        [array addObject:arr];
    }
    if (!array.count) {
        return @[@[@"0",@"",@"0"]];
    }
    return array;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [selectedField   resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)continueRequest
{
    if (!addressMode.name || [addressMode.name isEqualToString:@""]) {
        return NO;
    }
    if (!addressMode.mobile || [addressMode.mobile isEqualToString:@""]) {
        return NO;
    }
    if (!addressMode.detailAdress || [addressMode.detailAdress isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (NSString*)CNToEn:(NSString*)str
{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)requestUploadAdress
{
    if (![self continueRequest]) {
        [self showAlertView:@"请输入信息"];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@AddressAdd.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [addressMode getDict:YES];
        MutableOrderedDictionary *newDict =[self dictWithAES:dict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [self.navigationController popViewControllerAnimated:YES];
            if (self.finished) {
                self.finished();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}
- (IBAction)doSave:(id)sender {
    [self requestUploadAdress];
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
    [selectedField resignFirstResponder];
    [selectAreaArr replaceObjectAtIndex:0 withObject:(areaArr[[picker selectedRowInComponent:0]])];
    [selectAreaArr replaceObjectAtIndex:1 withObject:(cityArr[[picker selectedRowInComponent:1]])];
    [selectAreaArr replaceObjectAtIndex:2 withObject:(townArr[[picker selectedRowInComponent:2]])];
    [self setModelAreaID];
    [self.writeTB reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSArray*)areaFomeArr:(NSArray*)arr row:(NSInteger)row
{
    if (arr.count > row) {
        return arr[row];
    }
    return nil;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return areaArr.count;
        case 1:
            return cityArr.count;
        case 2:
            return townArr.count;
        default:
            return 0;
    }
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return areaArr[row][1];
        case 1:
            return cityArr[row][1];
        case 2:
            return townArr[row][1];
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:{
            NSNumber *provinceID = areaArr[row][0];
            cityArr = [self arrayFromDB:kCityAdress upName:kProvinceAdress key:[provinceID integerValue]];
            NSLog(@"%@", cityArr[0][0]);
            townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[(NSNumber*)(cityArr[0][0]) intValue]];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        }
            break;
        case 1:{
            NSNumber *cityID = cityArr[row][0];
            townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[cityID integerValue]];
            [pickerView reloadComponent:2];
        }
            break;
        case 2:{
            
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WriteCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *titleLab = (UILabel*)[cell viewWithTag:1];
    titleLab.text = _userInfos[indexPath.row];
    UITextField *field = (UITextField*)[cell viewWithTag:2];
    field.delegate = self;
    field.returnKeyType = UIReturnKeyDone;
    switch (indexPath.row) {
        case 0:{
            field.text = addressMode ? addressMode.name : @"";
        }
            break;
        case 1:{
            field.text = addressMode ? addressMode.mobile : @"";
            field.keyboardType = UIKeyboardTypeNumberPad;
        }
            break;
        case 2:{
            [self insertAddress:field];
            field.text = [NSString stringWithFormat:@"%@ %@ %@", addressMode.provinceName, addressMode.cityName, addressMode.townName];

        }
            break;
        case 3:{
            field.text = addressMode ? addressMode.detailAdress : @"";
        }
        break;
        default:
        break;
    }
    field.placeholder = placeholderArr[indexPath.row];
    if (indexPath.row == 2) {
    
    }else if (indexPath.row == 1){
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectedField = textField;
    CGPoint point = [textField convertPoint:textField.frame.origin toView:self.view];
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 160) - 250;
    if (space < 0) {
        CGPoint offset = self.writeTB.contentOffset;
        offset.y -= space;
        [self.writeTB setContentOffset:offset];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.writeTB setContentOffset:CGPointZero];
    NSInteger index = [placeholderArr indexOfObject:textField.placeholder];
    switch (index) {
        case 0:
            addressMode.name = textField.text;
            break;
        case 1:
            addressMode.mobile = textField.text;
            break;
        case 3:
            addressMode.detailAdress = textField.text;
            break;
        default:
            break;
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
    [orderArr insertObject:@"5134DUIOIOO72761" forKey:@"t" atIndex:12];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}
- (NSString *)aeskeyOrNot:(NSString *)value aes:(BOOL)aes
{
    NSLog(@"===================%@",value);
    NSString *string = nil;
    if (value == nil || [value isKindOfClass:[NSNull class]] ) {
        return @"";
    }
    NSString *newValue=[NSString stringWithFormat:@"%@",value ];
    if([newValue isEqualToString:@""]){
        return @"";
    }else if(!aes){
        return newValue;
    }else{
        string = [newValue AES256EncryptWithKey:kAESKey];
        return string;
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

//
//  InvoiceVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/23.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "InvoiceVC.h"
#import "MyButton.h"
#import "MyTextField.h"

@interface InvoiceVC ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray     *sectionTitles;
    NSInteger   selectedIndex;//选中的section
    NSMutableDictionary *invoiceDict;//填写的发票信息
    NSArray     *requestKeys;//发送请求是的key 此处就组装好发票的dict
    MyTextField *selectedTF;
}
@property (weak, nonatomic) IBOutlet UITableView *invoiceTB;
@end

@implementation InvoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"保存" target:self action:@selector(doRightBut:)];
    
    if (self.invoice) {
        invoiceDict = [[NSMutableDictionary alloc] initWithDictionary:self.invoice];
    }else{
        invoiceDict = [[NSMutableDictionary alloc] init];
    }
    selectedIndex = [invoiceDict[@"InvoiceType"] integerValue]/10;
    NSDictionary *section0 = @{@"不开具发票":@[]};
    NSDictionary *section1 = @{@"普通发票(税率 3.00%)":@[@"发票抬头"]};
//    NSDictionary *section2 = @{@"增值税发票":@[@"发票抬头",@"纳税人识别号",@"注册地址",@"开户银行",@"银行帐号",@"注册电话"]};
    requestKeys = @[@"InvoiceTitle",@"InvoiceTaxNo",@"RegAddress",@"RegBank",@"RegAccount",@"RegPhone"];
    sectionTitles = @[section0, section1];
    self.invoiceTB.delegate = self;
    self.invoiceTB.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    [selectedTF resignFirstResponder];
    NSLog(@"%@", invoiceDict);
    [invoiceDict setObject:[NSString stringWithFormat:@"%ld", (long)selectedIndex*10] forKey:@"InvoiceType"];
    if (![self judgeInvoice]) {
        return;
    }
    if (self.finished) {
        self.finished(invoiceDict);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)judgeInvoice
{
    switch (selectedIndex) {
        case 0:{
            
        }break;
        case 1:{
            NSString *string = invoiceDict[requestKeys[0]];
            if (!string || [string isEqualToString:@""]) {
                [self showAlertView:@"请完善信息"];
                return NO;
            }
        }break;
        case 2:{
            for (NSString *titleKey in requestKeys) {
                NSString *content = invoiceDict[titleKey];
                if (!content || [content isEqualToString:@""]) {
                    [self showAlertView:@"请完善信息"];
                    return NO;
                }
                NSInteger index = [requestKeys indexOfObject:titleKey];
                if (![self isValidateInfo:content index:index]){
                    return NO;
                }
            }
        }break;
        default:
            break;
    }
    return YES;
}

- (BOOL)isValidateInfo:(NSString*)key index:(NSInteger)index
{
    switch (index) {
        case 1:{//纳税人识别号
            if (![self isValidateTaxesNumber:key]) {
                NSLog(@"taxes number no, %@", key);
                [self showAlertView:@"请输入有效纳税人识别号码"];
                return NO;
            }
        }break;
        case 4:{//开户银行
            if (![self isValidateBankNumber:key]) {
                NSLog(@"bank number no %@", key);
                [self showAlertView:@"请输入有效银行卡号码"];
                return NO;
            }
        }break;
        case 5:{//注册电话
            if (![self isValidateMobile:key]) {
                NSLog(@"mobile no %@", key);
                [self showAlertView:@"请输入有效手机号码"];
                return NO;
            }
        }break;
        default:
            break;
    }
    return YES;
}
- (BOOL)isValidateTaxesNumber:(NSString*)number
{
    NSInteger length = [number length];
    if (length < 15 || length > 18) {
        return NO;
    }
    return YES;
}

- (BOOL)isValidateBankNumber:(NSString*)number
{
    int oddsum = 0;
    int evensum = 0;
    int allsum = 0;
    
    for (int i = 0; i< [number length];i++) {
        NSString *tmpString = [number substringWithRange:NSMakeRange(i, 1)];
        int tmpVal = [tmpString intValue];
        if((i % 2) == 0){
            tmpVal *= 2;
            if(tmpVal>=10)
                tmpVal -= 9;
            evensum += tmpVal;
        }else{
            oddsum += tmpVal;
            
        }
    }
    
    allsum = oddsum + evensum;
    
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}
- (BOOL)isValidateMobile:(NSString*)mobile
{
    NSString *regex = @"^(13+\\d{9})$|(14+\\d{9})$|(15+\\d{9})$|(18+\\d{9})$|(17+\\d{9})$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

- (void)myButtonClick:(MyButton*)button
{
    NSLog(@"%@", button.mark);
    selectedIndex = [button.mark integerValue];
    [self.invoiceTB reloadData];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == selectedIndex) {
        NSArray *keys = [(NSDictionary*)(sectionTitles[section]) allKeys];
        return [[sectionTitles[section] objectForKey:keys[0]] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [tableView headerViewForSection:section];
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    }
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = (UIImageView*)[view viewWithTag:3];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
    }
    UIImage *BGImage = (selectedIndex == section ? [UIImage imageNamed:@"circleSelected"] : [UIImage imageNamed:@"circleUnselected"]);
    imageView.image = BGImage;
    imageView.tag = 3;
    [view addSubview:imageView];
    
    UILabel *label = (UILabel*)[view viewWithTag:1];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 100, 30)];
    }
    label.textColor = kGrayColor;
    NSArray *keys = [(NSDictionary*)(sectionTitles[section]) allKeys];
    label.text = keys[0];
    label.tag = 1;
    [view addSubview:label];
    
    MyButton *button = (MyButton*)[view viewWithTag:2];
    if (!button) {
        button = [[MyButton alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    }
    button.tag = 2;
    button.mark = @(section);
    [button addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = sectionTitles[indexPath.section];
    NSArray *keys = [dict allKeys];
    NSArray *rowKeys = [dict objectForKey:keys[0]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = rowKeys[indexPath.row];
    MyTextField *tf = (MyTextField*)[cell viewWithTag:2];
    NSString *key = requestKeys[indexPath.row];
    tf.text = invoiceDict[key];

    tf.delegate = self;
    tf.mark = indexPath;
    tf.returnKeyType = UIReturnKeyDone;
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

- (void)textFieldDidBeginEditing:(MyTextField *)textField
{
    selectedTF = textField;
    CGPoint point = [textField convertPoint:textField.frame.origin toView:self.view];
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 160) - 250;
    if (space < 0) {
        CGPoint offset = self.invoiceTB.contentOffset;
        offset.y -= space;
        [self.invoiceTB setContentOffset:offset];
    }
    
}

- (void)textFieldDidEndEditing:(MyTextField *)textField
{
    [self.invoiceTB setContentOffset:CGPointZero];
    NSIndexPath *mark = textField.mark;
    if (mark) {
        switch (mark.section) {
            case 1:
            case 2:{
                NSString *key = requestKeys[mark.row];
                [invoiceDict setObject:textField.text forKey:key];
            }break;
            default:
                break;
        }
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

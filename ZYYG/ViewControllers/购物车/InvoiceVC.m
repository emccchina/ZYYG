//
//  InvoiceVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/23.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "InvoiceVC.h"
#import "MyButton.h"

@interface InvoiceVC ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray     *sectionTitles;
    NSInteger   selectedIndex;//选中的section
    NSMutableDictionary *invoiceDict;//填写的发票信息
    NSArray     *requestKeys;//发送请求是的key 此处就组装好发票的dict
}
@property (weak, nonatomic) IBOutlet UITableView *invoiceTB;
@end

@implementation InvoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"保存" target:self action:@selector(doRightBut:)];
    selectedIndex = 0;
    invoiceDict = [[NSMutableDictionary alloc] init];
    NSDictionary *section0 = @{@"不开具发票":@[]};
    NSDictionary *section1 = @{@"普通发票":@[@"发票抬头"]};
    NSDictionary *section2 = @{@"增值税发票":@[@"发票抬头",@"纳税人识别号",@"注册地址",@"开户银行",@"帐号",@"注册电话"]};
    requestKeys = @[@"InvoiceTitle",@"InvoiceTaxNo",@"RegAddress",@"RegBank",@"RegAccount",@"RegPhone"];
    sectionTitles = @[section0, section1, section2];
    self.invoiceTB.delegate = self;
    self.invoiceTB.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    
}

- (void)myButtonClick:(MyButton*)button
{
    NSLog(@"%@", button.mark);
    selectedIndex = [button.mark integerValue];
    [invoiceDict removeAllObjects];
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
    UITextField *tf = (UITextField*)[cell viewWithTag:2];
    tf.delegate = self;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point = [textField convertPoint:textField.frame.origin toView:self.view];
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 160) - 250;
    if (space < 0) {
        CGPoint offset = self.invoiceTB.contentOffset;
        offset.y -= space;
        [self.invoiceTB setContentOffset:offset];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.invoiceTB setContentOffset:CGPointZero];
//    NSInteger index = [sectionTitles ]
    
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

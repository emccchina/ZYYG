//
//  ChooseVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ChooseVC.h"

@interface ChooseVC ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray *payType;
    NSArray *delivery;
    NSInteger _selectState;//选择那种方式
    NSArray *tickets;//发票数组
    NSArray *ticketTitles;//发票title
    NSMutableArray *ticketResults;//发票选择结果
}
@property (weak, nonatomic) IBOutlet UITableView *chooseTB;
@end

@implementation ChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    NSArray *titles = @[@"保证金支付方式", @"支付方式", @"配送方式", @"发票信息"];
    payType = @[@"银行卡", @"支付宝"];
    delivery = @[@"快递", @"上门自提"];
    NSArray *ticketType = @[@"普通发票", @"增值税发票"];
    NSArray *ticketTop = @[@"个人"];
    tickets = @[ticketType, ticketTop];
    ticketTitles = @[@"发票类型", @"发票抬头(可输入个人或单位名称)"];
    ticketResults = [NSMutableArray arrayWithObjects:@(0), @(0), nil];//第一个参数 发票类型0普通发票， 1增值税发票 ，，第二个 名称
    self.title = titles[self.typeChoose];
    self.chooseTB.delegate = self;
    self.chooseTB.dataSource = self;
    if (self.typeChoose == 1 || self.typeChoose == 2) {
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"确定" target:self action:@selector(doRightBut:)];
    }
    
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    if (self.chooseFinished) {
        id sendContent = (self.typeChoose != 3 ? @(_selectState) : ticketResults);
        if (self.typeChoose == 3){
            NSString *type = ([ticketResults[0] integerValue] ? @"20" : @"10");
            [ticketResults replaceObjectAtIndex:0 withObject:type];
        }
        self.chooseFinished(self.typeChoose, sendContent);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.typeChoose == 3 ? tickets.count: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.typeChoose == 3) {
        return [(NSArray*)(tickets[section]) count];
    }
    return self.typeChoose == 2 ? delivery.count : payType.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.typeChoose == 3) {
        return 30;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.typeChoose == 3) {
        if (section < ticketTitles.count) {
            return ticketTitles[section];
        }
    }
    return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.typeChoose == 3) {
        if (indexPath.section == 1) {
            UITableViewCell *cellTicket = [tableView dequeueReusableCellWithIdentifier:@"TicketCell" forIndexPath:indexPath];
            UITextField *field = (UITextField*)[cellTicket viewWithTag:1];
            field.delegate = self;
            return cellTicket;
        }else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
            cell.textLabel.text = tickets[indexPath.section][indexPath.row];
            cell.accessoryType = ([ticketResults[indexPath.section] integerValue] == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
            return cell;
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
        cell.textLabel.text = (self.typeChoose == 2 ? delivery[indexPath.row] : payType[indexPath.row]);
        cell.accessoryType = (_selectState == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.typeChoose == 3) {
        [ticketResults replaceObjectAtIndex:indexPath.section withObject:@(indexPath.row)];
    }else{
        _selectState = indexPath.row;
        if (self.typeChoose == 1 || self.typeChoose == 2) {
            [self doRightBut:nil];
            return;
        }
    }
    [self.chooseTB reloadData];
}

#pragma mark - UITextfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = textField.text;
    if ([text isEqualToString:@""]) {
        [self showAlertView:@"请输入名称"];
        return;
    }
    [ticketResults replaceObjectAtIndex:1 withObject:text];
}
@end

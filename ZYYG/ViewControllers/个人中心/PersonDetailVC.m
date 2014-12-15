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

@interface PersonDetailVC ()
<UITextFieldDelegate>
{
    NSMutableArray *detailArry;
    UserInfo *user;
    NSArray *titles;
    NSArray *placeholders;//占位符
    NSMutableArray *infos;//个人信息说明
}

@end

@implementation PersonDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    titles = @[@"昵称", @"真实姓名", @"性别", @"年收入", @"手机号", @"邮箱", @"所在地", @"详细地址", @"邮编"];
    placeholders = @[@"请输入昵称", @"请输入真实姓名", @"请选择性别", @"请输入年收入", @"请输入手机号", @"请输入邮箱", @"请输入所在地", @"请输入详细地址", @"请输入邮编"];
    
    user =[UserInfo shareUserInfo];
    infos = [[NSMutableArray alloc] init];
    [self setInfos];
    self.personDetailTableView.delegate = self;
    self.personDetailTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}

- (void)setInfos
{
    [infos addObject:user.nickName ? :@""];
    [infos addObject:user.realName ? :@""];
    [infos addObject:user.gender ? :@""];
    [infos addObject:user.income ? :@""];
    [infos addObject:user.mobile ? :@""];
    [infos addObject:user.email ? :@""];
    [infos addObject:user.provideCode ? :@""];
    [infos addObject:user.detailAddress ? :@""];
    [infos addObject:user.zipCode ? :@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PersonDetailCell" forIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = titles[indexPath.row];
    UITextField *field = (UITextField*)[cell viewWithTag:2];
    field.placeholder = placeholders[indexPath.row];
    field.delegate = self;
    field.text = infos[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
}

@end

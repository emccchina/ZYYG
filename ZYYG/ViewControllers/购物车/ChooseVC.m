//
//  ChooseVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ChooseVC.h"

@interface ChooseVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *payType;
    NSArray *delivery;
    NSInteger _selectState;//选择那种方式
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
    self.title = titles[self.typeChoose];
    self.chooseTB.delegate = self;
    self.chooseTB.dataSource = self;
    self.navigationItem.rightBarButtonItem = nil;
    
    
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    if (self.chooseFinished) {
        id sendContent = @(_selectState);
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.typeChoose == 2 ? delivery.count : payType.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
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
    return @"";
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell" forIndexPath:indexPath];
    cell.textLabel.text = (self.typeChoose == 2 ? delivery[indexPath.row] : payType[indexPath.row]);
    cell.accessoryType = (_selectState == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectState = indexPath.row;
    if (self.typeChoose == 1 || self.typeChoose == 2) {
        [self doRightBut:nil];
        return;
    }
}

@end

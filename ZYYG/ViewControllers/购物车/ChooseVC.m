//
//  ChooseVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ChooseVC.h"
#import "ClassifyModel.h"


@interface ChooseVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *payType;//支付
    NSArray *delivery;//配送数组
    NSArray *packageArr;//包装
    NSInteger _selectState;//选择那种方式
    NSString *selectCode;
    ClassifyModel *model;
}
@property (weak, nonatomic) IBOutlet UITableView *chooseTB;
@end

@implementation ChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
     UserInfo *userInfo = [UserInfo shareUserInfo];
    NSArray *titles = @[@"保证金支付方式", @"支付方式", @"配送方式", @"包装方式"];
    payType = @[@"银行卡", @"支付宝"];
    delivery =userInfo.deliveryList;
    packageArr =userInfo.packingList;
    self.title = titles[self.typeChoose];
    self.chooseTB.delegate = self;
    self.chooseTB.dataSource = self;
    self.navigationItem.rightBarButtonItem = nil;
    
    
}

- (void)doRightBut:(UIBarButtonItem*)item
{
    ClassifyModel *sendContent;
    if (self.chooseFinished) {
        switch (self.typeChoose) {
            case 1:
                sendContent = [[ClassifyModel alloc] init];
                break;
            case 2:
                sendContent = delivery[_selectState];
                break;
            case 3:
                sendContent = packageArr[_selectState];
                break;
            default:
                break;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.typeChoose) {
        case 1:
            return payType.count;
        case 2:
            return delivery.count;
        case 3:
            return packageArr.count;
            
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    
    NSString *title = nil;
    NSString *detail = nil;
    switch (self.typeChoose) {
        case 1:
            title = payType[indexPath.row][0];
            detail = payType[indexPath.row ][1];
            break;
        case 2:
            model=delivery[indexPath.row];
            title = model.name;
            detail = [NSString stringWithFormat:@"(￥%@)%@",model.price,model.desc] ;
            break;
        case 3:
            model=packageArr[indexPath.row];
            title = model.name;
            detail = [NSString stringWithFormat:@"(￥%@)%@",model.price,model.desc] ;
            break;
        default:
            break;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.accessoryType = (_selectState == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectState = indexPath.row;
    [self doRightBut:nil];
}

@end

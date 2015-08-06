//
//  PersonCenterVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "PersonCenterVC.h"
#import "PersonCenterModel.h"
#import "UserInfo.h"
#import "OrderListVC.h"
//个人中心
@implementation PersonCenterVC
{
    NSMutableArray *personDataArray;//个人中心数据
    UserInfo *user;//用户信息
    UIImage *imagedata;//头像图片
    NSInteger orderType;
}

static NSString *topCell = @"topCell";
static NSString *listCell = @"listCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    user=[UserInfo shareUserInfo];
    orderType=0;
    //初始化数据
    personDataArray =[NSMutableArray array];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"PersonCenter" ofType:@"plist"];
    NSArray *pArray=[NSArray arrayWithContentsOfFile:path];
    for (int i=0; i<pArray.count; i++) {
        NSArray *dArray=pArray[i];
        NSMutableArray *dmArray=[NSMutableArray array];
        for (int j=0; j<dArray.count; j++) {
            NSDictionary *dict=dArray[j];
            PersonCenterModel *model = [PersonCenterModel personCenterModelWithDictionary:dict];
            [dmArray addObject:model];
        }
        [personDataArray addObject:dmArray];
    }
    NSLog(@"个人中心");
    //指定代理
    self.PersonTableView.delegate = self;
    self.PersonTableView.dataSource = self;
    //    [self performSelector:@selector(showDeta) withObject:nil afterDelay:3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestForCount];
    [self.PersonTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

//获取用户信息
- (void)requestPersonCenter:(NSInteger)number
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
}
//编辑按钮(已取消)
- (IBAction)doHeadBut:(id)sender {
    if (![[UserInfo shareUserInfo] isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    [self presentCameraVC];
  
}

- (void)requestForCount
{
    if (![[UserInfo shareUserInfo] isLogin]) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@UserInfoCount.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager POST:url parameters:@{@"key":[UserInfo shareUserInfo].userKey} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [[UserInfo shareUserInfo] parseCount:result];
            [self.PersonTableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

//更换头像
- (void)selectImageFinished:(NSData *)image
{
    UIImage *image1 = [UIImage imageWithData:image];
    NSLog(@"%@, %ld", NSStringFromCGSize(image1.size), (unsigned long)image.length);
    
    [self.PersonTableView reloadData];
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@UploadHeader.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey,@"Key",image, @"ImageDatas", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
           imagedata = image1;
            [self.PersonTableView reloadData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return personDataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0.1;
    }
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
        return 0.1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray  *dArray=personDataArray[section];
    return dArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120;
    }else{
        return 45;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    user=[UserInfo shareUserInfo];
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topCell forIndexPath:indexPath];
        
        UIImageView *viewBG = (UIImageView *)[cell viewWithTag:2];
        UILabel *nameLabel = (UILabel*)[cell viewWithTag:3];
        UILabel *levelLabel = (UILabel*)[cell viewWithTag:4];
        UILabel *emailLabel = (UILabel*)[cell viewWithTag:5];
        UILabel *nameTitle = (UILabel*)[cell viewWithTag:6];
        UILabel *levelTitle = (UILabel*)[cell viewWithTag:7];
        UILabel *emailTitle = (UILabel*)[cell viewWithTag:8];
        UILabel *wecomeLabel = (UILabel*)[cell viewWithTag:9];
        UIButton *loginButton = (UIButton*)[cell viewWithTag:10];
        NSString *imageUrl=user.headImage;
        
        if (imageUrl && ![imageUrl isEqualToString:@""]) {
            [viewBG setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
        }else{
            [viewBG setImage:[UIImage imageNamed:@"avatar.png"]];
        }
        if (imagedata) {
            [viewBG setImage:imagedata];
        }
//        self.navigationItem.rightBarButtonItem = ([user isLogin] ? [Utities barButtonItemWithSomething:@"编辑" target:self action:@selector(doEditButton)] : nil);
        nameLabel.text = user.nickName;
        levelLabel.text = user.mobile;
        emailLabel.text = user.email;
        nameLabel.hidden = ![user isLogin];
        levelLabel.hidden = ![user isLogin];
        emailLabel.hidden = ![user isLogin];
        nameTitle.hidden=![user isLogin];
        levelTitle.hidden=![user isLogin];
        emailTitle.hidden=![user isLogin];
        wecomeLabel.hidden=[user isLogin];
        loginButton.hidden=[user isLogin];
        loginButton.layer.cornerRadius=5;
        loginButton.layer.backgroundColor = kRedColor.CGColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        PersonCenterModel *model= personDataArray[indexPath.section][indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listCell forIndexPath:indexPath];
        UIImageView *headerImage = (UIImageView *)[cell viewWithTag:1];
        [headerImage setImage:[UIImage imageNamed:model.headerImage]];
        
        UILabel *title = (UILabel*)[cell viewWithTag:2];
        title.text = model.title;
        
        UILabel *count = (UILabel*)[cell viewWithTag:3];
        count.layer.cornerRadius=8;
        count.textColor=[UIColor whiteColor];
        count.layer.backgroundColor=kRedColor.CGColor;
        if ([model.segueString isEqualToString:@"ShoppingCart"]) {
            [self setCount:[UserInfo shareUserInfo].cartCount label:count];
        }else if ([model.segueString isEqualToString:@"Myletter"]) {
            [self setCount:[UserInfo shareUserInfo].letterCount label:count];
        }else{
            [self setCount:0 label:count];
        }
        UIImageView *footerImage = (UIImageView *)[cell viewWithTag:4];
        [footerImage setImage:[UIImage imageNamed:model.footerImage]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)setCount:(NSInteger)count label:(UILabel*)label
{
    label.hidden = !count;
    label.text = [NSString stringWithFormat:@"%ld", (long)count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    if(indexPath.section == 0){
        return;
    }
    PersonCenterModel *model=personDataArray[indexPath.section][indexPath.row];
    if ([model.segueString isEqualToString:@"NormalOrderList"]) {
        orderType=0;
        [self performSegueWithIdentifier:@"OrderList" sender:self];
        return;
    }else if ([model.segueString isEqualToString:@"CompeteOrderList"]) {
        orderType=10;
        [self performSegueWithIdentifier:@"OrderList" sender:self];
        return;
    }else if([model.segueString isEqualToString:@"ShoppingCart"]) {
        [self.tabBarController setSelectedIndex:3];
        return;
    }
    [self performSegueWithIdentifier:model.segueString sender:self];
}

//跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = segue.destinationViewController;
    vc.hidesBottomBarWhenPushed = YES;
    if ([(OrderListVC *)vc respondsToSelector:@selector(setOrderType:)]) {
        NSString *orderCode=[NSString stringWithFormat:@"%ld",(long)orderType];
        [vc setValue:orderCode forKey:@"orderType"];
    }
}
- (IBAction)loginPress:(UIButton *)sender {
    [Utities presentLoginVC:self];
}
//-(void)doEditButton
//{
//    [self performSegueWithIdentifier:@"PersonDetail" sender:self];
//}
@end

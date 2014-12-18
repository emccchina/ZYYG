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

@implementation PersonCenterVC
{
    NSMutableArray *personDataArray;
    UserInfo *user;
    
}

static NSString *topCell = @"topCell";
static NSString *listCell = @"listCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    user=[UserInfo shareUserInfo];
    [self requestPersonCenter:0];
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
    [self.PersonTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = [segue destinationViewController];
    destVC.hidesBottomBarWhenPushed = YES;
}

- (void)requestPersonCenter:(NSInteger)number
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
}
- (IBAction)doHeadBut:(id)sender {
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return personDataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat hight=5;
    if (section==0) {
        return 1;
    }
    return hight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray  *dArray=personDataArray[section];
    return dArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 125;
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
        if (imageUrl && ![@"" isEqual:imageUrl]) {
            [viewBG setImageWithURL:[NSURL URLWithString:imageUrl]];
        }else{
            [viewBG setImage:[UIImage imageNamed:@"avatar.png"]];
        }
        if ([user isLogin]) {
            self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"编辑" target:self action:@selector(doEditButton)];
            nameLabel.text = user.nickName;
            levelLabel.text = user.realName;
            emailLabel.text = user.email;
            nameLabel.hidden = NO;
            levelLabel.hidden = NO;
            emailLabel.hidden = NO;
            nameTitle.hidden=NO;
            levelTitle.hidden=NO;
            emailTitle.hidden=NO;
            wecomeLabel.hidden=YES;
            loginButton.hidden=YES;
        }else {
            nameLabel.hidden = YES;
            levelLabel.hidden = YES;
            emailLabel.hidden = YES;
            nameTitle.hidden=YES;
            levelTitle.hidden=YES;
            emailTitle.hidden=YES;
            wecomeLabel.hidden=NO;
            loginButton.hidden=NO;
            loginButton.layer.cornerRadius=5;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        PersonCenterModel *model= personDataArray[indexPath.section][indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listCell forIndexPath:indexPath];
        UIImageView *headerImage = (UIImageView *)[cell viewWithTag:1];
        [headerImage setImage:[UIImage imageNamed:model.headerImage]];
        
        UILabel *title = (UILabel*)[cell viewWithTag:2];
        title.text = model.title;
        if(model.count!=nil){
            UILabel *count = (UILabel*)[cell viewWithTag:3];
            count.layer.cornerRadius=8;
            count.textColor=[UIColor whiteColor];
            count.layer.backgroundColor=kRedColor.CGColor;
            //            count.text = model.count;
        }
        
        UIImageView *footerImage = (UIImageView *)[cell viewWithTag:4];
        [footerImage setImage:[UIImage imageNamed:model.footerImage]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    PersonCenterModel *model=personDataArray[indexPath.section][indexPath.row];
    if ([model.segueString isEqualToString:@"ShoppingCart"]) {
        [self.tabBarController setSelectedIndex:3];
        return;
    }
    [self performSegueWithIdentifier:model.segueString sender:self];
}

- (IBAction)loginPress:(UIButton *)sender {
    [Utities presentLoginVC:self];
}
-(void)doEditButton
{
    [self performSegueWithIdentifier:@"PersonDetail" sender:self];
}
@end

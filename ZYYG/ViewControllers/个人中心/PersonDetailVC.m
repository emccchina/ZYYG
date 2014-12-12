//
//  PersonDetailVC.m
//  ZYYG
//
//  Created by champagne on 14-12-8.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PersonDetailVC.h"
#import "UserInfo.h"

@interface PersonDetailVC ()
{
    NSMutableArray *detailArry;
    UserInfo *user;
}

@end

@implementation PersonDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    user =[UserInfo shareUserInfo];
    self.personDetailTableView.delegate = self;
    self.personDetailTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
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
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"personDetail"];
    UITableViewCell *imageCell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"imageCell"];
    switch (indexPath.row) {
        case 0:
            if(user.headImage &&![@"" isEqualToString:user.headImage]){
                [imageCell.imageView setImageWithURL:[NSURL URLWithString:user.headImage]];
            }else{
                [imageCell.imageView setImage:[UIImage imageNamed:@"avatar.png"]];
            }
            imageCell.textLabel.text=@"头像";
            imageCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return imageCell;
            break;
        case 1:
            cell.textLabel.text=@"昵称";
            cell.detailTextLabel.text=user.nickName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 2:
            cell.textLabel.text=@"真实姓名";
            cell.detailTextLabel.text=user.realName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 3:
            cell.textLabel.text=@"性别";
            cell.detailTextLabel.text=([user.gender isEqual:@"0" ]? @"女":@"男");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 4:
            cell.textLabel.text=@"年收入";
            cell.detailTextLabel.text=user.income;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 5:
            cell.textLabel.text=@"手机";
            cell.detailTextLabel.text=user.mobile;

            break;
        case 6:
            cell.textLabel.text=@"邮箱";
            cell.detailTextLabel.text=user.email;
            
            break;
        case 7:
            cell.textLabel.text=@"所在地";
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@+%@+%@" ,user.provideCode,user.cityCode,user.aeraCode];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 8:
            cell.textLabel.text=@"详细地址";
            cell.detailTextLabel.text=user.detailAddress;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 9:
            cell.textLabel.text=@"邮编";
            cell.detailTextLabel.text=user.zipCode;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cell;
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

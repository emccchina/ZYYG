//
//  CompeteRecordVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CompeteRecordVC.h"
#import "CompeteRecordCell.h"
#import "CompeteRecordCellTop.h"

@interface CompeteRecordVC ()

@end

@implementation CompeteRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.competeTableView registerNib:[UINib nibWithNibName:@"CompeteRecordCell" bundle:nil] forCellReuseIdentifier:@"CompeteRecordCell"];
    [self.competeTableView registerNib:[UINib nibWithNibName:@"CompeteRecordCellTop" bundle:nil] forCellReuseIdentifier:@"CompeteRecordCellTop"];
    [self showBackItem];
    self.competeTableView.delegate = self;
    self.competeTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 25;
    }
    return 160;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CompeteRecordCellTop *topCell = (CompeteRecordCellTop *)[tableView dequeueReusableCellWithIdentifier:@"CompeteRecordCellTop" forIndexPath:indexPath];
        return topCell;
    }else{
        CompeteRecordCell *cell = (CompeteRecordCell *)[tableView dequeueReusableCellWithIdentifier:@"CompeteRecordCell" forIndexPath:indexPath];
        [cell.goodsImage setImageWithURL:[NSURL URLWithString:@"http://www.baidu.com/img/bd_logo1.png"]];
        return cell;
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

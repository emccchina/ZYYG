//
//  RecommendedVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MarginMoneyVC.h"
#import "MarginMoneyCell.h"
@interface MarginMoneyVC ()

@end

@implementation MarginMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.recommendedTableView registerNib:[UINib nibWithNibName:@"MarginMoneyCell" bundle:nil] forCellReuseIdentifier:@"MarginMoneyCell"];
    [self showBackItem];
    self.recommendedTableView.delegate = self;
    self.recommendedTableView.dataSource = self;
    
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarginMoneyCell *cell = (MarginMoneyCell*)[tableView dequeueReusableCellWithIdentifier:@"MarginMoneyCell" forIndexPath:indexPath];
    [cell.goodsImage setImageWithURL:[NSURL URLWithString:@"http://www.baidu.com/img/bd_logo1.png"]];
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

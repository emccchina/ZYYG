//
//  CustomVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CustomVC.h"
#import "SpecialDiscuss.h"
#import "ImageScrollCell.h"

@interface CustomVC ()

@end

@implementation CustomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    [self.customTableVIew registerNib:[UINib nibWithNibName:@"SpecialDiscuss" bundle:nil] forCellReuseIdentifier:@"SpecialDiscuss"];
    [self.customTableVIew registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:@"imageCell"];
    
    self.customTableVIew.delegate=self;
    self.customTableVIew.dataSource=self;
    self.customTableVIew.backgroundColor = kRedColor;
    self.title = @"私人定制";
    NSLog(@"私人定制");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollviewImageClick:(NSInteger)index
{
//    NSDictionary *dict = images[index];
}

#pragma mark -tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section ==0)
        return 1;
    return 35;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==3) {
        return 15;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       return CGRectGetWidth(tableView.frame) * 256 / 640;
    }else if (indexPath.section==1 ||indexPath.section==2) {
        return 290;
    }
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ImageScrollCell *scrollCell = (ImageScrollCell*)[tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
        scrollCell.style = 0;
        scrollCell.click = ^(NSInteger index){
            [self scrollviewImageClick:index];
        };
        [scrollCell reloadScrollViewData];
       
        return scrollCell;
    }else if (indexPath.section==1 ||indexPath.section==2) {
        SpecialDiscuss *sCell = (SpecialDiscuss *)[tableView dequeueReusableCellWithIdentifier:@"SpecialDiscuss" forIndexPath:indexPath];
        return sCell;

    }else{
         UITableViewCell *cell = [[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"managerCell" ];
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

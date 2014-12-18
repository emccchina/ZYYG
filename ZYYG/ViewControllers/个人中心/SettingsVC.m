//
//  SettingsVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SettingsVC.h"
#import "SettingModel.h"
@interface SettingsVC ()
{
    NSMutableArray *settingDataArray;
}

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showBackItem];
    //初始化数据
    settingDataArray =[NSMutableArray array];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"SettingsList" ofType:@"plist"];
    NSArray *pArray=[NSArray arrayWithContentsOfFile:path];
    for (int i=0; i<pArray.count; i++) {
        NSArray *dArray=pArray[i];
        NSMutableArray *dmArray=[NSMutableArray array];
        for (int j=0; j<dArray.count; j++) {
            NSDictionary *dict=dArray[j];
            SettingModel *model = [SettingModel settongModelWithDict:dict];
            [dmArray addObject:model];
        }
        [settingDataArray addObject:dmArray];
    }
    self.settingsTableView.delegate=self;
    self.settingsTableView.dataSource=self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingDataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray  *dArray=settingDataArray[section];
    return dArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 20;
   
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingModel *model=settingDataArray[indexPath.section][indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCollectionCell"];
    cell.textLabel.text=model.title;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SettingModel *model=settingDataArray[indexPath.section][indexPath.row];
    if ([model.segueString isEqualToString:@"updatePassword"]) {
        [self performSegueWithIdentifier:model.segueString sender:self];
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

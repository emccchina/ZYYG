//
//  SettingsVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SettingsVC.h"
#import "SettingModel.h"
#import <StoreKit/StoreKit.h>
@interface SettingsVC ()
<SKStoreProductViewControllerDelegate>
{
    NSMutableArray *settingDataArray;
}

@end

@implementation SettingsVC
#define kAppID  @"414245413"//@"952611536"
#define APP_URL @"http://itunes.apple.com/lookup?id="kAppID

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

- (BOOL)compareVersions:(NSDictionary*)dict
{
    NSArray *infoArray = [dict objectForKey:@"results"];
    if (infoArray.count) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *latestVersion = [releaseInfo objectForKey:@"version"];
        
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        
        NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
        
        NSLog(@"%@,%@", appVersion, latestVersion);
        if ([appVersion isEqualToString:latestVersion]) {
            return YES;
        }
    }
    return NO;
}

- (void)requestForVersion
{
    [self showIndicatorView:nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = APP_URL;
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSLog(@"reuslt is %@", result);
            if ([self compareVersions:result]) {
                [self showAlertView:@"已经是最新版本"];
            }else{
                [self showAlertView:@"有新版本,是否更新"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)doAlertView
{
    [self evaluate];
}
- (void)evaluate{
    
    [self showIndicatorView:nil];
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId
     @{SKStoreProductParameterITunesItemIdentifier : kAppID} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         [self dismissIndicatorView];
         if(error){
             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
         }else{
             //模态弹出AppStore应用界面
             [self presentViewController:storeProductViewContorller animated:YES completion:^{
                 
             }
              ];
         }
     }];
}

//取消按钮监听方法
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
    }else if ([model.segueString isEqualToString:@"checkUpdate"]){
        [self requestForVersion];
    }else if ([model.segueString isEqualToString:@"scaleMark"]){
        [self evaluate];
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

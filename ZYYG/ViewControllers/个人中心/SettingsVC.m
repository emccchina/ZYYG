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
#define kAppID  @"952611536"
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
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
        
        NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        
        NSLog(@"%@,%@，，，，，%@", appVersion, latestVersion, infoDic);
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
            if ([self compareVersions:result]) {
                [self showAlertView:@"已经是最新版本"];
            }else{
                [self showAlertViewTwoBut:@"温馨提示" message:@"有新版本,是否更新" actionTitle:@"确定"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)doAlertViewTwo
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

- (IBAction)doLogoutBut:(id)sender {
    [[UserInfo shareUserInfo] loginOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteFailed
{
    [self showAlertView:@"删除失败"];
}

- (void)deleteFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//需要的路径
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"tem"];
    BOOL isDict = YES;
    if ([fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDict]) {
        NSError *error = nil;
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        NSArray* fileList = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
        //    DLog(@"%@", fileList);
        if (error) {
            [self deleteFailed];
        }
        for (NSString* pathName in fileList){
            NSString *databaseFile = [documentsDirectory stringByAppendingPathComponent:pathName];
            if ([fileManager isDeletableFileAtPath:databaseFile]){
                BOOL remove = [fileManager removeItemAtPath:databaseFile error:nil];
                if (!remove) {
                    NSLog(@"files delete failed");
                    [self deleteFailed];
                    return;
                }
            }
        }
        
        [self showAlertView:@"删除成功"];
        
    }else{
        [self showAlertView:@"删除成功"];
    }

}

#pragma mark -tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingDataArray.count+1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == settingDataArray.count) {
        return 1;
    }
    NSArray  *dArray=settingDataArray[section];
    return dArray.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == settingDataArray.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCell" forIndexPath:indexPath];
//        UIButton *logoutBut= (UIButton*)[cell viewWithTag:1];
//        logoutBut.layer.cornerRadius = 5;
//        logoutBut.layer.backgroundColor = kRedColor.CGColor;
        return cell;
    }else{
        SettingModel *model=settingDataArray[indexPath.section][indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
        cell.textLabel.text=model.title;
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        return cell;
    }
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == settingDataArray.count) {
        [self doLogoutBut:nil];
        return;
    }
    SettingModel *model=settingDataArray[indexPath.section][indexPath.row];
    if ([model.segueString isEqualToString:@"updatePassword"]) {
        [self performSegueWithIdentifier:model.segueString sender:self];
    }else if ([model.segueString isEqualToString:@"checkUpdate"]){
        [self requestForVersion];
    }else if ([model.segueString isEqualToString:@"scaleMark"]){
        [self evaluate];
    }else if ([model.segueString isEqualToString:@"clearCache"]){
        [self deleteFile];
    }
}


@end

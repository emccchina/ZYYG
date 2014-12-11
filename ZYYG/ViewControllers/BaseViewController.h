//
//  BaseViewController.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHRefresh.h"

#define kNetworkNotConnect    @"网络不给力,请稍候再试"
#define kNetworkConnecting    @"玩命加载中..."
@interface BaseViewController : UIViewController

@property (nonatomic, assign) NSInteger   index;//测试customModel 转场数据

- (void)showIndicatorView:(NSString*)text;//现实指示器
- (void)dismissIndicatorView;//

- (void)showBottomAlertView:(NSString*)message;

- (void)showBackItem;//返回按钮

- (void)showAlertView:(NSString*)message;//显示弹出框
- (void)doAlertView;

- (id)parseResults:(id)resultResponds;


//打开相机
- (void)presentCameraVC;
- (void)selectImageFinished:(UIImage*)image;

@end

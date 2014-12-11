//
//  AppDelegate.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL        showMore;//是否显示更多的内容
}

@property (strong, nonatomic) UIWindow *window;

- (void)showPopView;
@end


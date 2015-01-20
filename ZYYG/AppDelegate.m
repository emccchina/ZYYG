//
//  AppDelegate.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "AppDelegate.h"
#import "TSPopoverController.h"
#import "PopView.h"
#import "MyView/MyNavigationController.h"
#import "NSString+AES.h"

@interface AppDelegate ()
<UITabBarControllerDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITabBarController *VC = (UITabBarController*)self.window.rootViewController;
    VC.delegate = self;
    
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];

    NSString *s = @"12345";
    NSString *e = [s AES256EncryptWithKey:@"0123456789012345"];
    NSLog(@"e is %@,%@", e,[Utities md5AndBase:s]);
    NSString *e2 = [e AES256DecryptWithKey:@"0123456789012345"];
    NSLog(@"e2 is %@", e2);
    return YES;
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSString *title = viewController.tabBarItem.title;
    if ([title isEqualToString:@"更多"]) {
        [self showPopView];
        return NO;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"terminate");
    NSArray *array = [NSArray array];
    [array writeToFile:[Utities filePathName:kClassifyArr] atomically:YES];//清空
    [array writeToFile:[Utities filePathName:kHotSearchArr] atomically:YES];//清空
}


- (void)presentMoreGroup:(NSString*)identifier
{
    UITabBarController *VC = (UITabBarController*)self.window.rootViewController;
    MyNavigationController *view5 = [[UIStoryboard storyboardWithName:@"MoreStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    [VC presentViewController:view5 animated:YES completion:nil];

}

- (void)showPopView
{
    NSArray *titles = @[@"私人定制", @"私人洽购"];
    UITabBarController *VC = (UITabBarController*)self.window.rootViewController;
    NSLog(@"tabbar.frame %@, %f, %f", NSStringFromCGRect(VC.tabBar.frame), VC.tabBar.itemWidth, VC.tabBar.itemSpacing);
    CGRect rect = VC.tabBar.frame;
    rect.origin.x = rect.size.width-100;
    rect.origin.y += 20;
    rect.size.width = 140;
    rect.size.height = kPopCellHegith*titles.count;
    
    PopView *popView = [[PopView alloc] initWithFrame:CGRectMake(0, 0, 110, kPopCellHegith*titles.count) titles:titles];
    popView.type = 1;
    TSPopoverController *popoverController = [[TSPopoverController alloc] initWithView:popView];
    popoverController.cornerRadius = 2;
    //    popoverController.titleText = @"change order";
    popoverController.popoverBaseColor = kBGGrayColor;
    popoverController.popoverGradient= NO;
    //    popoverController.arrowPosition = TSPopoverArrowPositionHorizontal;
    [popoverController showPopoverWithRect:rect];
    
    popView.selectedFinsied = ^(NSInteger row){
        NSLog(@"%ld", (long)row);
        [popoverController dismissPopoverAnimatd:YES];
        NSArray *indentifiers = @[@"CustomVC", @"TalkBuyVC"];
        [self presentMoreGroup:indentifiers[row]];
    };
}

@end

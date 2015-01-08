//
//  MyTabbarController.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "MyTabbarController.h"

@interface MyTabbarController ()

@end

@implementation MyTabbarController

- (void)awakeFromNib
{
    UIViewController *view1 = [self viewControllerFormStoryboard:@"FairPriceStoryboard"];
    view1.tabBarItem = [self tabBarItemWithTitle:@"平价交易" image:[UIImage imageNamed:@"fairGray"] selectedImage:[UIImage imageNamed:@"fairRed"]];
    
    UIViewController *view2 = [self viewControllerFormStoryboard:@"CompeteStoryboard"];
    view2.tabBarItem = [self tabBarItemWithTitle:@"线上竞价" image:[UIImage imageNamed:@"completeGray"] selectedImage:[UIImage imageNamed:@"completeRed"]];
    
    UIViewController *view3 = [self viewControllerFormStoryboard:@"PersonCenterStoryboard"];
    view3.tabBarItem = [self tabBarItemWithTitle:@"个人中心" image:[UIImage imageNamed:@"personGray"] selectedImage:[UIImage imageNamed:@"personRed"]];
    
    UIViewController *view4 = [self viewControllerFormStoryboard:@"ShopCartStoryboard"];
    view4.tabBarItem = [self tabBarItemWithTitle:@"购物车" image:[UIImage imageNamed:@"ShoppingGray"] selectedImage:[UIImage imageNamed:@"ShoppingRed"]];
    
    UIViewController *view5 = [[UIViewController alloc] init];
    view5.tabBarItem = [self tabBarItemWithTitle:@"更多" image:[UIImage imageNamed:@"moreGray"] selectedImage:[UIImage imageNamed:@"moreRed"]];
////    UIViewController *view5 = [[UIStoryboard storyboardWithName:@"MoreStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CustomVC"];
////    view5.tabBarItem = [self tabBarItemWithTitle:@"私人定制" image:[UIImage imageNamed:@"privateCustomGray"] selectedImage:[UIImage imageNamed:@"privateCustomRed"]];
////    UIViewController *view6 = [[UIStoryboard storyboardWithName:@"MoreStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"TalkBuyVC"];
//    view6.tabBarItem = [self tabBarItemWithTitle:@"私人洽购" image:[UIImage imageNamed:@"privateTalkGray"] selectedImage:[UIImage imageNamed:@"privateTalkRed"]];
    self.viewControllers = [NSArray arrayWithObjects:view1,view2, view3, view4,view5, nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITabBarItem*)tabBarItemWithTitle:(NSString*)title image:(UIImage*)image selectedImage:(UIImage*)selectImage
{
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectImage];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  kRedColor, NSForegroundColorAttributeName,
                                  nil] forState:UIControlStateSelected];
    return item;
}

- (UIViewController*)viewControllerFormStoryboard:(NSString*)name
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:name bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    return vc;
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

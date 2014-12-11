//
//  CustomModel.m
//  Demo
//
//  Created by wu on 14/11/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CustomModel.h"
#import "BaseViewController.h"

@implementation CustomModel

- (void)perform
{
    BaseViewController *src = (BaseViewController *)self.sourceViewController;
//    NSLog(@"%d", ((LoginVC*)src).index);//传值
    BaseViewController *dest = (BaseViewController *)self.destinationViewController;
    dest.hidesBottomBarWhenPushed = YES;
    [src.navigationController pushViewController:dest animated:YES];
    [src.navigationController.view.layer addAnimation:[Utities getAnimation:3] forKey:nil];
    
}



@end

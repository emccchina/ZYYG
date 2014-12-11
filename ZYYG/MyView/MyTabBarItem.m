//
//  MyTabBarItem.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "MyTabBarItem.h"

@implementation MyTabBarItem

- (void)awakeFromNib
{
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                  nil] forState:UIControlStateSelected];
    
//    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                  [UIColor greenColor], NSForegroundColorAttributeName,
//                                  nil] forState:UIControlStateNormal];
}

@end

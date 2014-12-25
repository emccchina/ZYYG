//
//  PayManager.m
//  ZYYG
//
//  Created by EMCC on 14/12/25.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PayManager.h"
#import "PaaCreater.h"
@implementation PayManager

- (void)payforWithTarget:(UIViewController *)newVC orderNumber:(NSString *)orederNumber selector:(SEL)newAction
{
    self.action = newAction;
    self.vc = newVC;
}

- (void)APayResult:(NSString*)result
{
    if ([self.vc respondsToSelector:self.action]) {
        IMP imp = [self.vc methodForSelector:self.action];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self.vc, self.action, result);
    }
}

@end

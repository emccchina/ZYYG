//
//  PayManager.h
//  ZYYG
//
//  Created by EMCC on 14/12/25.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APay.h"
#import "PaaCreater.h"
//支付
typedef void (^PayforFinished) (id result);
@interface PayManager : UIView
<APayDelegate>
{
}

- (void)payforWithTarget:(UIViewController*)newVC orderNumber:(NSString*)orederNumber selector:(SEL)newAction;

@property (nonatomic, copy) PayforFinished finished;
@property (nonatomic, assign) UIViewController *vc;
@property (nonatomic, assign) SEL   action;

@end

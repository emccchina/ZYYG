//
//  APayLib.h
//  APayLib
//
//  Created by allinpay-shenlong on 14-5-26.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, APayResult)
{
    APayResultSuccess = 0,
    APayResultFail = 1,
    APayResultCancel = -1,
};

@protocol APayDelegate <NSObject>

- (void)APayResult:(NSString*)result;

@end


@interface APay : NSObject

+ (void)startPay:(NSString *)payData viewController:(UIViewController *)viewController delegate:(id<APayDelegate>)delegate mode:(NSString*)mode;

@end


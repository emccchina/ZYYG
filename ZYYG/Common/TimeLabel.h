//
//  TimeLabel.h
//  ZYYG
//
//  Created by EMCC on 15/1/9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TimeLabel : UILabel
{
    CADisplayLink           *_countDownTimer;
    NSTimeInterval          startCount;
    NSTimeInterval          endCount;
}

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, assign) NSInteger status;//0 开始   1 计时中   2 结束
@property (nonatomic, strong) NSString *timeCount;
- (void)start;

@end

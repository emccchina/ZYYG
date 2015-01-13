//
//  TimeLabel.m
//  ZYYG
//
//  Created by EMCC on 15/1/9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "TimeLabel.h"

@implementation TimeLabel

- (void)dealloc
{
    if (_countDownTimer) {
        [_countDownTimer invalidate];
        [_countDownTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    _countDownTimer = nil;
}

- (void)setStartTime:(NSString *)startTime
{
    startCount = [self intervalFromDateString:startTime];
}

- (void)setEndTime:(NSString *)endTime
{
    endCount = [self intervalFromDateString:endTime];
}

- (NSTimeInterval)intervalFromDateString:(NSString*)timeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat: @"yyyy/MM/dd HH:mm:ss"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
    NSDate *destDate= [dateFormatter dateFromString:timeString];
//    NSLog(@"%@,....%@", destDate, [self getNowDateFromatAnDate:[NSDate date]]);
    return [destDate timeIntervalSinceDate:[self getNowDateFromatAnDate:[NSDate date]]];
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

- (NSString*)HHMMSSFromCount:(NSTimeInterval)count
{
    count = fabs(count);
    NSInteger HH = count / 60/60;
    NSInteger MM = (count - HH*60*60)/60;
    NSInteger SS = (count - HH*60*60 - MM*60);
    return [NSString stringWithFormat:@"%02ld时%02ld分%02ld秒", (long)HH,(long)MM,(long)SS];
}

- (void)start
{
    if (!_countDownTimer) {
        _countDownTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(countDown)];
        _countDownTimer.frameInterval = 60;//CADisplayLink 默认每秒运行60次，将它的frameInterval属性设置为60 CADisplayLink每隔60帧运行一次
    }
    
    [_countDownTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)countDown
{
//    NSLog(@"%f，，，%p",[[NSDate date] timeIntervalSince1970], self);
    
    if (endCount < 0){
        self.status = 2;
        self.timeCount = @"已结束";
        self.text = self.timeCount;
        [_countDownTimer invalidate];
        _countDownTimer = nil;
    }else{
        if (startCount > 0) {
            self.timeCount = [NSString stringWithFormat:@"距开始:%@", [self HHMMSSFromCount:startCount]];
            self.text = self.timeCount;
        }else{
            self.status = 1;
            self.timeCount = [NSString stringWithFormat:@"距结束:%@", [self HHMMSSFromCount:endCount]];
            self.text = self.timeCount;
        }
    }
    endCount -= 1;
    startCount -= 1;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

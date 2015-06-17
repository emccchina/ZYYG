//
//  BiddingInfoCell.h
//  ZYYG
//
//  Created by EMCC on 15/1/10.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"
typedef void (^doLeftButFinished)();
typedef void (^doRightButFinished)();
//竞价的状态  竞价详情中使用
@interface BiddingInfoCell : UITableViewCell
{
    BOOL _collectState;
}

@property (weak, nonatomic) IBOutlet UILabel *LTLabel;
@property (weak, nonatomic) IBOutlet UILabel *LSLabel;

@property (weak, nonatomic) IBOutlet UILabel *LFourthLabel;
@property (weak, nonatomic) IBOutlet UILabel *LThirstLabel;
@property (weak, nonatomic) IBOutlet TimeLabel *LFifthLabel;
@property (weak, nonatomic) IBOutlet UILabel *LXLabel;

@property (weak, nonatomic) IBOutlet UILabel *RSLabel;
@property (weak, nonatomic) IBOutlet UILabel *RThirstLabel;
@property (weak, nonatomic) IBOutlet UIButton *LBut;
@property (weak, nonatomic) IBOutlet UIButton *RBut;
@property (copy, nonatomic) doLeftButFinished  Lfinished;
@property (copy, nonatomic) doRightButFinished Rfinished;
@property (assign, nonatomic) BOOL collectState;
@end

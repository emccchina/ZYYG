//
//  BiddingInfoCell.m
//  ZYYG
//
//  Created by EMCC on 15/1/10.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "BiddingInfoCell.h"

@implementation BiddingInfoCell

- (void)awakeFromNib {
    // Initialization code
    createTopLine
    createBottomLine
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.RBut.layer.cornerRadius = 2;
    self.RBut.layer.backgroundColor = kRedColor.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)doLBut:(id)sender {
    if (self.Lfinished) {
        self.Lfinished();
    }
}
- (IBAction)doRBut:(id)sender {
    if (self.Rfinished) {
        self.Rfinished();
    }
}

- (void)setCollectState:(BOOL)collectState
{
    _collectState = collectState;
    UIColor *color = collectState ? kRedColor : kLightGrayColor;
    UIImage *image = collectState ? [UIImage imageNamed:@"collectRed"] : [UIImage imageNamed:@"collectGray"];
    [self.LBut setTitleColor:color forState:UIControlStateNormal];
    [self.LBut setImage:image forState:UIControlStateNormal];
}

@end

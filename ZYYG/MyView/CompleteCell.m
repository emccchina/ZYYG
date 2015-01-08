//
//  CompleteCell.m
//  ZYYG
//
//  Created by EMCC on 15/1/8.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "CompleteCell.h"

@implementation CompleteCell

- (void)awakeFromNib {
    // Initialization code
    createTopLine
    [self.image.layer setCornerRadius:2];
    [self.image.layer setBorderWidth:1.0/[UIScreen mainScreen].scale];
    [self.image.layer setBorderColor:kLightGrayColor.CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(NSInteger)type
{
    self.LSLabel.hidden = !type;
    self.RSLabel.hidden = !type;
    self.RTLabel.hidden = !type;
    self.LFoLabel.hidden = type;
    self.RFLabel.hidden = !type;
}

//红色否
- (void)setFourLableState:(BOOL)fourLableState
{
    self.LFoLabel.textColor = fourLableState ? kRedColor : kBlackColor;
}

@end

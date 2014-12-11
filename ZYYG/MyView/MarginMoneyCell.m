//
//  MarginMoneyCell.m
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MarginMoneyCell.h"

@implementation MarginMoneyCell

- (void)awakeFromNib {
    // Initialization code
    createTopLine
    createBottomLine
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

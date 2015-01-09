//
//  CompeteRecordCell.m
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CompeteRecordCell.h"

@implementation CompeteRecordCell

- (void)awakeFromNib {
    // Initialization code
    createBottomLine
    self.bidButton.layer.backgroundColor=kRedColor.CGColor;
    self.bidButton.layer.cornerRadius=3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

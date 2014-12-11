//
//  CollectCell.m
//  ZYYG
//
//  Created by EMCC on 14/11/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CollectCell.h"

@implementation CollectCell


- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    createBottomLine;
    
    createTopLine
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSpread:(BOOL)spread
{
    self.botLab.hidden = !spread;
    self.botRightLab.hidden = !spread;
}

- (void)setCollectState:(BOOL)collectState
{
    _collectState = collectState;
    UIColor *color = collectState ? kRedColor : kLightGrayColor;
    [self.rightBut setTitleColor:color forState:UIControlStateNormal];
}

- (IBAction)collectPressed:(id)sender {
    if (self.colloct) {
        self.colloct(!_collectState);//与原状态相反
    }
}
@end

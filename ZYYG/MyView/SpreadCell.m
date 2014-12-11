//
//  SpreadCell.m
//  ZYYG
//
//  Created by EMCC on 14/11/26.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SpreadCell.h"

@implementation SpreadCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    createTopLine
    createBottomLine
    self.detailLab.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)spreadButtonPressed:(id)sender {
    _spreadState = !_spreadState;
    if (self.reloadHeight) {
        self.reloadHeight(_spreadState);
    }
    
}

- (void)setSpreadState:(BOOL)spreadState
{
    _spreadState = spreadState;
    self.detailLab.hidden = !_spreadState;
    UIImage *image = _spreadState ? [UIImage imageNamed:@"down"] : [UIImage imageNamed:@"left"];
    [self.spreadButton setImage:image forState:UIControlStateNormal];
}


@end

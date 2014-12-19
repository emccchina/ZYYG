//
//  CartCell.m
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CartCell.h"

@implementation CartCell

- (void)awakeFromNib {
    // Initialization code
//    createBottomLine
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bottomView.layer.borderColor = kLightGrayColor.CGColor;
    self.bottomView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectButPressed:(id)sender {
    _selectState = !_selectState;
    [self changeButImage:_selectState];
    if (self.doSelected) {
        self.doSelected(self.indexPath, _selectState);
    }
}

- (void)setCellType:(BOOL)cellType
{
    self.selectBut.hidden = cellType;
    self.bottomView.hidden = cellType;
    self.validLab.hidden = cellType;
}
- (void)setValid:(BOOL)valid
{
    self.selectBut.hidden = !valid;
    self.validLab.hidden = valid;
}
- (void)setSelectState:(BOOL)selectState
{
    _selectState = selectState;
    [self changeButImage:_selectState];
}

- (void)changeButImage:(BOOL)selected
{
    UIImage *image = selected ? [UIImage imageNamed:@"circleSelected"] : [UIImage imageNamed:@"circleUnselected"];
    [self.selectBut setImage:image forState:UIControlStateNormal];
    
}

@end

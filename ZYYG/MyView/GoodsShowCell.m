//
//  GoodsShowCell.m
//  ZYYG
//
//  Created by wu on 14/11/22.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "GoodsShowCell.h"

@implementation GoodsShowCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.leftImage.layer setCornerRadius:2];
    [self.leftImage.layer setBorderWidth:1.0/[UIScreen mainScreen].scale];
    [self.leftImage.layer setBorderColor:kLightGrayColor.CGColor];
    
    [self.rightImage.layer setCornerRadius:2];
    [self.rightImage.layer setBorderWidth:1.0/[UIScreen mainScreen].scale];
    [self.rightImage.layer setBorderColor:kLightGrayColor.CGColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)leftButPressed:(id)sender {
    NSLog(@"left button pressed");
    if ([self.delegate respondsToSelector:@selector(imageViewPressed:position:)]) {
        [self.delegate imageViewPressed:self.indexPath position:0];
    }
}
- (IBAction)rightButPressed:(id)sender {
    NSLog(@"right button pressed");
    if ([self.delegate respondsToSelector:@selector(imageViewPressed:position:)]) {
        [self.delegate imageViewPressed:self.indexPath position:1];
    }
}

- (void)setShowRight:(BOOL)newShowRight
{
    self.rightImage.hidden = !newShowRight;
    self.rightBut.hidden = !newShowRight;
    self.RTLab.hidden = !newShowRight;
    self.RMLab.hidden = !newShowRight;
    self.RBLab.hidden = !newShowRight;
}

@end

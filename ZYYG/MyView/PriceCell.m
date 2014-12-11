//
//  PriceCell.m
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PriceCell.h"

@implementation PriceCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    createBottomLine
    
    [self.leftBut setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.leftBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [self.rightBut setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.rightBut setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    //中间线
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor blackColor];
    line.alpha = 0.3;
    [self addSubview:line];
    [line setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [line addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1/[UIScreen mainScreen].scale]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)leftButPressed:(id)sender {
    if (self.buttonSeleced) {
        self.buttonSeleced(0, self.indexPath);
    }
    NSLog(@"lelft");
}
- (IBAction)rightButPressed:(id)sender {
    NSLog(@"right");
    if (self.buttonSeleced) {
        self.buttonSeleced(1, self.indexPath);
    }
}

@end

//
//  AuctionArtCell.m
//  ZYYG
//
//  Created by EMCC on 15/1/9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "AuctionArtCell.h"

@implementation AuctionArtCell

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

@end

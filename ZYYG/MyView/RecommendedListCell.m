//
//  RecommendedListCell.m
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "RecommendedListCell.h"

@implementation RecommendedListCell

- (void)awakeFromNib {
    // Initialization code
    createTopLine
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)collect:(UIButton *)sender {
}
@end

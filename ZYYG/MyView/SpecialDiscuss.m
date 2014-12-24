//
//  SpecialDiscuss.m
//  ZYYG
//
//  Created by champagne on 14-12-24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SpecialDiscuss.h"

@implementation SpecialDiscuss

- (void)awakeFromNib {
    // Initialization code
    [self.L1Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    [self.L2Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    [self.L3Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    [self.L4Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    self.tit1.text=@"支付";
    self.lab1.text=@"支付";
    self.tit2.text=@"支付";
    self.lab2.text=@"支付";
    self.tit3.text=@"支付";
    self.lab3.text=@"支付";
    self.tit4.text=@"支付";
    self.lab4.text=@"支付";
    [self.M1Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    [self.M2Image setImage:[UIImage imageNamed:@"sinaLoge"]];
    [self.M3Image setImage:[UIImage imageNamed:@"sinaLoge"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

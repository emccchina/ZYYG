//
//  MarginChooseView.m
//  ZYYG
//
//  Created by EMCC on 15/1/10.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "MarginChooseView.h"

@implementation MarginChooseView

- (void)awakeFromNib
{
    self.inputTF.delegate = self;
    self.marignBut.layer.cornerRadius = 2;
    self.marignBut.layer.backgroundColor = kRedColor.CGColor;
}


- (IBAction)doReduceBut:(id)sender {
}
- (IBAction)doAddBut:(id)sender {
}
- (IBAction)doHightestBut:(id)sender {
}
- (IBAction)doMarginBut:(id)sender {
}


@end

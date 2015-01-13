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
    self.inputTF.delegate = self;
    self.inputTF.returnKeyType = UIReturnKeyDone;
}


- (IBAction)doReduceBut:(id)sender {
}
- (IBAction)doAddBut:(id)sender {
}
- (IBAction)doHightestBut:(id)sender {
}
- (IBAction)doMarginBut:(id)sender {
    if (self.gotoMargin) {
        self.gotoMargin();
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(MyTextField *)textField
{
    NSLog(@"bigin tf");
    textField.superRect = self.superview.frame;
    CGRect rect = self.superview.frame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [textField.superview bringSubviewToFront:;];
    
}



@end

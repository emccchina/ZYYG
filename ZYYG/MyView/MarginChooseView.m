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
    self.inputTF.keyboardType = UIKeyboardTypeNumberPad;
//    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
//    [topView setBarStyle:UIBarStyleDefault];
//    
//    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doFinish)];
//    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace, doneButton, nil];
//    
//    [topView setItems:buttonsArray];
//    [self.inputTF setInputAccessoryView:topView];
}

- (void)doFinish
{
    [self.inputTF resignFirstResponder];
}

- (void)setMinMoney:(double)minMoney
{
    _minMoney = minMoney;
    self.inputTF.text = [NSString stringWithFormat:@"%.2f", self.appendMoney+_minMoney];
}

- (void)changeMoney:(BOOL)state  //0 reduce    1 add
{
    if (!state) {
        if ([self.inputTF.text doubleValue] <= (_minMoney+self.appendMoney)) {
            return;
        }
    }
    NSLog(@"%f,,,,,%f,,,,,,%f", [self.inputTF.text doubleValue], self.appendMoney, [self.inputTF.text doubleValue]+self.appendMoney);
    NSString *string = state ? [NSString stringWithFormat:@"%.2f", [self.inputTF.text doubleValue]+self.appendMoney]:[NSString stringWithFormat:@"%.2f", [self.inputTF.text doubleValue]-self.appendMoney];
    
    self.inputTF.text = string;
    
}

- (IBAction)doReduceBut:(id)sender {
    [self changeMoney:NO];
}
- (IBAction)doAddBut:(id)sender {
    [self changeMoney:YES];
}
- (IBAction)doHightestBut:(id)sender {
}
- (IBAction)doMarginBut:(id)sender {
    if (self.gotoMargin) {
        self.gotoMargin(_type);
    }
}

- (void)setButState:(BOOL)enable
{
    self.marignBut.enabled = enable;
    self.addBut.enabled = enable;
    self.reduceBut.enabled = enable;
    self.inputTF.enabled = NO;
    self.hightestBut.enabled = enable;
}

- (void)setType:(NSInteger)type
{
    _type = type;
    switch (type) {
        case 0:
        {
            [self.marignBut setTitle:@"交保证金" forState:UIControlStateNormal];
            [self setButState:YES];
        }
            break;
        case 1:{
            [self.marignBut setTitle:@"尚未开始" forState:UIControlStateNormal];
            [self setButState:NO];
            [self.marignBut.layer setBackgroundColor:kLightGrayColor.CGColor];
        }break;
        case 2:{
            [self.marignBut setTitle:@"我要出价" forState:UIControlStateNormal];
            [self.marignBut.layer setBackgroundColor:kRedColor.CGColor];
            [self setButState:YES];
        }break;
        case 3:{
            [self.marignBut setTitle:@"已成交" forState:UIControlStateNormal];
            [self.marignBut.layer setBackgroundColor:kLightGrayColor.CGColor];
            [self setButState:NO];
        }break;
        case 4:{
            [self.marignBut setTitle:@"已流拍" forState:UIControlStateNormal];
            [self.marignBut.layer setBackgroundColor:kLightGrayColor.CGColor];
            [self setButState:NO];
        }
        default:
            break;
    }
}

- (NSInteger)type
{
    return _type;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(MyTextField *)textField
{
    NSLog(@"bigin tf");
    textField.superRect = textField.superview.superview.frame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [textField.superview bringSubviewToFront:;];
    
}



@end

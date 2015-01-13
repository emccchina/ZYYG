//
//  MyTextField.m
//  ZYYG
//
//  Created by EMCC on 14/12/23.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //注册键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

#pragma mark keyboardNotification

- (void)keyboardWillShow:(NSNotification*)notification{
    if (self.superRect.origin.y <= 0) {
        return;
    }
    NSLog(@"%@", NSStringFromCGRect(self.superRect));
    NSLog(@"keyboard info %@", notification.userInfo);
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat u = CGRectGetMaxY(self.superRect);
    //如果self在键盘之下 才做偏移
    if (CGRectGetMaxY(self.superRect)>=_keyboardRect.origin.y)
        {
            [UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 CGRect re = self.superRect;
                                 re.origin.y = _keyboardRect.origin.y-self.superRect.size.height;
                                 self.superview.transform = CGAffineTransformMakeTranslation(0, -_keyboardRect.size.height);
                             } completion:nil];
            
            
        }

}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.superview.transform = CGAffineTransformMakeTranslation(0, 0);
                     } completion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  UpdatePassVC.h
//  ZYYG
//
//  Created by champagne on 14-12-18.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface UpdatePassVC : BaseViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *passOld;
@property (weak, nonatomic) IBOutlet UITextField *passNew;
@property (weak, nonatomic) IBOutlet UITextField *passAgain;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)pressButton:(id)sender;

@end

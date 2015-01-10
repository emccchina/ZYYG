//
//  MarginChooseView.h
//  ZYYG
//
//  Created by EMCC on 15/1/10.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^GoToPayMargin)();

@interface MarginChooseView : UIView
<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *reduceBut;
@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (weak, nonatomic) IBOutlet UIButton *addBut;
@property (weak, nonatomic) IBOutlet UIButton *hightestBut;
@property (weak, nonatomic) IBOutlet UIButton *marignBut;

@property (weak, nonatomic) IBOutlet NSObject *dd;
@property (nonatomic, copy) GoToPayMargin  gotoMargin;

@end

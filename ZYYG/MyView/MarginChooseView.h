//
//  MarginChooseView.h
//  ZYYG
//
//  Created by EMCC on 15/1/10.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTextField.h"
typedef void (^GoToPayMargin)(NSInteger state);

@interface MarginChooseView : UIView
<UITextFieldDelegate>
{
    double    _minMoney;
    NSInteger _type;
}
@property (weak, nonatomic) IBOutlet UIButton *reduceBut;
@property (weak, nonatomic) IBOutlet MyTextField *inputTF;
@property (weak, nonatomic) IBOutlet UIButton *addBut;
@property (weak, nonatomic) IBOutlet UIButton *hightestBut;
@property (weak, nonatomic) IBOutlet UIButton *marignBut;
@property (nonatomic, assign) double minMoney;
@property (weak, nonatomic) IBOutlet NSObject *dd;
@property (nonatomic, copy) GoToPayMargin  gotoMargin;

@property (nonatomic, assign) NSInteger type;//0交保证金  1 尚未开始   2我要出价   3已成交灰色不能点
@property (nonatomic, assign) double appendMoney;
@end

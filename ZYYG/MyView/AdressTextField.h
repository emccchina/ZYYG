//
//  AdressTextField.h
//  ZYYG
//
//  Created by EMCC on 14/12/15.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@class AdressTextField;

typedef void (^AdressFinished)(AdressTextField *textField);//省 市 区 的数组

@interface AdressTextField : UITextField
<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    FMDatabase          *dataBase;
    NSArray             *areaArr;//各个地区
    NSArray             *townArr;
    NSArray             *cityArr;
    NSMutableArray      *selectAreaArr;
    UIPickerView        *picker;//
}

@property (nonatomic, strong) NSArray *provience;
@property (nonatomic, strong) NSArray *city;
@property (nonatomic, strong) NSArray *town;
@property (nonatomic, copy) AdressFinished editFinished;


@end

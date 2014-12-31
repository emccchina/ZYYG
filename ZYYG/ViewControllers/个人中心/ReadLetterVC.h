//
//  ReadLetterVC.h
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "LetterModel.h"
//阅读站内信
@interface ReadLetterVC : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *letterFrom;
@property (weak, nonatomic) IBOutlet UILabel *letterTitle;
@property (weak, nonatomic) IBOutlet UILabel *letterCreateTime;
@property (weak, nonatomic) IBOutlet UIWebView *letterContent;
@property (nonatomic, strong)  LetterModel *letter;
@property (nonatomic, strong)  NSString *letterCode;

@end

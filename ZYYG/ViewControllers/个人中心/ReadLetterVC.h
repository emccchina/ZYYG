//
//  ReadLetterVC.h
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "LetterModel.h"

@interface ReadLetterVC : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *from;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (nonatomic, strong)  LetterModel *letter;
@property (nonatomic, strong)  NSString *letterCode;


@end

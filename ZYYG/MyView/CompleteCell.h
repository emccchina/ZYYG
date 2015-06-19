//
//  CompleteCell.h
//  ZYYG
//
//  Created by EMCC on 15/1/8.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompleteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *LFLabel;
@property (weak, nonatomic) IBOutlet UILabel *LSLabel;
@property (weak, nonatomic) IBOutlet UILabel *LTLabel;

@property (nonatomic, assign) NSInteger type;//0线上竞价主页   1线上竞价详情
@property (nonatomic, assign) BOOL      fourLableState;
@end

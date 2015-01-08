//
//  MarginMoneyCell.h
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarginMoneyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *marginMoney;
@property (weak, nonatomic) IBOutlet UILabel *marginState;
@property (weak, nonatomic) IBOutlet UILabel *freezeTime;
@property (weak, nonatomic) IBOutlet UILabel *thawTime;
@property (weak, nonatomic) IBOutlet UILabel *spendTime;

@end

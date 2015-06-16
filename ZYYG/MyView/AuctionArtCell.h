//
//  AuctionArtCell.h
//  ZYYG
//
//  Created by EMCC on 15/1/9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeLabel.h"
@interface AuctionArtCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *LFLabel;
@property (weak, nonatomic) IBOutlet UILabel *LSLabel;
@property (weak, nonatomic) IBOutlet TimeLabel *RSLabel;
@property (weak, nonatomic) IBOutlet UILabel *LTLabel;
@property (weak, nonatomic) IBOutlet UILabel *RTLabel;
@property (weak, nonatomic) IBOutlet UILabel *LBLabel;
@property (weak, nonatomic) IBOutlet UILabel *RBLabel;

@end

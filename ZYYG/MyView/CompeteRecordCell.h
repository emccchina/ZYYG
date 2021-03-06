//
//  CompeteRecordCell.h
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompeteRecordCell : UITableViewCell

@property (nonatomic,strong) NSString *GoodsCode;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *yourPrice;
@property (weak, nonatomic) IBOutlet UILabel *highestPrice;
@property (weak, nonatomic) IBOutlet UILabel *beginTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *proxyPrice;

@end

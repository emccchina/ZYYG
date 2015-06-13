//
//  RecommendedListCell.h
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
//推荐拍品cell(目前用于 私人洽购,我的收藏)
@interface MyCollectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *goodsImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *Lab1;
@property (weak, nonatomic) IBOutlet UILabel *Lab3;
@property (weak, nonatomic) IBOutlet UILabel *Lab4;

@end

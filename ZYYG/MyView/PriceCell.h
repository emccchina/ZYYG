//
//  PriceCell.h
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonSelected) (NSInteger butTag, NSIndexPath *indexPath);//but tag  0 left ,  1 right
//价格参数cell
@interface PriceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) ButtonSelected   buttonSeleced;
@end

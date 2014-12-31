//
//  OrderListCellSum.h
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
//订单列表 3 cell
@interface OrderListCellSum : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *goodsSum;
@property (weak, nonatomic) IBOutlet UILabel *priceSum;
@end

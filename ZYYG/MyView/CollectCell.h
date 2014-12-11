//
//  CollectCell.h
//  ZYYG
//
//  Created by EMCC on 14/11/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CollectPressed)(BOOL collect);

//商品详情的收藏cell
@interface CollectCell : UITableViewCell
{
    BOOL        _collectState;
}
@property (weak, nonatomic) IBOutlet UILabel *topLab;
@property (weak, nonatomic) IBOutlet UILabel *botLab;
@property (weak, nonatomic) IBOutlet UILabel *botRightLab;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;
@property (nonatomic, copy) CollectPressed      colloct;
@property (assign, nonatomic) BOOL   collectState;//是否收藏 0：否    1：是
@property (assign, nonatomic) BOOL   spread;//是否展开，显示价格
@end

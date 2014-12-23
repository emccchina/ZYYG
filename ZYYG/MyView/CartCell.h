//
//  CartCell.h
//  ZYYG
//
//  Created by EMCC on 14/11/28.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DoSelected)(NSIndexPath *indexPath, BOOL selected);
//购物车cell
@interface CartCell : UITableViewCell
{
    BOOL        _selectState;
}
@property (weak, nonatomic) IBOutlet UILabel *LBLab;
@property (weak, nonatomic) IBOutlet UILabel *LThirdLab;
@property (weak, nonatomic) IBOutlet UILabel *LSecondLab;
@property (weak, nonatomic) IBOutlet UILabel *validLab;
@property (weak, nonatomic) IBOutlet UILabel *RTLab;

@property (weak, nonatomic) IBOutlet UILabel *LTLab;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIButton *selectBut;
@property (weak, nonatomic) IBOutlet UILabel *RSecondLab;
@property (weak, nonatomic) IBOutlet UILabel *RThirdLab;
@property (weak, nonatomic) IBOutlet UILabel *RBLab;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLab;

@property (nonatomic, assign) BOOL          cellType;//是否显示出 按钮 底部的已购买label  0显示， 1隐藏
@property (nonatomic, assign) BOOL          valid;//有效否
@property (nonatomic, assign) BOOL          selectState;//是否选中
@property (nonatomic, strong) NSIndexPath   *indexPath;
@property (nonatomic, copy) DoSelected      doSelected;
@end

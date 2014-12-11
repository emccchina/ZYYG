//
//  GoodsShowCell.h
//  ZYYG
//
//  Created by wu on 14/11/22.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoodsShowCellDelegate <NSObject>
@optional
// 左右图片被点击  position： 0,left         1,right
- (void)imageViewPressed:(NSIndexPath*)indexPath position:(BOOL)position;

@end

//商品展示的cell  左右展示
@interface GoodsShowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *leftBut;
@property (weak, nonatomic) IBOutlet UIButton *rightBut;
@property (weak, nonatomic) IBOutlet UIImageView *leftImage;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;

//展示的label
@property (weak, nonatomic) IBOutlet UILabel *LTLab;
@property (weak, nonatomic) IBOutlet UILabel *LMLab;
@property (weak, nonatomic) IBOutlet UILabel *LBLab;

@property (weak, nonatomic) IBOutlet UILabel *RTLab;
@property (weak, nonatomic) IBOutlet UILabel *RMLab;
@property (weak, nonatomic) IBOutlet UILabel *RBLab;
@property (assign, nonatomic) BOOL      showRight;
@property (weak, nonatomic) id<GoodsShowCellDelegate> delegate;

@property (nonatomic, strong)  NSIndexPath *indexPath;

@end



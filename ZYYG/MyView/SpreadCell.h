//
//  SpreadCell.h
//  ZYYG
//
//  Created by EMCC on 14/11/26.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReloadCellHeight) (BOOL spread12);

//点击展开的cell
@interface SpreadCell : UITableViewCell
{
    BOOL   _spreadState;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *spreadButton;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (copy, nonatomic) ReloadCellHeight reloadHeight;
@property (assign, nonatomic) BOOL   spreadState;//是否展开
@end

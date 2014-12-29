//
//  PopView.h
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectPopViewFinished) (NSInteger row);
#define kPopCellHegith            44
@interface PopView : UIView
<UITableViewDataSource, UITableViewDelegate>
{
    UITableView         *myTableView;
    NSArray             *_titles;
    NSInteger           _type;
}
@property (nonatomic, assign) NSInteger                 type;//0 分类中带图片的   1 不带图片,在window上显示的appdelegate
@property (nonatomic, strong) NSArray                   *titles;
@property (nonatomic, copy) SelectPopViewFinished       selectedFinsied;
@property (nonatomic, strong) UIImage                   *titleImage;
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)newTitles;

@end

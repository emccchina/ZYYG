//
//  ChooseView.h
//  ZYYG
//
//  Created by EMCC on 14/12/3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ChooseViewFinised) (id selected);

//筛选页面的view
@interface ChooseView : UIView
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray     *_titles;
    BOOL        _sell;//是否已售
}
@property (strong, nonatomic) IBOutlet UITableView *chooseTB;
@property (nonatomic, copy)   ChooseViewFinised     chooseFinised;
@property (strong, nonatomic) NSArray  *titles;

@end

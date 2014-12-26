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
    NSArray     *_details;
    BOOL        _sell;//是否已售
}

@property (nonatomic, assign) NSInteger             type;//0平价中的筛选，1洽购中的筛选
@property (strong, nonatomic) IBOutlet UITableView *chooseTB;
@property (nonatomic, copy)   ChooseViewFinised     chooseFinised;
@property (strong, nonatomic) NSArray  *titles;
@property (strong, nonatomic) NSArray   *details;
- (void)reloadTitles:(NSArray*)titles details:(NSArray*)details;//重新载入

@end

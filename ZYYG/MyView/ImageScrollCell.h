//
//  ImageScrollCell.h
//  ZYYG
//
//  Created by wu on 14/11/22.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CycleScrollView.h"
typedef void (^imageClick) (void);
//滚动的cell  展示图片
@interface ImageScrollCell : UITableViewCell
<CycleScrollViewDatasource, CycleScrollViewDelegate>

@property (assign, nonatomic) NSInteger         style;//0 首页的   1详情的
@property (strong, nonatomic) IBOutlet CycleScrollView *scrollView;
@property (strong, nonatomic) NSArray                   *images;
@property (nonatomic, copy) imageClick          click;
- (void)reloadScrollViewData;//刷新scrollview
@end

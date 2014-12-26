//
//  ChooseSingleView.h
//  ZYYG
//
//  Created by champagne on 14-12-26.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ChooseSingleViewFinised) (id selected);

@interface ChooseSingleView : UIView
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chooseTB;
@property (nonatomic, copy)   ChooseSingleViewFinised     chooseFinised;
@property (strong, nonatomic) NSMutableArray  *artists;
- (void)reloadArtists:(NSMutableArray*)artists;//重新载入

@end

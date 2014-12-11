//
//  PersonCenterVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "BaseViewController.h"

//个人中心
@interface PersonCenterVC : BaseViewController
<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *PersonTableView;

@end

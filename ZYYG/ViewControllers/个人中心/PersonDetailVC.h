//
//  PersonDetailVC.h
//  ZYYG
//
//  Created by champagne on 14-12-8.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface PersonDetailVC : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *personDetailTableView;
@end

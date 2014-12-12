//
//  EditPersonVC.h
//  ZYYG
//
//  Created by champagne on 14-12-12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface EditPersonVC : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSString      *editType;//隐藏底部的购物车view
@property (nonatomic, strong) NSString      *textValue;//
@property (weak, nonatomic) IBOutlet UITableView *editPersonTableView;


@end

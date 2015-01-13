//
//  PayMarginVC.h
//  ZYYG
//
//  Created by champagne on 15-1-9.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "GoodsModel.h"
#import "PaaCreater.h"
@interface PayMarginVC : BaseViewController <UITableViewDelegate,UITableViewDataSource,APayDelegate>

@property (nonatomic,retain) GoodsModel *goods;
@property (nonatomic, strong) NSString *auctionCode;
@property (weak, nonatomic) IBOutlet UITableView *PayMarginTabelView;
@property (weak, nonatomic) IBOutlet UILabel *marginMoneyLab;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
- (IBAction)pressPay:(id)sender;
@end

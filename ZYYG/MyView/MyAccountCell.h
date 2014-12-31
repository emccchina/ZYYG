//
//  MyAccountCell.h
//  ZYYG
//
//  Created by champagne on 14-12-8.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
//我的账户cell
@interface MyAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *BillCode; //账单号
@property (weak, nonatomic) IBOutlet UILabel *Direction; //收入支出
@property (weak, nonatomic) IBOutlet UILabel *BillType; //业务类型
@property (weak, nonatomic) IBOutlet UILabel *MoneyType;  //操作类型
@property (weak, nonatomic) IBOutlet UILabel *OperMoney;    //金额
@property (weak, nonatomic) IBOutlet UILabel *ReceiveNickName;//接收方
@property (weak, nonatomic) IBOutlet UILabel *AuditTime;    //生成时间
@property (weak, nonatomic) IBOutlet UILabel *Remark;   //备注

@end

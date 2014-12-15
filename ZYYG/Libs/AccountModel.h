//
//  AccountModel.h
//  ZYYG
//
//  Created by champagne on 14-12-15.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountModel : NSObject


@property (nonatomic, strong) NSString          *Direction; //方向（收入或支出）
@property (nonatomic, strong) NSString          *AuditTime; //审核时间
@property (nonatomic, strong) NSString          *BillType; //单据类型
@property (nonatomic, strong) NSString          *BillCode; //销售单号
@property (nonatomic, strong) NSString          *OperMoney; //操作金额
@property (nonatomic, strong) NSString          *MoneyType; //金额类型
@property (nonatomic, strong) NSString          *ReceiveNickName; //接收人帐户
@property (nonatomic, strong) NSString          *Remark; //备注

+(id)accountWithDict:(NSDictionary *)dict;

@end

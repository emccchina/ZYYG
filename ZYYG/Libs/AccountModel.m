//
//  AccountModel.m
//  ZYYG
//
//  Created by champagne on 14-12-15.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "AccountModel.h"

@implementation AccountModel


+(id)accountWithDict:(NSDictionary *)dict
{
    AccountModel *account=[[AccountModel alloc] init];
    account.Direction=[dict safeObjectForKey:@"Direction"];
    account.AuditTime=[dict safeObjectForKey:@"AuditTime"];
    account.BillType=[dict safeObjectForKey:@"BillType"];
    account.BillCode=[dict safeObjectForKey:@"BillCode"];
    account.OperMoney=[dict safeObjectForKey:@"OperMoney"];
    account.MoneyType=[dict safeObjectForKey:@"MoneyType"];
    account.ReceiveNickName=[dict safeObjectForKey:@"ReceiveNickName"];
    account.Remark=[dict safeObjectForKey:@"Remark"];
    return account;
}

@end

//
//  InvoiceModel.m
//  ZYYG
//
//  Created by champagne on 14-12-16.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "InvoiceModel.h"

@implementation InvoiceModel

+(id)invoiceWithDict:(NSDictionary *)dict
{
    InvoiceModel *invoice=[[InvoiceModel alloc] init];
    
    invoice.InvoiceTaxNo=[dict safeObjectForKey:@"InvoiceTaxNo"]; // 发票号
    invoice.InvoiceTitle=[dict safeObjectForKey:@"InvoiceTitle"]; //发票抬头
    invoice.InvoiceType=[dict safeObjectForKey:@"InvoiceType"]; //发票类型
    invoice.RegAccount=[dict safeObjectForKey:@"RegAccount"]; //
    invoice.RegAddress=[dict safeObjectForKey:@"RegAddress"]; //
    invoice.RegBank=[dict safeObjectForKey:@"RegBank"]; //
    invoice.RegPhone=[dict safeObjectForKey:@"RegPhone"]; //
    return invoice;
}

@end

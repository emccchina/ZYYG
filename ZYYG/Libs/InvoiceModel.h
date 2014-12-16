//
//  InvoiceModel.h
//  ZYYG
//
//  Created by champagne on 14-12-16.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvoiceModel : NSObject

@property (nonatomic, strong) NSString          *InvoiceTaxNo; // 发票号
@property (nonatomic, strong) NSString          *InvoiceTitle; //发票抬头
@property (nonatomic, strong) NSString          *InvoiceType; //发票类型
@property (nonatomic, strong) NSString          *RegAccount; //
@property (nonatomic, strong) NSString          *RegAddress; //
@property (nonatomic, strong) NSString          *RegBank; //
@property (nonatomic, strong) NSString          *RegPhone; //

+(id)invoiceWithDict:(NSDictionary *)dict;

@end

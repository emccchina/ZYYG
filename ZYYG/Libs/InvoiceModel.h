//
//  InvoiceModel.h
//  ZYYG
//
//  Created by champagne on 14-12-16.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//增值税发票
@interface InvoiceModel : NSObject

@property (nonatomic, strong) NSString          *InvoiceTaxNo; // 发票号
@property (nonatomic, strong) NSString          *InvoiceTitle; //发票抬头
@property (nonatomic, strong) NSString          *InvoiceType; //发票类型
@property (nonatomic, strong) NSString          *RegAccount; //
@property (nonatomic, strong) NSString          *RegAddress; //
@property (nonatomic, strong) NSString          *RegBank; //银行卡号
@property (nonatomic, strong) NSString          *RegPhone; //电话

+(id)invoiceWithDict:(NSDictionary *)dict;

@end

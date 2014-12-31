//
//  InvoiceVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/23.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
//发票填写
typedef void (^SelectInvoiceFinished)(NSDictionary* invoiceFinished);
@interface InvoiceVC : BaseViewController

@property (nonatomic, strong) NSDictionary *invoice;

@property (nonatomic, copy) SelectInvoiceFinished finished;

@end

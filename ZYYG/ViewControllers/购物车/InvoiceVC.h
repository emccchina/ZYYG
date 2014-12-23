//
//  InvoiceVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/23.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface InvoiceVC : BaseViewController

@end


@interface InvoiceManager : NSObject

@property (nonatomic, assign) NSInteger type;//0不开具发票  1普通发票   2增值税发票

@end
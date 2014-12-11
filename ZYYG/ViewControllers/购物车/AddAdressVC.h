//
//  AddAdressVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"
#import "AddAdressVC.h"
#import "AdressVC.h"

typedef void (^AddAdressFinised) (void);
@interface AddAdressVC : BaseViewController

@property (nonatomic, strong) AdressModel         *address;
@property (nonatomic, copy) AddAdressFinised    finished;
@end

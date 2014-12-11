//
//  SearchReusltVC.h
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectInfo : NSObject
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *page;
@end

@implementation SelectInfo

@end

@interface SearchReusltVC : BaseViewController

@property (nonatomic, strong) SelectInfo    *selectInfo;

@end

//
//  AdressVC.h
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

#define kProvince       @"Province_Code"
#define kcity           @"city_Code"
#define karea           @"area_Code"
#define kDetailAdress   @"address"
#define kName           @"name"
#define kZipCode        @"zipCode"
#define kTel            @"tel"
#define kTelPhone       @"telPhone"
#define kStates         @"status"
#define kAddr_code      @"addr_code"

typedef void (^AddressDefaultChange) (BOOL change);

//地址页面
@interface AdressVC : BaseViewController

//@property (nonatomic, strong) NSMutableArray *adresses;
@property (nonatomic, copy) AddressDefaultChange  change;
@end

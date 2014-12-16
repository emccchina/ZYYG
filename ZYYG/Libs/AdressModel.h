//
//  AdressModel.h
//  ZYYG
//
//  Created by EMCC on 14/12/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdressModel : NSObject

@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *defaultAdress;
@property (nonatomic, strong) NSString      *provinceName;
@property (nonatomic, strong) NSString      *provinceID;
@property (nonatomic, strong) NSString      *cityName;
@property (nonatomic, strong) NSString      *cityID;
@property (nonatomic, strong) NSString      *townName;
@property (nonatomic, strong) NSString      *townID;
@property (nonatomic, strong) NSString      *detailAdress;
@property (nonatomic, strong) NSString      *mobile;
@property (nonatomic, strong) NSString      *telPhone;
@property (nonatomic, strong) NSString      *adressCode;
@property (nonatomic, strong) NSString      *zipCode;

- (void)setModelFromAddressModel:(AdressModel*)model;

- (void)setModel:(NSDictionary*)dict;

- (NSDictionary*)getDict:(BOOL)state;//获取提交地址的字典  state， 是否默认

-(void)addressFromOrder:(NSDictionary *)dict;

@end


@interface AddressManager : NSObject

@property (nonatomic, strong) NSMutableArray  *addresses;
@property (nonatomic, assign) NSUInteger      defaultAddressIndex;
@property (nonatomic, strong) NSString        *defaultAddressCode;
@property (nonatomic, assign) BOOL            updata;

- (void)requestAddressList;

@end
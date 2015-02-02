//
//  AdressModel.h
//  ZYYG
//
//  Created by EMCC on 14/12/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//收货地址
@interface AdressModel : NSObject

@property (nonatomic, strong) NSString      *name;//地址名
@property (nonatomic, strong) NSString      *defaultAdress;//默认地址
@property (nonatomic, strong) NSString      *provinceName;//省份
@property (nonatomic, strong) NSString      *provinceID;
@property (nonatomic, strong) NSString      *cityName;//城市
@property (nonatomic, strong) NSString      *cityID;
@property (nonatomic, strong) NSString      *townName;//地区
@property (nonatomic, strong) NSString      *townID;
@property (nonatomic, strong) NSString      *detailAdress;//详细定制
@property (nonatomic, strong) NSString      *mobile;//手机
@property (nonatomic, strong) NSString      *telPhone;//电话
@property (nonatomic, strong) NSString      *adressCode;//地址编号
@property (nonatomic, strong) NSString      *zipCode;//邮编
@property (nonatomic, assign) BOOL          isExist;//是否可用  竞价订单详情用
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
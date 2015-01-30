//
//  AdressModel.m
//  ZYYG
//
//  Created by EMCC on 14/12/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "AdressModel.h"
#import "AdressVC.h"
@implementation AdressModel
- (void)setModelFromAddressModel:(AdressModel*)model
{
    self.name = model.name;
    self.mobile = model.mobile;
    self.telPhone = model.telPhone;
    self.detailAdress = model.detailAdress;
    self.adressCode = model.adressCode;
    self.zipCode = model.zipCode;
    self.provinceID = model.provinceID;
    self.provinceName = model.provinceName;
    self.cityID = model.cityID;
    self.cityName = model.cityName;
    self.townID = model.townID;
    self.townName = model.townName;
    self.defaultAdress = model.defaultAdress;
}
- (void)setModel:(NSDictionary *)dict
{
    self.name = [dict safeObjectForKey:@"Linkman"];
    self.adressCode = [dict safeObjectForKey:@"AddrCode"];
    self.detailAdress = [dict safeObjectForKey:@"Address"];
    self.townID = [dict safeObjectForKey:@"AreaCode"];
    self.defaultAdress = [dict safeObjectForKey:@"DefaultAddr"];
    self.provinceName = [dict safeObjectForKey:@"ProvinceName"];
    self.provinceID = [dict safeObjectForKey:@"ProvinceCode"];;
    self.cityName = [dict safeObjectForKey:@"CityName"];
    self.cityID = [dict safeObjectForKey:@"CityCode"];
    self.townName =[dict safeObjectForKey:@"AreaName"];
    self.mobile = [dict safeObjectForKey:@"Mobile"];
    self.telPhone = [dict safeObjectForKey:@"Telephone"];
    self.zipCode = [dict safeObjectForKey:@"Postcode"];
}

- (NSDictionary*)getDict:(BOOL)stat
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[UserInfo shareUserInfo].userKey forKey:@"key"];
    [dict setObject:self.provinceID forKey:kProvince];
    [dict setObject:self.cityID forKey:kcity];
    [dict setObject:self.townID forKey:karea];
    [dict setObject:self.detailAdress forKey:kDetailAdress];
    [dict setObject:self.name forKey:kName];
    [dict setObject:self.mobile forKey:kTel];
    [dict setObject:(self.zipCode ? : @"") forKey:kZipCode];
    [dict setObject:(self.telPhone ? :@"") forKey:kTelPhone];
    [dict setObject:[NSString stringWithFormat:@"%d", stat] forKey:kStates];
    [dict setObject:(self.adressCode?:@"") forKey:kAddr_code];
    return (NSDictionary*)dict;
}

-(void)addressFromOrder:(NSDictionary *)dict
{
    self.name = [dict safeObjectForKey:@"Consignee"];
    self.defaultAdress = [dict safeObjectForKey:@"Address"];
    self.zipCode = [dict safeObjectForKey:@"Postcode"];
    self.mobile = [dict safeObjectForKey:@"Tel"];
    
}

@end

@implementation AddressManager

- (void)requestAddressList
{
    
}

@end
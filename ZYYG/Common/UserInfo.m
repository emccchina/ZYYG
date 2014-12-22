//
//  UserInfo.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "UserInfo.h"
#import "GoodsModel.h"

@implementation UserInfo

+ (UserInfo*)shareUserInfo
{
    static UserInfo *userInfoInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        userInfoInstance = [[self alloc] init];
    });
    return userInfoInstance;
}

- (BOOL)isLogin
{
    return self.userKey ? YES : NO;
}

- (void)loginOut
{
    self.userKey = nil;
    self.headImage = nil;
    self.useName = nil;
    self.realName = nil;
    self.nickName = nil;
    self.gender = nil;
    self.industry =nil;
    self.income = nil;
    self.mobile = nil;
    self.email = nil;
    self.provideCode = nil;
    self.cityCode = nil;
    self.aeraCode = nil;
    self.detailAddress = nil;
    self.zipCode = nil;
    self.addressManager = nil;
    self.cartsArr = nil;
}

-(UserInfo *)setParams:(UserInfo *)user parmas:(NSDictionary *)dict
{
    user.userKey=[dict safeObjectForKey:@"key"];
    user.headImage=[dict safeObjectForKey:@"HEAD_IMG"];
    user.useName=[dict safeObjectForKey:@"email"];
    user.realName=[dict safeObjectForKey:@"RealName"];
    user.nickName=[dict safeObjectForKey:@"Nickname"];
    user.gender=[dict safeObjectForKey:@"gender"];
    user.industry=[dict safeObjectForKey:@"Industry"];
    user.income=[dict safeObjectForKey:@"Income"];
    user.mobile=[dict safeObjectForKey:@"Mobile"];
    user.email=[dict safeObjectForKey:@"email"];
    user.provideCode=[dict safeObjectForKey:@"ProvideCode"];
    user.cityCode=[dict safeObjectForKey:@"CityCode"];
    user.aeraCode=[dict safeObjectForKey:@"AeraCode"];
    user.detailAddress=[dict safeObjectForKey:@"DetailAddr"];
    user.zipCode=[dict safeObjectForKey:@"Postcode"];
    return user;
}

- (void)parseAddressArr:(NSArray*)arr
{
    if (!arr.count) {
        return;
    }
    AddressManager *manager = [[AddressManager alloc] init];
    NSMutableArray *addresses = [NSMutableArray array];
    BOOL address = NO;//是否有默认的
    for (NSDictionary* dict in arr) {
        AdressModel *model = [[AdressModel alloc] init];
        [model setModel:dict];
        if ([model.detailAdress integerValue]) {
            address = YES;
            manager.defaultAddressIndex = [arr indexOfObject:dict];
            manager.defaultAddressCode = model.adressCode;
        }
        [addresses addObject:model];
    }
    if (!address) {
        AdressModel *model = addresses[0];
        manager.defaultAddressCode = model.adressCode;
        manager.defaultAddressIndex = 0;
    }
    manager.addresses = addresses;
    self.addressManager = manager;
}

- (void)parseCartArr:(NSArray *)arr
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        GoodsModel *model = [[GoodsModel alloc] init];
        [model goodsModelFromCart:dict];
        [array addObject:model];
    }
    self.cartsArr = array;
}

@end

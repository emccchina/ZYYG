//
//  UserInfo.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "UserInfo.h"

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

-(UserInfo *)setParams:(UserInfo *)user parmas:(NSDictionary *)dict
{
    user.userKey=dict[@"key"];
    user.headImage=dict[@"headImage"];
    user.useName=dict[@"email"];
    user.realName=dict[@"RealName"];
    user.nickName=dict[@"Nickname"];
    user.gender=dict[@"gender"];
    user.industry=dict[@"Industry"];
    user.income=dict[@"Income"];
    user.mobile=dict[@"Mobile"];
    user.email=dict[@"Email"];
    user.provideCode=dict[@"ProvideCode"];
    user.cityCode=dict[@"CityCode"];
    user.aeraCode=dict[@"AeraCode"];
    user.detailAddress=dict[@"detailAddr"];
    user.zipCode=dict[@"PostCode"];
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

@end

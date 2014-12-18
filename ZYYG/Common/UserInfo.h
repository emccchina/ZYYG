//
//  UserInfo.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdressModel.h"

//User info 单例模式
@interface UserInfo : NSObject

+ (UserInfo*)shareUserInfo;

@property (nonatomic, strong) NSString          *userKey;
@property (nonatomic, strong) NSString          *headImage;
@property (nonatomic, strong) NSString          *useName;
@property (nonatomic, strong) NSString          *realName;
@property (nonatomic, strong) NSString          *nickName;
@property (nonatomic, strong) NSString          *gender;
@property (nonatomic, strong) NSString          *industry;
@property (nonatomic, strong) NSString          *income;
@property (nonatomic, strong) NSString          *mobile;
@property (nonatomic, strong) NSString          *email;
@property (nonatomic, strong) NSString          *provideCode;
@property (nonatomic, strong) NSString          *cityCode;
@property (nonatomic, strong) NSString          *aeraCode;
@property (nonatomic, strong) NSString          *detailAddress;
@property (nonatomic, strong) NSString          *zipCode;
@property (nonatomic, strong) AddressManager    *addressManager;
@property (nonatomic, strong) NSMutableArray    *cartsArr;//购物车数组
- (BOOL)isLogin;//是否登录

-(UserInfo *)setParams:(UserInfo *)user parmas:(NSDictionary *)dict;

- (void)parseAddressArr:(NSArray*)arr;
- (void)parseCartArr:(NSArray*)arr;
@end

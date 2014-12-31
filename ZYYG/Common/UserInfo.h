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

+ (UserInfo*)shareUserInfo; //全局共享的用户信息 单例模式

@property (nonatomic, strong) NSString          *userKey; //用户code
@property (nonatomic, strong) NSString          *headImage;//头像地址
@property (nonatomic, strong) NSString          *useName;//用户名 (email)
@property (nonatomic, strong) NSString          *realName;//真实姓名
@property (nonatomic, strong) NSString          *nickName;//昵称
@property (nonatomic, strong) NSString          *gender;//性别 1 男 0 女
@property (nonatomic, strong) NSString          *industry; //职业
@property (nonatomic, strong) NSString          *income;//收入水平
@property (nonatomic, strong) NSString          *mobile;//手机
@property (nonatomic, strong) NSString          *email;//邮箱 默认是注册邮箱 不可更改
@property (nonatomic, strong) NSString          *provideCode;//省份编码
@property (nonatomic, strong) NSString          *cityCode;//城市编码
@property (nonatomic, strong) NSString          *aeraCode;//地区编码
@property (nonatomic, strong) NSString          *detailAddress;//详细地址
@property (nonatomic, strong) NSString          *zipCode;//邮编
@property (nonatomic, strong) AddressManager    *addressManager;  // 省市级联数据
@property (nonatomic, strong) NSMutableArray    *cartsArr;//购物车数组

- (BOOL)isLogin;//是否登录

- (void)loginOut;//登出

-(UserInfo *)setParams:(UserInfo *)user parmas:(NSDictionary *)dict;//用户信息初始化

- (void)parseAddressArr:(NSArray*)arr; //地址分析
- (void)parseCartArr:(NSArray*)arr; //购物车分析
@end

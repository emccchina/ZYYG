//
//  PublicDefine.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#ifndef ZYYG_PublicDefine_h
#define ZYYG_PublicDefine_h

#define createBottomLine  UIView *lineB = [[UIView alloc] init];\
                                    lineB.backgroundColor = [UIColor blackColor];\
                                    lineB.alpha = 0.3;\
                                    [self addSubview:lineB];\
                                    [lineB setTranslatesAutoresizingMaskIntoConstraints:NO];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];\
                                    [lineB addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1/[UIScreen mainScreen].scale]];


#define createTopLine   UIView *lineT = [[UIView alloc] init];\
                                    lineT.backgroundColor = [UIColor blackColor];\
                                    lineT.alpha = 0.3;\
                                    [self addSubview:lineT];\
                                    [lineT setTranslatesAutoresizingMaskIntoConstraints:NO];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineT attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineT attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];\
                                    [self addConstraint:[NSLayoutConstraint constraintWithItem:lineT attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]];\
                                    [lineT addConstraint:[NSLayoutConstraint constraintWithItem:lineT attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1/[UIScreen mainScreen].scale]];

#endif

#define kTownAdress                         @"town"
#define kCityAdress                         @"city"
#define kProvinceAdress                     @"province"
#define kTem                                @"tem/"
#define kClassifyArr                        kTem@"classifyArr"//分类中的数组 每次关掉程序都会 清空 其他时间存储在doctment中
#define kHotSearchArr                       @"hotSearch"//热搜的数组， 在首页中请求，存入文件，每次打开程序请求一次
#define kAccountKey                         @"account"
#define kAccountPassword                    @"accountPassword"
#define kRememberAccount                    @"rememberAccount"
#define kServerDomain                       @"http://test.zaixianchuangxin.com/mobile/"//@"http://www.zemcc.com/mobile/"

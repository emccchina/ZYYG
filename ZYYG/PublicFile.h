//
//  PublicFile.h
//  ZYYG
//
//  Created by wu on 14/11/22.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#ifndef ZYYG_PublicFile_h
#define ZYYG_PublicFile_h

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define NSLog( s, ... )
#endif

#define iPhone_iOS8        (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define kScreenWidth    CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight   CGRectGetHeight([UIScreen mainScreen].bounds)
#define kRedColor       [UIColor colorWithRed:228.0/255.0 green:57.0/255.0 blue:60.0/255.0 alpha:1]
#define kLightGrayColor [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1]
#define kGrayColor      [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1]
#define kBlackColor     [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1]
#define kBGGrayColor     [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1]
#import "PublicDefine.h"
#import "Utities.h"
#import "UserInfo.h"
#import "NSDictionary+safeObjectForKey.h"
#import "ServerFile.h"

#endif

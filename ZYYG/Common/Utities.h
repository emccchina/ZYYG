//
//  Utities.h
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utities : NSObject

//获取string 的大小
+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string;
+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string rect:(CGSize)size;

//行间距
+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string rect:(CGSize)size space:(CGFloat)space;

//创建barButton
+ (UIBarButtonItem*)barButtonItemWithSomething:(id)some target:(id)target action:(SEL)sel;

//展示登录页面
+ (void)presentLoginVC:(UIViewController*)VC;

//创建一个动画
+ (CATransition *)getAnimation:(NSInteger)mytag;

//获取文件路径
+ (NSString*)filePathName:(NSString*)fileName;

//NSUserDefa
+ (void)setUserDefaults:(id)object key:(NSString*)key;
+ (id)getUserDefaults:(NSString*)key;

//md5 and base64
+ (NSString* )md5AndBase:(NSString *)str;

+ (void)errorPrint:(NSError*)error vc:(UIViewController*)vc;
//展示提示语
+ (void)showMessageOnWindow:(NSString*)message;

+ (NSString*)doWithPayList:(NSString*)result;

+ (NSDictionary *)AESAndMD5:(NSDictionary *)array;

@end

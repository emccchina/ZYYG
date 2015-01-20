//
//  NSString+AES.h
//  ZYYG
//
//  Created by EMCC on 15/1/20.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AES)

- (NSString *)AES256EncryptWithKey:(NSString *)key;   //加密
- (NSString *)AES256DecryptWithKey:(NSString *)key;   //解密

@end

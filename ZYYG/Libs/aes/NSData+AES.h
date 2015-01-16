//
//  AES.h
//  ZYYG
//
//  Created by EMCC on 15/1/16.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(AES)

- (NSData *)AES256EncryptWithKey:(NSString *)key;   //加密
- (NSData *)AES256DecryptWithKey:(NSString *)key;   //解密

@end

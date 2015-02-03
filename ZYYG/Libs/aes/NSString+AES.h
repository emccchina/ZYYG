//
//  NSString+AES.h
//  ZYYG
//
//  Created by EMCC on 15/1/20.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderedDictionary.h"

@interface NSString (AES)

- (NSString *)cleanString:(id)string ;
- (NSString *)AES256EncryptWithKey:(id)key;   //加密
- (NSString *)AES256DecryptWithKey:(id)key;   //解密

@end

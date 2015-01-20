//
//  NSString+AES.m
//  ZYYG
//
//  Created by EMCC on 15/1/20.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "NSString+AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (AES)

- (NSString *)AES256EncryptWithKey:(NSString *)key   //加密
{
    NSData *dataSelf = [self dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [dataSelf length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [dataSelf bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:numBytesEncrypted];
        free(buffer);
        return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];//[NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
- (NSString *)AES256DecryptWithKey:(NSString *)key   //解密
{
    NSData *dataSelf = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSLog(@"endrypt data self %@", dataSelf);
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [dataSelf length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [dataSelf bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:numBytesDecrypted];
        free(buffer);
        NSLog(@"data1 is %@", data);
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//[NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end

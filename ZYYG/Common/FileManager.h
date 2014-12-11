//
//  FileManager.h
//  ZYYG
//
//  Created by EMCC on 14/12/4.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

@property (nonatomic, retain) NSString*  nameOfFile;

//获取文件路径
- (NSString*)filePathName:(NSString*)fileName;
//判断是否存在
- (BOOL)filePathExists:(NSString*)fileName;
//读文件
- (NSString*)readDataFromFile:(NSString*)fileName;
- (NSData*)dataFromFile:(NSString*)fileName;
//写文件;
- (void)writeDataToFile:(NSData*)data fileName:(NSString*)fileName;
//
- (void)clearFileWithFileName:(NSString*)fileName;

//读写文件夹中文件
//- (NSData*)dataFromFileInFolder:(KDFileName)fileName;
- (void)writeDataToFileInFolder:(NSData *)data fileName:(NSString*)fileName;

- (BOOL)clearFileInFolder:(NSString*)fileName;

@end

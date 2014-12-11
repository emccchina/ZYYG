//
//  FileManager.m
//  ZYYG
//
//  Created by EMCC on 14/12/4.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

- (NSString*)filePathName:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//需要的路径
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (BOOL)filePathExists:(NSString*)fileName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* fileD = [self filePathName:fileName];
    if (!fileD) {
        return NO;
    }
    BOOL isExist = [fileManager fileExistsAtPath:fileD];
    if (!isExist) {
        return NO;//return [fileManager createFileAtPath:fileD contents:nil attributes:nil];
    }
    
    return YES;
}

- (NSString*)readDataFromFile:(NSString*)fileName
{
    if ([self filePathExists:fileName]) {
        NSFileManager* fileManger = [NSFileManager defaultManager];
        NSString* fileName11 = [self filePathName:fileName];
        NSData* data = [fileManger contentsAtPath:fileName11];
        NSString* resopndString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //        NSString* stateInfoEnc = [NSString decryptUseDES:resopndString key:kDESKey];
        return resopndString;
    }
    return nil;
}

- (NSData*)dataFromFile:(NSString*)fileName
{
    if ([self filePathExists:fileName]) {
        NSFileManager* fileManger = [NSFileManager defaultManager];
        NSString* fileName11 = [self filePathName:fileName];
        NSData* data = [fileManger contentsAtPath:fileName11];
        return data;
    }
    return nil;
}

- (void)writeDataToFile:(NSData*)data fileName:(NSString*)fileName
{
    if (![self filePathExists:fileName]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* fileD = [self filePathName:fileName];
        if (!fileD) {
            return;
        }
        [fileManager createFileAtPath:fileD contents:nil attributes:nil];
    }
    
    NSString* fileName11 = [self filePathName:fileName];
    NSMutableData* writeDate = [[NSMutableData alloc] init];
    [writeDate appendData:data];
    [writeDate writeToFile:fileName11 atomically:YES];
}

- (void)clearFileWithFileName:(NSString*)fileName
{
    if ([self filePathExists:fileName]) {
        NSString* fileName11 = [self filePathName:fileName];
        NSData* writeDate = [NSData data];
        [writeDate writeToFile:fileName11 atomically:YES];
        
    }
}

- (void)writeDataToFileInFolder:(NSData *)data fileName:(NSString*)fileName
{
    if (![self filePathExists:fileName]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* fileD = [self filePathName:fileName];
        if (!fileD) {
            return;
        }
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];//需要的路径
            documentsDirectory = [documentsDirectory stringByAppendingPathComponent:fileName];
            BOOL isDict = YES;
            if (![fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDict]) {
                [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            [fileManager createFileAtPath:fileD contents:nil attributes:nil];
        
        
    }
    
    NSString* fileName11 = [self filePathName:fileName];
    NSMutableData* writeDate = [[NSMutableData alloc] init];
    [writeDate appendData:data];
    [writeDate writeToFile:fileName11 atomically:YES];
    
}

- (BOOL)clearFileInFolder:(NSString*)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];//需要的路径
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:fileName];
        BOOL isDict = YES;
        if ([fileManager fileExistsAtPath:documentsDirectory isDirectory:&isDict]) {
            NSError *error = nil;
            //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
            NSArray* fileList = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
            //    DLog(@"%@", fileList);
            
            for (NSString* pathName in fileList){
                NSString *databaseFile = [documentsDirectory stringByAppendingPathComponent:pathName];
                if ([fileManager isDeletableFileAtPath:databaseFile]){
                    BOOL remove = [fileManager removeItemAtPath:databaseFile error:nil];
                    if (!remove) {
                        NSLog(@"files delete failed");
                        return NO;
                    }
                }
            }
        }
    
    
    return YES;
}
@end

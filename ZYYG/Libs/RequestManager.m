//
//  RequestManager.m
//  ZYYG
//
//  Created by EMCC on 15/2/3.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "RequestManager.h"
#import "NSString+AES.h"
@implementation RequestManager

+ (void)requestForAddressListInManager:(void (^)(BOOL success))successful
{
    UserInfo *userInfo = [UserInfo shareUserInfo];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@OrderBasicInfoList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userInfo.userKey, @"key", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        NSLog(@"aesde %@", aesde);
        id result = [NSJSONSerialization JSONObjectWithData:[aesde dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (result) {
            [userInfo parseAddressArr:result[@"AddressList"]];
            [userInfo parseDeliveryList:result[@"DeliveryList"]];
            [userInfo parsePackingList:result[@"PackingList"]];
            userInfo.taxPercend=[result[@"Tax"] floatValue];
            successful(YES);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        successful(NO);
        
    }];

}

@end

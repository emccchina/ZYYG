//
//  RequestManager.h
//  ZYYG
//
//  Created by EMCC on 15/2/3.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManager : NSObject

+ (void)requestForAddressListInManager:(void (^)(BOOL success))successful;

+ (void)requestForConfirmGoodsWithDict:(NSDictionary*)dict result:(void(^)(BOOL success)) successful;

@end

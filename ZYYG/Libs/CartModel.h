//
//  CartModel.h
//  ZYYG
//
//  Created by EMCC on 14/12/11.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartModel : NSObject

@property (nonatomic, copy) NSString    *ImageUrl;
@property (nonatomic, copy) NSString    *product_id;
@property (nonatomic, copy) NSString    *size;
@property (nonatomic, copy) NSString    *Title;
@property (nonatomic, copy) NSString    *Count;
@property (nonatomic, copy) NSString    *Num;
@property (nonatomic, copy) NSString    *Money;
@property (nonatomic, assign) BOOL  selected;

- (void)parseDict:(NSDictionary*)dict;

@end

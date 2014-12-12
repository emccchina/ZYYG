//
//  ClassifyModel.h
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//分类的model
@interface ClassifyModel : NSObject

@property (nonatomic, assign) NSInteger         index;
@property (nonatomic, strong) NSString          *code;
@property (nonatomic, strong) NSString          *name;
@property (nonatomic, strong) NSString          *price;
- (void)classifyModelFromDict:(NSDictionary*)dict;

@end

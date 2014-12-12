//
//  ClassifyModel.m
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ClassifyModel.h"

@implementation ClassifyModel

- (void)classifyModelFromDict:(NSDictionary *)dict
{
    self.index = [dict[@"index"] integerValue];
    self.code   = dict[@"Code"];
    self.name   = dict[@"Name"];
}

@end

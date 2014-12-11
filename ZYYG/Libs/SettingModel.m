//
//  SettingModel.m
//  ZYYG
//
//  Created by champagne on 14-12-5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

+(id)settongModelWithDict:(NSDictionary *)dict
{
    SettingModel *set=[[SettingModel alloc] init];
    set.title=[dict objectForKey:@"title"];
    set.segueString=[dict objectForKey:@"segueString"];
    return set;
}

@end

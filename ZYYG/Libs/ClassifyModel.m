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

- (void)deliveryFromDict:(NSDictionary*)dict
{
    self.code=[dict safeObjectForKey:@"DeliveryCode"];
    self.name=[dict safeObjectForKey:@"DeliveryName"];
    self.desc=[dict safeObjectForKey:@"DeliveryDesc"];
    self.price=[dict safeObjectForKey:@"Price"];
    
    
}
- (void)packingFromDict:(NSDictionary*)dict
{
    self.code=[dict safeObjectForKey:@"PackingCode"];
    self.name=[dict safeObjectForKey:@"PackingName"];
    self.desc=[dict safeObjectForKey:@"PackingDesc"];
    self.price=[dict safeObjectForKey:@"Price"];
    
}
@end

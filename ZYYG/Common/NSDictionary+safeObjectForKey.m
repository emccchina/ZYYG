//
//  NSDictionary+safeObjectForKey.m
//  EMCCHaiTao
//
//  Created by Champagne on 14-10-12.
//  Copyright (c) 2014年 champagne. All rights reserved.
//

#import "NSDictionary+safeObjectForKey.h"


#define checkNull(__X__)        (__X__) == [NSNull null] || (__X__) == nil ? @" " : [NSString stringWithFormat:@"%@", (__X__)]


@implementation NSDictionary (safeObjectForKey)

- (NSString *)safeObjectForKey:(id)key
{
        return checkNull([self objectForKey:key]);
}

@end

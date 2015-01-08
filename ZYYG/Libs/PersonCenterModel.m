//
//  PersonCenterModel.m
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PersonCenterModel.h"

@implementation PersonCenterModel

+(PersonCenterModel *)personCenterModelWithDictionary:(NSDictionary *)dict
{
    PersonCenterModel *per=[[PersonCenterModel alloc] init];
    per.headerImage=[dict objectForKey:@"headerImage"];
    per.title=[dict objectForKey:@"title"];
    per.footerImage=[dict objectForKey:@"footerImage"];
    per.segueString=[dict objectForKey:@"segueString"];
    return per;

}

@end

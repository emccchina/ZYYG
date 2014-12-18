//
//  SettingModel.h
//  ZYYG
//
//  Created by champagne on 14-12-5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property(nonatomic ,copy) NSString *title;
@property(nonatomic ,copy) NSString *segueString;

+(id)settongModelWithDict:(NSDictionary *)dict;
@end

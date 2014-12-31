//
//  SettingModel.h
//  ZYYG
//
//  Created by champagne on 14-12-5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//设置
@interface SettingModel : NSObject

@property(nonatomic ,copy) NSString *title;
@property(nonatomic ,copy) NSString *segueString;//跳转页面

+(id)settongModelWithDict:(NSDictionary *)dict;
@end

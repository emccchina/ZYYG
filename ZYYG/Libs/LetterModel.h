//
//  LetterModel.h
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LetterModel : NSObject

@property (nonatomic, strong) NSString *AuditTime;
@property (nonatomic, strong) NSString *LetterCode;
@property (nonatomic, strong) NSString *Title;
@property (nonatomic, strong) NSString *SendName;
@property (nonatomic, strong) NSString *LetterContent;

+(id)letterFromDict:(NSDictionary *)dict;

@end

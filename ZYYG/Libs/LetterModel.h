//
//  LetterModel.h
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//站内信
@interface LetterModel : NSObject

@property (nonatomic, strong) NSString      *AuditTime;//发送时间
@property (nonatomic, strong) NSString      *LetterCode;//编号
@property (nonatomic, strong) NSString      *Title;//标题
@property (nonatomic, strong) NSString      *SendName;//发送正
@property (nonatomic, strong) NSString      *LetterContent;//内容

+(id)letterFromDict:(NSDictionary *)dict;
-(void)initFromManager:(NSDictionary *)dict;
@end

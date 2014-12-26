//
//  LetterModel.m
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "LetterModel.h"

@implementation LetterModel

+(id)letterFromDict:(NSDictionary *)dict
{
    LetterModel *letter=[[LetterModel alloc] init];
    letter.AuditTime=[dict safeObjectForKey:@"AuditTime"];
    letter.LetterCode=[dict safeObjectForKey:@"LetterCode"];
    letter.Title=[dict safeObjectForKey:@"Title"];
    letter.SendName=[dict safeObjectForKey:@"SendName"];
    letter.LetterContent=[dict safeObjectForKey:@"LetterContent"];
    
    return letter;
}
-(void)initFromManager:(NSDictionary *)dict
{
    self.Title=[dict safeObjectForKey:@"Title"];
    self.LetterCode=[dict safeObjectForKey:@"ImageUrl"];
    self.SendName=[dict safeObjectForKey:@"Tel"];
    self.LetterContent=[dict safeObjectForKey:@"Url"];
}
@end

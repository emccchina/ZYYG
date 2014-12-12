//
//  SelectInfo.m
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SelectInfo.h"

@implementation SelectInfo
- (NSDictionary*)createURLDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.categaryCode) {
        [dict setObject:self.categaryCode forKey:@"Categary"];
    }
    if (self.price) {
        [dict setObject:self.price forKey:@"Price"];
    }
    if (self.size) {
        [dict setObject:self.size forKey:@"Size"];
    }
    if (self.squareFoot) {
        [dict setObject:self.squareFoot forKey:@"SquareFoot"];
    }
    if (self.sytle) {
        [dict setObject:self.sytle forKey:@"CreationStyle"];
    }
    if (self.artorName) {
        [dict setObject:self.artorName forKey:@"AuthorCode"];
    }
    if (self.country) {
        [dict setObject:self.country forKey:@"Country"];
    }
    if (self.height) {
        [dict setObject:self.height forKey:@"Height"];
    }
    if (self.versionNumber) {
        [dict setObject:self.versionNumber forKey:@"VersionNumber"];
    }
    if (self.species) {
        [dict setObject:self.species forKey:@"Species"];
    }
    if (self.shotPrice) {
        [dict setObject:@(self.shotPrice) forKey:@"ShotPrice"];
    }
    if (self.shotDate) {
        [dict setObject:@(self.shotDate) forKey:@"ShotDate"];
    }
    if (self.shotQuantity) {
        [dict setObject:@(self.shotQuantity) forKey:@"ShotQuantity"];
    }
    if (self.num) {
        [dict setObject:@(self.num) forKey:@"num"];
    }
    if (self.page) {
        [dict setObject:@(self.page) forKey:@"page"];
    }
    return dict;
}
@end

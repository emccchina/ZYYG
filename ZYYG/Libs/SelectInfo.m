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
    
    if (self.makeStyle) {
        [dict setObject:self.makeStyle forKey:@"FiringMode"];
    }
    
    if (self.attrible) {
        [dict setObject:self.attrible forKey:@"Attributes"];
    }
    
    if (!dict.count) {
        return nil;
    }
    return dict;
}


- (void)setInfoWithType:(NSString*)type content:(NSDictionary*)content
{
    NSString *code = content[@"Code"];
    if (!code) {
        return;
    }
    if ([type isEqualToString:kAttributeCode]) {
        self.attrible = code;
    }else if ([type isEqualToString:kAuthorCode]){
        self.artorName = code;
    }else if ([type isEqualToString:kStyleCode]){
        self.sytle = code;
    }else if ([type isEqualToString:kMakeStyleCode]){
        self.makeStyle = code;
    }else if ([type isEqualToString:kHeightCode]){
        self.height = code;
    }else if ([type isEqualToString:kCountoyCode]){
        self.country = code;
    }else if ([type isEqualToString:kPrice1Code]){
        self.price = code;
    }else if ([type isEqualToString:kPrice2Code]){
        self.price = code;
    }else if ([type isEqualToString:kSpec1Code]){
        self.size = code;
    }else if ([type isEqualToString:kSpec2Cpde]){
        self.squareFoot = code;
    }else if ([type isEqualToString:kSpeciesCode]){
        self.species = code;
    }else if ([type isEqualToString:kVersionsCode]){
        self.versionNumber = code;
    }
}
@end

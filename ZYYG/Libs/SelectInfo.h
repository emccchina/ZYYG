//
//  SelectInfo.h
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAttributeCode          @"attribute"
#define kAuthorCode             @"author"
#define kStyleCode              @"creationStyle"
#define kMakeStyleCode          @"firingMode"
#define kHeightCode             @"height"
#define kCountoyCode            @"nationality"
#define kPrice1Code             @"price1"
#define kPrice2Code             @"price2"
#define kSpec1Code              @"spec1"
#define kSpec2Cpde              @"spec2"
#define kSpeciesCode            @"species"
#define kVersionsCode           @"versionNumber"


@interface SelectInfo : NSObject
@property (nonatomic, strong) NSString *categaryCode;//
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *squareFoot;//平尺
@property (nonatomic, strong) NSString *sytle;
@property (nonatomic, strong) NSString *artorName;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *versionNumber;
@property (nonatomic, strong) NSString *species;
@property (nonatomic, assign) NSInteger  shotPrice;
@property (nonatomic, assign) NSInteger shotDate;
@property (nonatomic, assign) NSInteger shotQuantity;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSString  *attrible;
@property (nonatomic, strong) NSString *makeStyle;
- (NSDictionary*)createURLDict;

- (void)setInfoWithType:(NSString*)type content:(NSDictionary*)content;

@end

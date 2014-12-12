//
//  SelectInfo.h
//  ZYYG
//
//  Created by EMCC on 14/12/12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

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

- (NSDictionary*)createURLDict;

@end

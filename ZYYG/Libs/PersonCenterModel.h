//
//  PersonCenterModel.h
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonCenterModel : NSObject

@property(nonatomic ,copy) NSString *headerImage;
@property(nonatomic ,copy) NSString *title;
@property(nonatomic ,copy) NSString *count;
@property(nonatomic ,copy) NSString *footerImage;
@property(nonatomic ,copy) NSString *segueString;


+(PersonCenterModel *) personCenterModelWithDictionary:(NSDictionary *)dict;
@end

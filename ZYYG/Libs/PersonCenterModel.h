//
//  PersonCenterModel.h
//  ZYYG
//
//  Created by champagne on 14-12-2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>
//个人中心
@interface PersonCenterModel : NSObject

@property(nonatomic ,copy) NSString *headerImage;//cell图片
@property(nonatomic ,copy) NSString *title;//cell标题
@property(nonatomic ,copy) NSString *count;//红色的数量数据
@property(nonatomic ,copy) NSString *footerImage;//箭头
@property(nonatomic ,copy) NSString *segueString;//跳转页面


+(PersonCenterModel *) personCenterModelWithDictionary:(NSDictionary *)dict;
@end

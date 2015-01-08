//
//  AuctionModel.h
//  ZYYG
//
//  Created by EMCC on 15/1/8.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import <Foundation/Foundation.h>

//拍卖会 线上竞价首页
@interface AuctionModel : NSObject

@property (nonatomic, strong) NSString *auctionCode;
@property (nonatomic, strong) NSString *auctionName;
@property (nonatomic, strong) NSString *auctionState;
@property (nonatomic, strong) NSString *auctionDate;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *stopTime;
@property (nonatomic, strong) NSString *imageURL;

- (void)parseFromAuctionResult:(NSDictionary*)dict;

@end

//
//  AuctionModel.m
//  ZYYG
//
//  Created by EMCC on 15/1/8.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "AuctionModel.h"

@implementation AuctionModel
- (void)parseFromAuctionResult:(NSDictionary*)dict
{
    self.auctionCode = [dict safeObjectForKey:@"AUCTIONCODE"];
    self.auctionName = [dict safeObjectForKey:@"AUCTIONNAME"];
    self.auctionState = [dict safeObjectForKey:@"State"];
    self.auctionDate = [dict safeObjectForKey:@"Date"];
    self.startTime = [dict safeObjectForKey:@"StartTime"];
    self.stopTime = [dict safeObjectForKey:@"StopTime"];
    self.imageURL = [dict safeObjectForKey:@"Image"];
}
@end

//
//  OrderSubmitModel.m
//  ZYYG
//
//  Created by EMCC on 15/2/2.
//  Copyright (c) 2015年 wu. All rights reserved.
//

#import "OrderSubmitModel.h"
#import "NSString+AES.h"

@implementation OrderSubmitModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.invoiceType = @"0";
        self.userKey = [NSString stringWithFormat:@"%@", [UserInfo shareUserInfo].userKey];
    }
    return self;
}

/* 选择普通发票时:
 * 1.发票抬头可写。
 * 2.税费 = (商品总额 + 包装费 + 配送费 - 立减金额 - 其他优惠) * 税点。
 * 3.订单总额 = 商品总额 + 包装费 + 配送费 + 税费。
 * 4.实收总额 = 订单总额 - 立减金额 - 其他优惠。
 * 5.应付总额 = 实收总额 - 已付总额。
 */

- (void)calculatePrice
{
    self.dealPrice=self.totalPrice+[self.packing.price floatValue]+[self.delivery.price floatValue]-self.cutPrice -self.favoPrice;
    if([self.invoiceInfo[@"InvoiceType"] integerValue]){
        UserInfo *userInfo = [UserInfo shareUserInfo];
        self.taxPrice = self.dealPrice*userInfo.taxPercend;
        self.dealPrice += self.taxPrice;
        self.dealPrice-=self.paidPrice;
    }
    self.dealPrice = round(self.dealPrice*100)/100;
}

- (NSString *)aeskeyOrNot:(NSString *)value aes:(BOOL)aes
{
    NSString *string = nil;
    if (value == nil || [value isKindOfClass:[NSNull class]] ) {
        return @"";
    }
    NSString *newValue=[NSString stringWithFormat:@"%@",value ];
    if([newValue isEqualToString:@""]){
        return @"";
    }else if(!aes){
        return newValue;
    }else{
        string = [newValue AES256EncryptWithKey:kAESKey];
        return string;
    }
}

//加密
-(MutableOrderedDictionary *)dictWithAES
{
    NSDictionary *invoceDict = [NSDictionary dictionaryWithDictionary:self.invoiceInfo];
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:self.userKey aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.orderCode aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.addressID aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceType"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceTitle"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.delivery.code aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.packing.code aes:NO]];
    [lStr appendString:kAESKey];
//    key,OrderCode,address_id,InvoiceType,InvoiceTitle,DeliveryCode,PackingCode
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:self.userKey aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:self.orderCode aes:NO] forKey:@"OrderCode" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:self.addressID aes:NO] forKey:@"AddressCode" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceType"] aes:NO] forKey:@"InvoiceType" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceTitle"] aes:NO] forKey:@"InvoiceTitle" atIndex:4];
    [orderArr insertObject:[self aeskeyOrNot:self.delivery.code aes:NO] forKey:@"DeliveryCode" atIndex:5];
    [orderArr insertObject:[self aeskeyOrNot:self.packing.code aes:NO] forKey:@"PackingCode" atIndex:6];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:7];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:8];
    return orderArr;
}
//加密
-(MutableOrderedDictionary *)updatedictWithAES
{
    NSDictionary *invoceDict = [NSDictionary dictionaryWithDictionary:self.invoiceInfo];
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:self.userKey aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.orderCode aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.addressID aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceType"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceTitle"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.delivery.code aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.packing.code aes:NO]];
    [lStr appendString:kAESKey];
    //    key,OrderCode,address_id,InvoiceType,InvoiceTitle,DeliveryCode,PackingCode
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:self.userKey aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:self.orderCode aes:NO] forKey:@"OrderCode" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:self.addressID aes:NO] forKey:@"AddressCode" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceType"] aes:NO] forKey:@"InvoiceType" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceTitle"] aes:NO] forKey:@"InvoiceTitle" atIndex:4];
    [orderArr insertObject:[self aeskeyOrNot:self.delivery.code aes:NO] forKey:@"DeliveryCode" atIndex:5];
    [orderArr insertObject:[self aeskeyOrNot:self.packing.code aes:NO] forKey:@"PackingCode" atIndex:6];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:7];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:8];
    return orderArr;
}

@end

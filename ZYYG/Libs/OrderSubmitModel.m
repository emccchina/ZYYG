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

- (NSString*)aeskeyOrNot:(NSString*)value aes:(BOOL)aes
{
    NSString *string = nil;
    if ([value isEqualToString:@""] || !value) {
        return @"";
    }else if(!aes){
        return value;
    }
    else{
        string = [value AES256EncryptWithKey:kAESKey];
        return string;
    }
}

//加密
-(MutableOrderedDictionary *)dictWithAES
{
    NSDictionary *invoceDict = [NSDictionary dictionaryWithDictionary:self.invoiceInfo];
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:self.userKey aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.addressID aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceType"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceTitle"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"RegAccount"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"RegAddress"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"RegBank"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"RegPhone"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:self.invoiceInfo[@"InvoiceTaxNo"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.productIDs aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.delivery.code aes:NO]];
    [lStr appendString:[self aeskeyOrNot:self.packing.code aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:self.userKey aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:self.addressID aes:NO] forKey:@"address_id" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceType"] aes:NO] forKey:@"InvoiceType" atIndex:2];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceTitle"] aes:NO] forKey:@"InvoiceTitle" atIndex:3];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"RegAccount"] aes:YES] forKey:@"RegAccount" atIndex:4];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"RegAddress"] aes:YES] forKey:@"RegAddress" atIndex:5];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"RegBank"] aes:YES] forKey:@"RegBank" atIndex:6];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"RegPhone"] aes:YES] forKey:@"RegPhone" atIndex:7];
    [orderArr insertObject:[self aeskeyOrNot:invoceDict[@"InvoiceTaxNo"] aes:NO] forKey:@"InvoiceTaxNo" atIndex:8];
    [orderArr insertObject:[self aeskeyOrNot:self.productIDs aes:NO] forKey:@"product_id" atIndex:9];
    [orderArr insertObject:[self aeskeyOrNot:self.delivery.code aes:NO] forKey:@"DeliveryCode" atIndex:10];
    [orderArr insertObject:[self aeskeyOrNot:self.packing.code aes:NO] forKey:@"PackingCode" atIndex:11];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:12];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:13];
    NSLog(@"aes dict is %@-----", orderArr);
    return orderArr;
}

@end

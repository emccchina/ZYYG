//
//  Utities.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "Utities.h"
#import <CommonCrypto/CommonDigest.h>
#import "JGProgressHUD.h"
#import "AppDelegate.h"
#import "APay.h"
#import "NSString+AES.h"
@implementation Utities

+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string
{
    if (string == nil) {
        return CGSizeZero;
    }
    
    return [string sizeWithAttributes:@{NSFontAttributeName: font}];
    
}

+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string rect:(CGSize)size
{
    if (string == nil) {
        return CGSizeZero;
    }
    return [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    
}

+ (CGSize)sizeWithUIFont:(UIFont*)font string:(NSString*)string rect:(CGSize)size space:(CGFloat)space
{
    if (string == nil) {
        return CGSizeZero;
    }
    //设置行间距
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    //        style.minimumLineHeight = 30.f;
    //        style.maximumLineHeight = 30.f;
    //        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    [style setLineSpacing:space];
    
    return [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font, NSParagraphStyleAttributeName : style} context:nil].size;
    
}

+ (UIBarButtonItem*)barButtonItemWithSomething:(id)some target:(id)target action:(SEL)sel
{
    UIBarButtonItem *item = nil;
    if ([some isKindOfClass:[UIImage class]]) {
        item = [[UIBarButtonItem alloc] initWithImage:(UIImage *)some style:UIBarButtonItemStyleDone target:target action:sel];
    }else{
        item = [[UIBarButtonItem alloc] initWithTitle:(NSString *)some style:UIBarButtonItemStyleDone target:target action:sel];
        item.tintColor = [UIColor whiteColor];
    }
    return item;
}

+ (CATransition *)getAnimation:(NSInteger)mytag{
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    switch (mytag) {
        case 1:
            animation.type = kCATransitionFade;
            break;
        case 2:
            animation.type = kCATransitionPush;
            break;
        case 3:
            animation.type = kCATransitionReveal;
            break;
        case 4:
            animation.type = kCATransitionMoveIn;
            break;
        case 5:
            animation.type = @"cube";
            break;
        case 6:
            animation.type = @"suckEffect";
            break;
        case 7:
            animation.type = @"oglFlip";
            break;
        case 8:
            animation.type = @"rippleEffect";
            break;
        case 9:
            animation.type = @"pageCurl";
            break;
        case 10:
            animation.type = @"pageUnCurl";
            break;
        case 11:
            animation.type = @"cameraIrisHollowOpen";
            break;
        case 12:
            animation.type = @"cameraIrisHollowClose";
            break;
        default:
            break;
    }
    
    
    int i = (int)rand()%4;
    switch (i) {
            
        case 0:
            animation.subtype = kCATransitionFromLeft;
            break;
        case 1:
            animation.subtype = kCATransitionFromBottom;
            break;
        case 2:
            animation.subtype = kCATransitionFromRight;
            break;
        case 3:
            animation.subtype = kCATransitionFromTop;
            break;
        default:
            break;
    }
    return animation;
}

+ (void)presentLoginVC:(UIViewController*)parentVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PublicStoryboard" bundle:nil];
    UIViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    vc.hidesBottomBarWhenPushed = YES;
    [parentVC.navigationController.view.layer addAnimation:[Utities getAnimation:5] forKey:nil];
    [parentVC.navigationController pushViewController:vc animated:YES];
}

+ (NSString*)filePathName:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//需要的路径
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *temDirectory = [documentsDirectory stringByAppendingPathComponent:kTem];
    BOOL isDict = YES;
    if (![fileManager fileExistsAtPath:temDirectory isDirectory:&isDict]) {
        [fileManager createDirectoryAtPath:temDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (void)setUserDefaults:(id)object key:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

+ (id)getUserDefaults:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key] ? : @"";
}

+ (NSString*)md5AndBase:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSData* data = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    NSString *hash = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return hash;
    
}

+ (void)errorPrint:(NSError*)error vc:(UIViewController*)vc
{
#ifdef DEBUG
    NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    NSLog(@"%@,%@,%@",[vc class],error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
    
}
+ (void)showMessageOnWindow:(NSString*)message
{
    JGProgressHUD *bottomHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    bottomHUD.useProgressIndicatorView = NO;
    bottomHUD.userInteractionEnabled = NO;
    bottomHUD.textLabel.text = message;
    bottomHUD.position = JGProgressHUDPositionBottomCenter;
    bottomHUD.marginInsets = (UIEdgeInsets) {
        .top = 0.0f,
        .bottom = 200.0f,
        .left = 0.0f,
        .right = 0.0f,
    };
    
    [bottomHUD showInView:[[UIApplication sharedApplication].delegate window]];
    
    [bottomHUD dismissAfterDelay:1.0f];
}

+ (NSString*)doWithPayList:(NSString *)result
{
    NSString *message = nil;
    
    NSArray *parts = [result componentsSeparatedByString:@"="];
    NSError *error;
    NSData *data = [[parts lastObject] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSInteger payResult = [dic[@"payResult"] integerValue];
    if (payResult == APayResultSuccess) {
        message = [NSString stringWithFormat:@"支付成功,订单号:%@",dic[@"payOrderId"]];
    } else if (payResult == APayResultFail) {
        message = @"支付失败";
    } else if (payResult == APayResultCancel) {
        message = @"支付取消";
    }
    
    return message;
}

+ (NSDictionary*)AESAndMD5:(NSDictionary *)dict
{
    NSLog(@"%f", [NSDate date].timeIntervalSince1970);
    NSMutableDictionary* dictAES = [NSMutableDictionary dictionary];
    NSMutableString *md5String = [NSMutableString string];
    NSArray *keys = [dict allKeys];
    for (NSString *key in keys) {
        [md5String appendString:key];
        NSString *value = dict[key];
        NSString *valueAES = [value AES256EncryptWithKey:kAESKey];
        [dictAES setObject:valueAES forKey:key];
    }
    
    NSString *mString = [Utities md5AndBase:md5String];
    [dictAES setObject:mString forKey:@"m"];
    NSLog(@"%f", [NSDate date].timeIntervalSince1970);
    return dictAES;
}

@end

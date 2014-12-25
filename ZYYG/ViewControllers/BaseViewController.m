//
//  BaseViewController.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "BaseViewController.h"

#import "JGProgressHUD.h"
#import "JGProgressHUDPieIndicatorView.h"
#import "JGProgressHUDRingIndicatorView.h"
#import "JGProgressHUDFadeZoomAnimation.h"

@interface BaseViewController()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    JGProgressHUD *HUD;
    JGProgressHUD *bottomHUD;
}

@end

@implementation BaseViewController

- (void)showIndicatorView:(NSString*)text
{
    if (!HUD) {
        HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    }
    HUD.textLabel.text = text;
    if (self.navigationController) {
        [HUD showInView:self.navigationController.view];
    }else{
        [HUD showInView:self.view];
    }
}

- (void)dismissIndicatorView
{
    if (HUD) {
        [HUD dismiss];
        [HUD removeFromSuperview];
    }
}

- (void)showBottomAlertView:(NSString*)message
{
    if (!bottomHUD) {
        bottomHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    }
    bottomHUD.useProgressIndicatorView = NO;
    bottomHUD.userInteractionEnabled = NO;
    bottomHUD.textLabel.text = @"Hello, World!";
    bottomHUD.position = JGProgressHUDPositionBottomCenter;
    bottomHUD.marginInsets = (UIEdgeInsets) {
        .top = 0.0f,
        .bottom = 100.0f,
        .left = 0.0f,
        .right = 0.0f,
    };
    
    [bottomHUD showInView:self.view];
    
    [bottomHUD dismissAfterDelay:1.0f];
}

- (void)showBackItem
{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backSign"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    leftItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)back
{
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertViewTwoBut:(NSString*)title message:(NSString *)message actionTitle:(NSString*)actionTitle
{
    if (iPhone_iOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    [self doAlertView];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:actionTitle
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self doAlertViewTwo];
                                                }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)showAlertView:(NSString*)message
{
    if (iPhone_iOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self doAlertView];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void)presentCameraVC
{
    UIActionSheet* sheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    [sheet showInView:self.view];
    
}

- (id)parseResults:(id)resultResponds
{
    NSError *error = nil;
    NSDictionary* result = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:(NSData*)resultResponds options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"parse rusults error %@", error);
        [self showAlertView:@"数据解析出错"];
        return nil;
    }
    if ([result[@"errno"] integerValue]) {
        [self showAlertView:result[@"msg"]];
        return nil;
    }
    return result;
    
}

- (void)doAlertView
{
    
}

- (void)doAlertViewTwo
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button Index click %ld", (long)buttonIndex);
    if (buttonIndex == 0) {
        [self doAlertView];
    }else{
        [self doAlertViewTwo];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    
}


#pragma mark - UIImagePickerViewControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //     DLog(@"info %@, %d", NSStringFromCGSize(image.size), [UIImageJPEGRepresentation(image, 1.0) length]);
    if (!image) {
        return;
    }
    
    // Set desired maximum height and calculate width
    NSData* imageZoom = [self imageSizeAfterZoom:image];
    if ([self respondsToSelector:@selector(selectImageFinished:)]) {
        [self selectImageFinished:imageZoom];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    //    CGFloat imageWidth = MAX(size.width, size.height);
    //    CGFloat smaller = MIN(size.width, size.height);
    //    [img drawInRect:CGRectMake((size.width-smaller)/2, (size.height-smaller)/2, smaller, smaller)];
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}


- (NSData*)imageSizeAfterZoom:(UIImage*)image
{
    CGFloat scaleImage = 0;
    CGSize imageSize = [image size];
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    CGSize imageSizeZoom = CGSizeZero;
    if (imageWidth < imageHeight) {
        scaleImage = imageHeight/500;
    }else{
        scaleImage = imageWidth/500;
    }
    imageSizeZoom = CGSizeMake(imageWidth/scaleImage, imageHeight/scaleImage);
    UIImage* imageZoom = [self scaleToSize:image size:imageSizeZoom];
    
    NSUInteger dataLenthDefault = 600000;
    
    NSData* data = UIImageJPEGRepresentation(imageZoom, 1.0);
    
    if ([data length] > dataLenthDefault) {
        
        data = UIImageJPEGRepresentation(imageZoom, (CGFloat)dataLenthDefault/(CGFloat)[data length]);
        
    }
    
    return data;
}

- (void)selectImageFinished:(NSData *)image
{
    
}



@end

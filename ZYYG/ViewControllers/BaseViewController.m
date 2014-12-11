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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    UIViewController *vc = segue.destinationViewController;
//    vc.hidesBottomBarWhenPushed = YES;
//}

- (void)showIndicatorView:(NSString*)text
{
    if (!HUD) {
        HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    }
    HUD.textLabel.text = text;
    [HUD showInView:self.view];
}

- (void)dismissIndicatorView
{
    if (HUD) {
        [HUD dismiss];
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self doAlertView];
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
//    UIImage* imageZoom = [self imageSizeAfterZoom:image];
//    
//    _avatarIV.image = imageZoom;
//    if (_photoView) {
//        _photoView.hidden = YES;
//    }
    if ([self respondsToSelector:@selector(selectImageFinished:)]) {
        [self selectImageFinished:image];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)selectImageFinished:(UIImage *)image
{
    
}



@end

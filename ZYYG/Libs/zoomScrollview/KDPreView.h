//
//  KDPreView.h
//  Camera
//
//  Created by wu on 13-10-14.
//  Copyright (c) 2013年 wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KDPreView;
@protocol KDPreviewDelegate <NSObject>

@end

@interface KDPreView : UIScrollView
<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIImage*                  placeholderImage;
@property (nonatomic, strong) NSString*                 imageURL;//网络图片

- (void)imageShow;
- (void)viewAdjustFrame;

@end

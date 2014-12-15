//
//  KDPreView.m
//  Camera
//
//  Created by wu on 13-10-14.
//  Copyright (c) 2013年 wu. All rights reserved.
//

#import "KDPreView.h"

@interface KDPreView()
{
    UIView*                 gestureView;
    UIGestureRecognizer*    singleTap;
    UIImageView*            photoView;
    CGPoint                 proPoint;
    CGFloat                 gestureX;
    CGFloat                 gestureY;
}


@end

@implementation KDPreView

- (void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setupView:self];
        
    }
    return self;
}

- (void)viewAdjustFrame
{
    [self adjustFrame];
}

- (void)layoutSubviews
{

}


- (void)setupView:(UIView*)parentView
{
    photoView = [[UIImageView alloc] init];
    photoView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    photoView.contentMode = UIViewContentModeScaleAspectFit;
    [parentView addSubview:photoView];
    
}

- (void)adjustLittleSign
{
    if (photoView.image == nil) {
        return;
    }
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    CGSize imageSize = photoView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    photoView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    photoView.center = CGPointMake(boundsWidth/2.0, boundsHeight/2.0);
}


- (void)adjustFrame
{
	if (photoView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = photoView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
	// 设置伸缩比例
    CGFloat minScale;

	CGFloat maxScale = 2.0;

    
    CGFloat  scaleWidth = imageWidth/boundsWidth;
    CGFloat  scaleHeight = imageHeight/boundsHeight;
    CGRect   imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    if (scaleWidth > scaleHeight) {
        
        minScale = 1/scaleWidth;
        
        imageFrame.size.width = boundsWidth;
        imageFrame.size.height = imageHeight/scaleWidth;
        
    }else{
        
        minScale = 1/scaleHeight;
        imageFrame.size.width = imageWidth/scaleHeight;
        imageFrame.size.height = boundsHeight;
    }
    
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    
    // 内容尺寸
    self.contentSize = CGSizeMake(imageFrame.size.width, imageFrame.size.height);
    photoView.frame = imageFrame;
    photoView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
}

- (void)adjustPhotoView:(UIImage*)image;
{
    CGSize imageSize = [image size];
    CGRect photoRect = photoView.frame;
    photoRect.size.width = imageSize.width;
    photoRect.size.height = imageSize.height;
    photoView.frame = photoRect;
    photoView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}


- (void)imageShow
{
    [photoView setImageWithURL:[NSURL URLWithString:self.imageURL]];
    [self adjustFrame];
}


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return photoView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGRect rect = view.frame;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    CGFloat viewWidth = view.frame.size.width;
    CGFloat viewHeight = view.frame.size.height;

    if (viewWidth < boundsWidth) {
        rect.origin.x = (boundsWidth - viewWidth) /2.0;
    }else{
        rect.origin.x = 0;
    }
    
    if (viewHeight < boundsHeight){
        rect.origin.y = (boundsHeight - viewHeight) / 2;
    }else{
        rect.origin.y = 0;
    }
    view.frame = rect;
    
}

//#pragma mark - UIGestureReconginzerDelegate
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

@end

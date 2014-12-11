//
//  ImageScrollCell.m
//  ZYYG
//
//  Created by wu on 14/11/22.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "ImageScrollCell.h"

@implementation ImageScrollCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)reloadScrollViewData
{
    if (!self.scrollView) {
        self.scrollView = [[CycleScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.datasource = self;
        self.scrollView.animationDuration = 3;
        [self addSubview:self.scrollView];
    }
    [self.scrollView reloadData];
}

- (NSInteger)numberOfPages
{
    return self.images.count;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    CGRect rect = self.scrollView.bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    if (self.images.count > index) {
        NSString *url = self.style ? self.images[index] : [self.images[index] safeObjectForKey:@"Url"];
        if ([url isKindOfClass:[NSNull class]]) {
            url = @"";
        }
        [imageView setImageWithURL:[NSURL URLWithString:url]];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (void)didClickPage:(CycleScrollView *)csView atIndex:(NSInteger)index
{
    if (self.style) {
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"当前点击第%ld个页面",(long)index]
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end

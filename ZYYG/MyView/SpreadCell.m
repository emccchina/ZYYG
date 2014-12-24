//
//  SpreadCell.m
//  ZYYG
//
//  Created by EMCC on 14/11/26.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SpreadCell.h"

@implementation SpreadCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    createTopLine
    createBottomLine
    self.detailLab.numberOfLines = 0;
    self.detailWebView.delegate = self;
    self.webViewHeight = 0;
    self.detailWebView.scalesPageToFit = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)spreadButtonPressed:(id)sender {
    if (self.detailWebView.isLoading) {
       [Utities showMessageOnWindow:@"正在加载中,请稍候"];
        return;
    }
    _spreadState = !_spreadState;
    if (self.reloadHeight) {
        self.reloadHeight(_spreadState, self.webViewHeight);
    }
    
}

- (void)setSpreadState:(BOOL)spreadState
{
    _spreadState = spreadState;
    self.detailWebView.hidden = !_spreadState;
    UIImage *image = _spreadState ? [UIImage imageNamed:@"down"] : [UIImage imageNamed:@"left"];
    [self.spreadButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIScrollView* scrollView = [webView scrollView];
    
    scrollView.bounces = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    NSLog(@"%@", NSStringFromCGSize(scrollView.contentSize));
    self.webViewHeight = scrollView.contentSize.height;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end

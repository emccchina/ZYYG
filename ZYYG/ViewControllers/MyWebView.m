//
//  MyWebView.m
//  ZYYG
//
//  Created by EMCC on 14/12/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyWebView.h"

@interface MyWebView ()

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@end

@implementation MyWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.myTitle;
    [self showBackItem];
    self.myWebView.delegate = self;
    // Do any additional setup after loading the view.
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.webViewURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self dismissIndicatorView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self dismissIndicatorView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showIndicatorView:kNetworkConnecting];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

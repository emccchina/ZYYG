//
//  MyWebView.h
//  ZYYG
//
//  Created by EMCC on 14/12/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "BaseViewController.h"

@interface MyWebView : BaseViewController
<UIWebViewDelegate>
@property (nonatomic, strong) NSString *webViewURL;
@property (nonatomic, strong) NSString *myTitle;
@end

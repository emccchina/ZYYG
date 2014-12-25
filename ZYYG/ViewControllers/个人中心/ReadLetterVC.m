//
//  ReadLetterVC.m
//  ZYYG
//
//  Created by champagne on 14-12-13.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ReadLetterVC.h"

@interface ReadLetterVC ()

@end

@implementation ReadLetterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    
    self.letterTitle.numberOfLines = 0;
    [self readLetter:[self letter]];
    
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)readLetter:(LetterModel*)letter
{
    self.letterFrom.text=letter.SendName;
    self.letterTitle.text=letter.Title;
    self.letterCreateTime.text=letter.AuditTime;
    self.letterCode=letter.LetterCode;
    [self.letterContent loadHTMLString:letter.LetterContent baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
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

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
     NSLog(@"%@",self.letter.Title);
    [super viewDidLoad];
    [self showBackItem];
    NSLog(@"%@",self.letter.Title);
//    [self readLetter:[self letter]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)readLetter:(LetterModel*)letter
{
    self.from.text=letter.SendName;
    self.title.text=letter.Title;
    self.createTime.text=letter.AuditTime;
    self.content.text=letter.LetterContent;
    self.letterCode=letter.LetterCode;
    
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

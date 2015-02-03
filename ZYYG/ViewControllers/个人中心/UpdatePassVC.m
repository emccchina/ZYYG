//
//  UpdatePassVC.m
//  ZYYG
//
//  Created by champagne on 14-12-18.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "UpdatePassVC.h"

@interface UpdatePassVC ()
{
    BOOL chageSuccessuful;
    UserInfo *user;
}

@end

@implementation UpdatePassVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    chageSuccessuful=NO;
    user =[UserInfo shareUserInfo];
    
    self.passOld.delegate = self;
    self.passNew.delegate = self;
    self.passAgain.delegate = self;
    
    [self.passOld setSecureTextEntry:YES];
    [self.passNew setSecureTextEntry:YES];
    [self.passAgain setSecureTextEntry:YES];
    
    self.submitButton.layer.cornerRadius = 3;
    self.submitButton.layer.backgroundColor = kRedColor.CGColor;
    NSLog(@"修改密码");
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressButton:(id)sender {
    if ([self.passOld.text isEqualToString:@""] || [self.passNew.text isEqualToString:@""] || [self.passAgain.text isEqualToString:@""] ) {
        [self showAlertView:@"请填写密码!"];
        return;
    }
    if (self.passNew.text.length > 20 || self.passNew.text.length < 8 ) {
        [self showAlertView:@"密码长度应在8--20之间!"];
        return;
    }
    if (![self.passNew.text isEqualToString:self.passAgain.text]) {
        [self showAlertView:@"两次输入的新密码不同!"];
        return;
    }
    

    [self changePassword];
}

- (void)changePassword
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@ChangePass.ashx",kServerDomain];
    NSString *old_pass = [Utities md5AndBase:self.passOld.text];
    NSString *new_pass = [Utities md5AndBase:self.passNew.text];
        NSLog(@"url %@, %@, %@", url, old_pass, new_pass);
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",old_pass, @"old_pass",new_pass, @"new_pass", nil];
    MutableOrderedDictionary *newDict=[self dictWithAES:regsiterDict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
            id result = [self parseResults:responseObject];
        if (result) {
            [self showAlertView:@"修改成功,请重新登录"];
//            user=nil;
            //此处logout
            chageSuccessuful=YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)doAlertView
{
    if (chageSuccessuful) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)changeConstraint:(CGFloat)top restore:(BOOL)restore
{
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTop && [constraint.firstItem isEqual:self.backView] && [constraint.secondItem isEqual:self.view]) {
            CGFloat space = (restore ? 0 : (constraint.constant += top));
            [self.view removeConstraint:constraint];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.backView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:space]];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint point = textField.frame.origin;
    //    NSLog(@"super view frame %@", NSStringFromCGPoint(point));
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 160) - 250;
    if (space < 0) {
        [self changeConstraint:space restore:NO];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //    self.view.frame = _initFrame;
    [self changeConstraint:0 restore:YES];
}

//加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"key"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"old_pass"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"new_pass"] aes:YES]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"key"] aes:NO] forKey:@"key" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"old_pass"] aes:YES] forKey:@"old_pass" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"new_pass"] aes:YES] forKey:@"new_pass" atIndex:2];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:3];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:4];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}


@end

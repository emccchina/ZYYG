//
//  RegisterVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "RegisterVC.h"

@interface RegisterVC ()
<UITextFieldDelegate>
{
    BOOL    agree;//是否同意协议
    BOOL    registerSuccessuful;
}
@property (weak, nonatomic) IBOutlet UIView *BGView;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *registerBut;
@property (weak, nonatomic) IBOutlet UIButton *agreeBut;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTF;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    self.title = @"注册";
    self.accountTF.delegate = self;
    self.passwordTF.delegate = self;
    self.passwordAgainTF.delegate = self;
    [self.passwordAgainTF setSecureTextEntry:YES];
    [self.passwordTF setSecureTextEntry:YES];
    self.emailTF.delegate = self;
    self.registerBut.layer.cornerRadius = 3;
    self.registerBut.layer.backgroundColor = kRedColor.CGColor;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeConstraint:(CGFloat)top restore:(BOOL)restore
{
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeTop && [constraint.firstItem isEqual:self.BGView] && [constraint.secondItem isEqual:self.view]) {
            CGFloat space = (restore ? 0 : (constraint.constant += top));
            [self.view removeConstraint:constraint];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.BGView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:space]];
        }
    }
}
- (IBAction)doAgree:(id)sender {
    agree = !agree;
    UIImage *butImage = agree ? [UIImage imageNamed:@"accountSelected"] : [UIImage imageNamed:@"accountUnselected"];
    [self.agreeBut setImage:butImage forState:UIControlStateNormal];
}
- (IBAction)doRegister:(id)sender {
    if (!agree) {
        [self showAlertView:@"请签署中艺易购协议协议"];
        return;
    }
    if ([self.accountTF.text isEqualToString:@""] || [self.emailTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""] || [self.passwordAgainTF.text isEqualToString:@""]) {
        [self showAlertView:@"请完善基本信息"];
        return;
    }
    if (![self.passwordAgainTF.text isEqualToString:self.passwordTF.text]) {
        [self showAlertView:@"两次密码不同"];
        return;
    }
    [self requestRegister];
}

- (void)requestRegister
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@reg.ashx",kServerDomain];
    NSString *password = [Utities md5AndBase:self.passwordTF.text];
    NSLog(@"url %@, %@, %d", url, password, password.length);
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.accountTF.text, @"username",password, @"pass",self.emailTF.text, @"email", nil];
    [manager POST:url parameters:regsiterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [self showAlertView:@"注册成功,请激活邮件后登录"];
            registerSuccessuful = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)doAlertView
{
    if (registerSuccessuful) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - UITextFieldDelegate
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

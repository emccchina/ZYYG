//
//  ForgetPasswordVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/22.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ForgetPasswordVC.h"
#import "RegisterVC.h"
@interface ForgetPasswordVC ()
<UITextFieldDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *getCaptcha;
@property (weak, nonatomic) IBOutlet UIButton *haveCaptcha;
@end

@implementation ForgetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    self.view.backgroundColor = kBGGrayColor;
    self.title = @"找回密码";
    self.emailTF.delegate = self;
    self.getCaptcha.layer.cornerRadius = 5;
    self.getCaptcha.layer.backgroundColor = kRedColor.CGColor;
    self.haveCaptcha.layer.cornerRadius = 5;
    self.haveCaptcha.layer.backgroundColor = kRedColor.CGColor;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doGetCaptcha:(id)sender {
    [self requestForgetPassword];
}
- (IBAction)doHaveCaptcha:(id)sender {
    [self performSegueWithIdentifier:@"RetakeVC" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[RegisterVC class]]) {
        RegisterVC* registerVC = (RegisterVC*)destVC;
        registerVC.typeVC = 1;
        registerVC.hidesBottomBarWhenPushed = YES;
    }
}
- (void)requestForgetPassword
{
    if (self.emailTF.text.length <= 0) {
        [self showAlertView:@"请输入邮箱"];
        return;
    }
    [self.emailTF resignFirstResponder];
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SendEmailPass.ashx",kServerDomain];
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.emailTF.text, @"email", nil];
    [manager POST:url parameters:regsiterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            [self showAlertView:@"验证码已发送至邮箱，请查收"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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

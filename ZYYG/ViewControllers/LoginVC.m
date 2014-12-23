//
//  LoginVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()
<UITextFieldDelegate>
{
    BOOL        rememberAccount;
}
@property (weak, nonatomic) IBOutlet UIImageView *BGImage;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UITextField *accoutTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *rememberBut;
@property (weak, nonatomic) IBOutlet UIButton *loginBut;
@property (weak, nonatomic) IBOutlet UIButton *registerBut;
@property (weak, nonatomic) IBOutlet UIButton *forgetBut;
@property (weak, nonatomic) IBOutlet UIButton *sinaLoginBut;
@property (weak, nonatomic) IBOutlet UIButton *QQLoginBut;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.index = 7;
    // Do any additional setup after loading the view.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:(iPhone4 ? 30 : 50)]];
//    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"LoginBG" ofType:@"png"];
    UIImage *bgImage = [UIImage imageWithContentsOfFile:imagePath];
    self.BGImage.image = bgImage;
    self.accoutTF.delegate = self;
    self.passwordTF.delegate = self;
    [self.passwordTF setSecureTextEntry:YES];
    self.loginBut.layer.cornerRadius = 3;
    self.loginBut.layer.backgroundColor = kRedColor.CGColor;
    self.sinaLoginBut.layer.borderColor = kRedColor.CGColor;
    self.sinaLoginBut.layer.borderWidth = 1;
    self.QQLoginBut.layer.borderWidth  = 1;
    self.QQLoginBut.layer.borderColor = kRedColor.CGColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    rememberAccount = [[Utities getUserDefaults:kRememberAccount] integerValue];
    [self setRememberState];
    NSString *account = [Utities getUserDefaults:kAccountKey];
    self.accoutTF.text = account;
#ifdef DEBUG
    self.passwordTF.text = [Utities getUserDefaults:kAccountPassword];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSString *account = rememberAccount ? self.accoutTF.text : @"";
    [Utities setUserDefaults:account key:kAccountKey];
#ifdef DEBUG
    NSString *password = rememberAccount ? self.passwordTF.text : @"";
    [Utities setUserDefaults:password key:kAccountPassword];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToContent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doRememberBut:(id)sender {
    rememberAccount = !rememberAccount;
    [self setRememberState];
}

- (void)setRememberState
{
    UIImage *image = rememberAccount ? [UIImage imageNamed:@"accountSelected"] : [UIImage imageNamed:@"accountUnselected"];
    [self.rememberBut setImage:image forState:UIControlStateNormal];
    [Utities setUserDefaults:@(rememberAccount) key:kRememberAccount];
}


- (IBAction)doLoginBut:(id)sender {
//    [self presentCameraVC];
    [self requestLogin];
}
- (IBAction)doRegisterBut:(id)sender {
}
- (IBAction)doForgetBut:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doSinaBut:(id)sender {
}
- (IBAction)doQQBut:(id)sender {
}

- (void)requestLogin
{
    if ([self.accoutTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""]) {
        [self showAlertView:@"请填写用户名和密码"];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@login.ashx",kServerDomain];
    NSString *password = [Utities md5AndBase:self.passwordTF.text];
    NSLog(@"url %@, %@", url, password);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.accoutTF.text, @"email",password, @"pass", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            UserInfo *userInfo = [UserInfo shareUserInfo];
            [userInfo setParams:userInfo parmas:result];
            [self.navigationController popViewControllerAnimated:YES];
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
    CGPoint point = textField.frame.origin;
    //    NSLog(@"super view frame %@", NSStringFromCGPoint(point));
    CGFloat height = kScreenHeight;
    CGFloat space = (height - point.y - 100) - 250;
    if (space < 0) {
        CGRect rect = self.view.frame;
        rect.origin.y += space;
        self.view.frame = rect;
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = self.view.frame;
    rect.origin = CGPointZero;
    self.view.frame = rect;
    
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

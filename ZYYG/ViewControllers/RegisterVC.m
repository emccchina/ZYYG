//
//  RegisterVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/2.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "RegisterVC.h"
#import "LoginVC.h"
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
    [self setInitState];
    self.accountTF.delegate = self;
    self.passwordTF.delegate = self;
    self.passwordAgainTF.delegate = self;
    [self.passwordAgainTF setSecureTextEntry:YES];
    [self.passwordTF setSecureTextEntry:YES];
    self.emailTF.delegate = self;
    self.registerBut.layer.cornerRadius = 3;
    self.registerBut.layer.backgroundColor = kRedColor.CGColor;
    
    
}

- (void)setInitState
{
    self.title = self.typeVC ? @"找回密码" : @"注册帐号";
    self.agreeBut.hidden = self.typeVC;
    self.accountTF.placeholder = self.typeVC ? @"请输入验证码" : @"请输入用户名";
    [self.registerBut setTitle:(self.typeVC ? @"确定" : @"注册") forState:UIControlStateNormal];
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
    
    if (self.typeVC) {
        [self requestForNewPassword];
        return;
    }
    [self requestRegister];
}

- (void)requestForNewPassword
{
    if ([self.passwordTF.text length] < 8) {
        [self showAlertView:@"密码大于八位"];
        return;
    }
    if ([self.accountTF.text isEqualToString:@""] || [self.emailTF.text isEqualToString:@""] || [self.passwordTF.text isEqualToString:@""] || [self.passwordAgainTF.text isEqualToString:@""]) {
        [self showAlertView:@"请完善信息"];
        return;
    }
    if (![self.passwordAgainTF.text isEqualToString:self.passwordTF.text]) {
        [self showAlertView:@"两次密码不同"];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@RetakePassWord.ashx",kServerDomain];
    NSString *password = [Utities md5AndBase:self.passwordTF.text];
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.accountTF.text, @"CheckCode",password, @"PassWord",self.emailTF.text, @"Username", nil];
    MutableOrderedDictionary *newDict= [self dictWithAES:regsiterDict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            NSArray *array = self.navigationController.viewControllers;
            for (UIViewController* vc in array) {
                if ([vc isKindOfClass:[LoginVC class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                    return;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
        
    }];
}

- (void)requestRegister
{
    if ([self.passwordTF.text length] < 8) {
        [self showAlertView:@"密码大于八位"];
        return;
    }
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
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@reg.ashx",kServerDomain];
    NSString *password = [Utities md5AndBase:self.passwordTF.text];
//    NSLog(@"url %@, %@, %d", url, password, password.length);
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

//加密
-(MutableOrderedDictionary *)dictWithAES:(NSDictionary *)oDict
{
    NSMutableString *lStr=[NSMutableString string];
    [lStr appendString:[self aeskeyOrNot:oDict[@"Username"] aes:NO]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"PassWord"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"CheckCode"] aes:NO]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"Username"] aes:NO] forKey:@"Username" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"PassWord"] aes:YES] forKey:@"PassWord" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"CheckCode"] aes:NO] forKey:@"CheckCode" atIndex:2];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:3];
    [orderArr insertObject:@"5134DUIOIOO72761" forKey:@"t" atIndex:4];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
}
- (NSString *)aeskeyOrNot:(NSString *)value aes:(BOOL)aes
{
    NSLog(@"===================%@",value);
    NSString *string = nil;
    if (value == nil || [value isKindOfClass:[NSNull class]] ) {
        return @"";
    }
    NSString *newValue=[NSString stringWithFormat:@"%@",value ];
    if([newValue isEqualToString:@""]){
        return @"";
    }else if(!aes){
        return newValue;
    }else{
        string = [newValue AES256EncryptWithKey:kAESKey];
        return string;
    }
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

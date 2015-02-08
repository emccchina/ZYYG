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
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *verifyTF;
@property (weak, nonatomic) IBOutlet UIButton *getVerifiBut;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTF;
@property (weak, nonatomic) IBOutlet UIButton *agreeBut;
@property (weak, nonatomic) IBOutlet UIButton *registerBut;
@property (weak, nonatomic) IBOutlet UIImageView *fourImage;

@end

@implementation RegisterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    [self setInitState];
    self.userNameTF.delegate = self;
    self.verifyTF.delegate = self;
    self.passwordTF.delegate = self;
    self.passwordAgainTF.delegate = self;
    [self.passwordAgainTF setSecureTextEntry:YES];
    [self.passwordTF setSecureTextEntry:YES];
    self.getVerifiBut.layer.cornerRadius = 3;
    self.getVerifiBut.layer.backgroundColor = kRedColor.CGColor;
    self.registerBut.layer.cornerRadius = 3;
    self.registerBut.layer.backgroundColor = kRedColor.CGColor;
    
    
}

- (void)setInitState
{
    self.title = self.typeVC ? @"找回密码" : @"注册帐号";
    self.userNameTF.placeholder=self.typeVC ? @"手机号/邮箱" : @"手机号码";
    self.agreeBut.hidden = self.typeVC;
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

- (IBAction)getVerification:(id)sender {
    if ([self.userNameTF.text isEqualToString:@""]) {
        if (self.typeVC) {
            [self showAlertView:@"请填写手机号码/邮箱"];
            return;
        }
        [self showAlertView:@"请填写手机号码"];
        return;
    }
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@RegSendSMS.ashx",kServerDomain];
    if (self.typeVC) {
      url = [NSString stringWithFormat:@"%@SendEmailPass.ashx",kServerDomain];
    }
      NSLog(@"url is  %@", url);
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userNameTF.text, @"LoginName", nil];
    [manager POST:url parameters:regsiterDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            if([@"0" isEqual:result[@"errno"]]){
                [self showAlertView:@"已成功发送验证码"];
                [self startTime];
            }else{
                [self showAlertView:result[@"msg"]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utities errorPrint:error vc:self];
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];

}

-(void)startTime{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.getVerifiBut setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.getVerifiBut.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.getVerifiBut setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                self.getVerifiBut.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

- (void)requestForNewPassword
{
    if ([self.userNameTF.text isEqualToString:@""]||[self.verifyTF.text isEqualToString:@""]|| [self.passwordTF.text isEqualToString:@""] || [self.passwordAgainTF.text isEqualToString:@""]) {
        [self showAlertView:@"请完善信息"];
        return;
    }
    if ([self.passwordTF.text length] < 8) {
        [self showAlertView:@"密码不得少于八位"];
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
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userNameTF.text, @"LoginName",password, @"PassWord", self.verifyTF.text, @"checkCode", nil];
    MutableOrderedDictionary *newDict= [self dictWithAES:regsiterDict];
     NSLog(@"url is  %@ %@",url,regsiterDict);
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        id result = [self parseResults:responseObject];
        if (result) {
            if([@"0" isEqual:result[@"errno"]]){
                [self showAlertView:@"密码找回成功,请登录!"];
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
        [self showAlertView:@"密码不得少于八位"];
        return;
    }
    if (!agree) {
        [self showAlertView:@"请签署中艺易购协议协议"];
        return;
    }
    if  ([self.userNameTF.text isEqualToString:@""]||[self.verifyTF.text isEqualToString:@""]|| [self.passwordTF.text isEqualToString:@""] || [self.passwordAgainTF.text isEqualToString:@""]){
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
    NSLog(@"url %@, %@", url, password);
    NSDictionary *regsiterDict = [NSDictionary dictionaryWithObjectsAndKeys:self.userNameTF.text, @"LoginName",password, @"PassWord", self.verifyTF.text, @"checkCode", nil];
    MutableOrderedDictionary *newDict=[self dictWithAES:regsiterDict];
    [manager POST:url parameters:newDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is  %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self dismissIndicatorView];
        NSString *aesde = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] AES256DecryptWithKey:kAESKey];
        id result = [self parseResults:[aesde dataUsingEncoding:NSUTF8StringEncoding]];
        if (result) {
            [self showAlertView:@"注册成功,请登录"];
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
    [lStr appendString:[self aeskeyOrNot:oDict[@"LoginName"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"PassWord"] aes:YES]];
    [lStr appendString:[self aeskeyOrNot:oDict[@"checkCode"] aes:YES]];
    [lStr appendString:kAESKey];
    NSLog(@"123 %@",lStr);
    MutableOrderedDictionary *orderArr= [MutableOrderedDictionary dictionary];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"LoginName"] aes:YES] forKey:@"LoginName" atIndex:0];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"PassWord"] aes:YES] forKey:@"PassWord" atIndex:1];
    [orderArr insertObject:[self aeskeyOrNot:oDict[@"checkCode"] aes:YES] forKey:@"checkCode" atIndex:2];
    [orderArr insertObject:[Utities md5AndBase:lStr] forKey:@"m" atIndex:3];
    [orderArr insertObject:ARC4RANDOM_MAX forKey:@"t" atIndex:4];
    NSLog(@"aes dict is %@   -----   %@", orderArr, oDict);
    return orderArr;
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

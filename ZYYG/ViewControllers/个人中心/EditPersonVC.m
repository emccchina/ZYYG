//
//  EditPersonVC.m
//  ZYYG
//
//  Created by champagne on 14-12-12.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "EditPersonVC.h"

@interface EditPersonVC ()
{
    UserInfo *user;
}
@end

@implementation EditPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    user=[UserInfo shareUserInfo];
    [self showBackItem];
    self.editPersonTableView.delegate = self;
    self.editPersonTableView.dataSource = self;
    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -textField
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"textFieldCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    titleLabel.text=[self editType];
    UITextField *textField=(UITextField *)[cell viewWithTag:2];

    textField.text=[self textValue];
    return cell;
}

#pragma mark -textField

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"fffffff");
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"bbbbb");
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"nnnnnn");
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

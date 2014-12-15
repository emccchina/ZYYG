//
//  MyLetterVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyLetterVC.h"
#import "HMSegmentedControl.h"
#import "LetterModel.h"
#import "ReadLetterVC.h"

@interface MyLetterVC ()
{
    HMSegmentedControl *segmentView;
    NSMutableArray *letterArray;
    UserInfo *user;
    NSInteger selectedIndex;
    BOOL state;
}

@end

@implementation MyLetterVC

static NSString *letterCell = @"letterCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    state=YES;
    letterArray =[NSMutableArray array];
    self.myLetterTableView.delegate=self;
    self.myLetterTableView.dataSource=self;
    [self requestLetterList:1 pageNumber:1];
    // Do any additional setup after loading the view.
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    if (1==(long)segmentedControl.selectedSegmentIndex) {
        state=NO;
        [self requestLetterList:0 pageNumber:1];
    }else{
        [self requestLetterList:1 pageNumber:1];
        state=YES;
    }
    
    //    [self.myLetterTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)requestLetterList:(NSInteger)letterState  pageNumber:(NSInteger)num
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@MessageList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",[NSString stringWithFormat:@"%d",letterState],@"IsReaded",[NSString stringWithFormat:@"%d",num],@"num", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [letterArray removeAllObjects];
            NSArray *letters=result[@"data"];
            for (int i=0; i<letters.count; i++) {
                LetterModel *letter =[LetterModel letterFromDict:letters[i]];
                [letterArray addObject:letter];
                NSLog(@"站内信读取成功");
            }
            [self.myLetterTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
}
#pragma mark -tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (segmentView) {
        return segmentView;
    }
    segmentView = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"未读",@"已读"]];
    segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentView.frame = CGRectMake(0, 0, 320, 40);
    segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    return segmentView;
    
}



#pragma  mark -tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return letterArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LetterModel *letter=letterArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:letterCell forIndexPath:indexPath];
    UIImageView *headerImage = (UIImageView *)[cell viewWithTag:1];
    
    [headerImage setImage:[UIImage imageNamed:@"letter.png"]];
    
    UILabel *title = (UILabel*)[cell viewWithTag:2];
    title.text = letter.Title;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    selectedIndex=indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ReadLetter" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"传送站内信内容点击");
    LetterModel *letter=letterArray[selectedIndex];
    if (state) {
        [self requestReadLetter:letter.LetterCode];
    }
    UIViewController *vc = segue.destinationViewController;
    vc.hidesBottomBarWhenPushed = YES;
    if ([(ReadLetterVC*)vc respondsToSelector:@selector(setLetter:)]) {
        [vc setValue:letter forKey:@"letter"];
    }
    
    
}


-(void)requestReadLetter:(NSString *)letterCode
{
    user=[UserInfo shareUserInfo];
    if (![user isLogin]) {
        [Utities presentLoginVC:self];
        return;
    }
    
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SaveMessage.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",letterCode,@"LetterCode",@"1",@"IsReaded",@"0",@"Nstatus", nil];
    NSLog(@"%@",letterCode);
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [self.myLetterTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        [dataArra removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        //        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        [self.adressTB reloadData];
        [self requestForDeleteLetter:indexPath];
    }
}

- (void)requestForDeleteLetter:(NSIndexPath*)indexPath
{
    LetterModel *letter=letterArray[indexPath.row];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SaveMessage.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSString *isread;
    if (state) {
        isread=@"1";
    }else{
        isread=@"0";
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",letter.LetterCode,@"LetterCode",isread,@"IsReaded",@"-1",@"Nstatus", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            if (state) {
                [self requestLetterList:1 pageNumber:1];
            }else{
                [self requestLetterList:0 pageNumber:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertView:kNetworkNotConnect];
    }];
    
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

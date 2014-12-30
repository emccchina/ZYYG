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
    NSInteger selectedIndex; //选中的行
    BOOL state; // 已读未读 标示
    NSInteger pageNum; //页数
}

@end

@implementation MyLetterVC

static NSString *letterCell = @"letterCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    state=YES;
    pageNum=1;
    letterArray =[NSMutableArray array];
    self.myLetterTableView.delegate=self;
    self.myLetterTableView.dataSource=self;
    [self requestLetterList:1 pageNumber:pageNum];
    [self addFootRefresh];
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

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [letterArray removeAllObjects];
    pageNum=1;
    if (1==(long)segmentedControl.selectedSegmentIndex) {
        state=NO;
        [self requestLetterList:0 pageNumber:pageNum];
    }else{
        [self requestLetterList:1 pageNumber:pageNum];
        state=YES;
    }
    
    //    [self.myLetterTableView reloadData];
}
- (void)addFootRefresh
{
    [letterArray removeAllObjects];
    [self.myLetterTableView addRefreshFooterViewWithAniViewClass:[JHRefreshCommonAniView class] beginRefresh:^{
        pageNum=pageNum+1;
        NSInteger letterState = state ==YES ? 1:0;
        [self requestLetterList:letterState pageNumber:pageNum];
    }];
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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[UserInfo shareUserInfo].userKey, @"key",[NSString stringWithFormat:@"%ld",(long)letterState],@"IsReaded",[NSString stringWithFormat:@"%ld",(long)num],@"num", nil];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            NSArray *letters=result[@"data"];
            if (!letters ||[letters isKindOfClass:[NSNull class]]||letters.count<1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"无新内容!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }else {
                for (int i=0; i<letters.count; i++) {
                    LetterModel *letter =[LetterModel letterFromDict:letters[i]];
                    [letterArray addObject:letter];
                    NSLog(@"站内信读取成功");
                }
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
    [self.myLetterTableView footerEndRefreshing];
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
    if (state) {
        [headerImage setImage:[UIImage imageNamed:@"closedletter.png"]];
    }else{
        [headerImage setImage:[UIImage imageNamed:@"opendletter.png"]];
    }
    
    
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
            [letterArray removeAllObjects];
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

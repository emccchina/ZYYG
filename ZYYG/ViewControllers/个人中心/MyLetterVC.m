//
//  MyLetterVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "MyLetterVC.h"
#import "HMSegmentedControl.h"

@interface MyLetterVC ()
{
    HMSegmentedControl *segmentView;
}

@end

@implementation MyLetterVC

static NSString *letterCell = @"letterCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    self.myLetterTableView.delegate=self;
    self.myLetterTableView.dataSource=self;
    // Do any additional setup after loading the view.
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    
    [self.myLetterTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    segmentView = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"已读", @"未读"]];
    segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentView.frame = CGRectMake(0, 0, 320, 40);
    segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    return segmentView;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:letterCell forIndexPath:indexPath];
    UIImageView *headerImage = (UIImageView *)[cell viewWithTag:1];
    [headerImage setImage:[UIImage imageNamed:@"站内信.png"]];
    
    UILabel *title = (UILabel*)[cell viewWithTag:2];
    title.text = @"站内信内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容";
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"ReadLetter" sender:self];
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

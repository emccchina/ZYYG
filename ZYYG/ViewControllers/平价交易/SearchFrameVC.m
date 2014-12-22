//
//  SearchFrameVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SearchFrameVC.h"
#define kNearestSearch              kTem@"NearestSearch.txt"
@interface SearchFrameVC ()
<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *nearestSearch;
    UISearchBar     *searchBar;
    NSArray         *hotSearch;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *searchLab;
@property (weak, nonatomic) IBOutlet UIButton *firstBut;
@property (weak, nonatomic) IBOutlet UIButton *secondBut;
@property (weak, nonatomic) IBOutlet UIButton *thirdBut;
@property (weak, nonatomic) IBOutlet UIButton *fourthBut;
@property (weak, nonatomic) IBOutlet UITableView *resultTB;
@end

@implementation SearchFrameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    hotSearch = [[NSArray alloc] initWithContentsOfFile:[Utities filePathName:kHotSearchArr]];
    if (!hotSearch || !hotSearch.count) {
        hotSearch = @[@"暂无"];
    }
    for (NSString *hotKey in hotSearch) {
        UIButton *button = (UIButton*)[self.topView viewWithTag:([hotSearch indexOfObject:hotKey]+1)];
        button.hidden = NO;
        [button setTitle:hotKey forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"" target:nil action:nil];
    [self navBarAddTextField];
    [self setButFrame:self.firstBut];
    [self setButFrame:self.secondBut];
    [self setButFrame:self.thirdBut];
    [self setButFrame:self.fourthBut];
    [self createLine];
    self.resultTB.delegate = self;
    self.resultTB.dataSource = self;
    
    nearestSearch = [NSMutableArray arrayWithContentsOfFile:[Utities filePathName:kNearestSearch]];
    if (!nearestSearch) {
        nearestSearch = [[NSMutableArray alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [searchBar resignFirstResponder];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [nearestSearch writeToFile:[Utities filePathName:kNearestSearch] atomically:YES];
}

- (void)createLine
{
    UIView *lineB = [[UIView alloc] init];
    lineB.backgroundColor = [UIColor blackColor];
    lineB.alpha = 0.3;
    [self.topView addSubview:lineB];
    [lineB setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.topView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [lineB addConstraint:[NSLayoutConstraint constraintWithItem:lineB attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1/[UIScreen mainScreen].scale]];
}

- (void)setButFrame:(UIButton*)but
{
    but.layer.cornerRadius = 4;
    but.layer.borderColor = kBlackColor.CGColor;
    but.layer.borderWidth = 1;
}

- (void)navBarAddTextField
{
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchBar;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
    NSLog(@"begin");
    searchBar.showsCancelButton = YES;
   
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar1
{
    NSLog(@"end");
    searchBar.showsCancelButton = NO;
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1
{
    NSLog(@"click");
    [searchBar resignFirstResponder];
    [nearestSearch insertObject:searchBar.text atIndex:0];
    [self.navigationController.view.layer addAnimation:[Utities getAnimation:6] forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1
{
    [searchBar resignFirstResponder];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nearestSearch.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"最近搜索";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
    cell.textLabel.text = nearestSearch[indexPath.row];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

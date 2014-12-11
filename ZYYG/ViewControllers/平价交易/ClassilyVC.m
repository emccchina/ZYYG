//
//  ClassilyVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/24.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ClassilyVC.h"
#import "HMSegmentedControl.h"
#import "ClassifyCell.h"
#import "PriceCell.h"
#import "PopView.h"

@interface ClassilyVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    BOOL        _classfilyType; //0:艺术领域    1：价格区间
    NSArray     *_priceArray;   //价格 array
    HMSegmentedControl *segmentedControl1;// table view title
    PopView     *_popView;
    NSArray     *_detaitArr;
    NSArray     *_titles;
    NSInteger   _selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *classfilyTB;

@end

@implementation ClassilyVC

static NSString *classfilyCell  = @"ClassifyCell";
static NSString *priceCell      = @"PriceCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    
    _priceArray = @[@"500-1000", @"1000-2000", @"2000-3000", @"3000-5000", @"5000-9999", @"10000-19999", @"2万-3万", @"3万-5万", @"5万-10万", @"10万-30万", @"30万-100万", @"100万-500万", @"500万以上"];
    
    self.classfilyTB.delegate = self;
    self.classfilyTB.dataSource = self;
    self.classfilyTB.bounces = NO;
//    [self.classfilyTB registerNib:[UINib nibWithNibName:@"ClassifyCell" bundle:nil] forCellReuseIdentifier:classfilyCell];
    [self.classfilyTB registerNib:[UINib nibWithNibName:@"PriceCell" bundle:nil] forCellReuseIdentifier:priceCell];
    
    CGRect rect = self.classfilyTB.frame;
    
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    rect.origin.x += 100;
    rect.origin.y += 40;
    rect.size.width = kScreenWidth-100;
    rect.size.height = kScreenHeight - 40 - navHeight - 20;
    
    if (![self readTitlesFromFile]) {
        NSLog(@"request classify");
        [self requestClassify];
    }
    NSArray *array = _titles.count ? _titles[0][@"Childs"] : nil;
    __weak ClassilyVC *weakSelf = self;
    
    _popView = [[PopView alloc] initWithFrame:rect titles:array];
    [self.view addSubview:_popView];
    __weak PopView *weakPop = _popView;
    _popView.selectedFinsied = ^(NSInteger row){
        [weakSelf presentSearchResultVC:weakPop.titles[row]];
    };
    
    
}

- (BOOL)readTitlesFromFile
{
    _titles = [NSArray arrayWithContentsOfFile:[Utities filePathName:kClassifyArr]];
    if (_titles.count) {
        return YES;
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    _classfilyType = !_classfilyType;
    _popView.hidden = _classfilyType;
    [self.classfilyTB reloadData];
}

- (void)requestClassify
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@CategoryList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            _titles = result[@"Category"];
            [_titles writeToFile:[Utities filePathName:kClassifyArr] atomically:YES];
            [_popView setTitles:_titles[0][@"Childs"]];
            [self.classfilyTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
    
}

- (void)presentSearchResultVC:(NSDictionary*)search
{
    NSLog(@"search id %@", search);
    [self performSegueWithIdentifier:@"ClassifySearch" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _classfilyType ? (_priceArray.count + 1) / 2 : _titles.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _classfilyType ? 50 : 44;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (segmentedControl1) {
        return segmentedControl1;
    }
    segmentedControl1 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"艺术领域", @"价格区间"]];
    segmentedControl1.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl1.frame = CGRectMake(0, 40 + 100, 320, 40);
    segmentedControl1.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    segmentedControl1.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl1.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [segmentedControl1 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    return segmentedControl1;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_classfilyType) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classfilyCell forIndexPath:indexPath];
        cell.backgroundColor = (_selectedIndex == indexPath.row ? kBGGrayColor : [UIColor whiteColor]);
        cell.textLabel.text = [_titles[indexPath.row] safeObjectForKey:@"Name"];
        return cell;
    }else{
        PriceCell *cell = (PriceCell *)[tableView dequeueReusableCellWithIdentifier:priceCell forIndexPath:indexPath];
        NSString *leftTitle = _priceArray[indexPath.row*2];
        NSString *rightTitle = nil;
        if ((indexPath.row+1)*2 < _priceArray.count) {
            rightTitle = _priceArray[(indexPath.row +1)*2];
            cell.rightBut.hidden = NO;
        }
        cell.indexPath = indexPath;
        [cell.leftBut setTitle:leftTitle forState:UIControlStateNormal];
        [cell.rightBut setTitle:rightTitle forState:UIControlStateNormal];
        cell.buttonSeleced = ^(NSInteger bugTag, NSIndexPath* cellIndexPath){
            [self presentSearchResultVC:nil];
        };
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_classfilyType) {
        [_popView setTitles:_titles[indexPath.row][@"Childs"]];
        _selectedIndex  = indexPath.row;
        [self.classfilyTB reloadData];
    }else{
        [self presentSearchResultVC:nil];
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

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
#import "ClassifyModel.h"
#import "SearchReusltVC.h"
@interface ClassilyVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    BOOL        _classfilyType; //0:艺术领域    1：价格区间
    NSArray     *_priceArray;   //价格 array
    HMSegmentedControl *segmentedControl1;// table view title
    PopView     *_popView;
    NSArray     *_detaitArr;
    NSMutableArray     *_titles;//左边的TB
    NSMutableArray      *_details;//右边的TB
    NSInteger   _selectedIndex;
    SelectInfo *selectInfo;
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
    _selectedIndex = 0;
    _titles = [[NSMutableArray alloc] init];
    _details = [[NSMutableArray alloc] init];
    NSString *pathPrice = [[NSBundle mainBundle] pathForResource:@"Price" ofType:@"plist"];
    _priceArray = [[NSArray alloc] initWithContentsOfFile:pathPrice];
    
    self.classfilyTB.delegate = self;
    self.classfilyTB.dataSource = self;
    self.classfilyTB.backgroundColor = kBGGrayColor;
    self.classfilyTB.bounces = NO;
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
    NSArray *array = _details.count ? _details[0] : nil;
    __weak ClassilyVC *weakSelf = self;
    
    _popView = [[PopView alloc] initWithFrame:rect titles:array];
    [self.view addSubview:_popView];
    _popView.selectedFinsied = ^(NSInteger row){
        [weakSelf presentSearchResultVC:row];
    };
}

- (BOOL)readTitlesFromFile
{
    NSArray *arr = [NSArray arrayWithContentsOfFile:[Utities filePathName:kClassifyArr]];
    if (arr.count) {
//        NSLog(@"%@", arr);
        [self parseTitles:arr];
        return YES;
    }
    return NO;
}

- (ClassifyModel*)classifyWithDict:(NSDictionary*)dict
{
    ClassifyModel *model = [[ClassifyModel alloc] init];
    [model classifyModelFromDict:dict];
    return model;
}

- (void)parseTitles:(NSArray*)arr
{
    NSArray *array0 = [arr sortedArrayUsingFunction:soredArray context:NULL];
    NSMutableArray *arrayDetail = [NSMutableArray array];
    NSMutableArray *arrayTitle = [NSMutableArray array];
    for (NSDictionary *dict in array0) {
        NSMutableArray *array2 = [NSMutableArray array];
        ClassifyModel *model = [self classifyWithDict:dict];
        [array2 addObject:model];
        [arrayTitle addObject:model];
        NSArray *childs =  dict[@"Childs"];
        NSArray *childsSorted = [childs sortedArrayUsingFunction:soredArray context:NULL];
        for (NSDictionary *childDict in childsSorted) {
            ClassifyModel *modelChild = [self classifyWithDict:childDict];
            [array2 addObject:modelChild];
        }
        [arrayDetail addObject:array2];
    }
    [_titles removeAllObjects];
    [_titles addObjectsFromArray:arrayTitle];
    [_details removeAllObjects];
    [_details addObjectsFromArray:arrayDetail];
    NSLog(@"_titles %@", _titles);
}

NSInteger soredArray(id model1, id model2, void *context)
{
    NSInteger index1 = [[(NSDictionary*)model1 objectForKey:@"index"] integerValue];
    NSInteger index2 = [[(NSDictionary*)model2 objectForKey:@"index"] integerValue];
    if (index1 < index2) {
        return  NSOrderedAscending;
    }else{
        return NSOrderedDescending;
    }
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
            NSArray *arr = result[@"Category"];
            [arr writeToFile:[Utities filePathName:kClassifyArr] atomically:YES];
            [self parseTitles:arr];
            [self.classfilyTB reloadData];
            [_popView setTitles:_details[0]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
    
}

- (void)presentSearchResultVC:(NSInteger)searchRow
{
    selectInfo = [[SelectInfo alloc] init];
    if (_classfilyType) {
        NSArray *array = _priceArray[searchRow];
        selectInfo.price = array[1];
    }else{
        ClassifyModel *mode = _details[_selectedIndex][searchRow];
        selectInfo.categaryCode = mode.code;
    }
    [self performSegueWithIdentifier:@"ClassifySearch" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SearchReusltVC *deatVC = (SearchReusltVC*)[segue destinationViewController];
    if ([deatVC respondsToSelector:@selector(setSelectInfo:)]) {
        [deatVC setSelectInfo:selectInfo];
    }
    
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
    return _classfilyType ? 60 : 44;
    
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
        cell.backgroundColor = (_selectedIndex == indexPath.row ? [UIColor whiteColor] : kBGGrayColor);
        cell.textLabel.text = [(ClassifyModel*)(_titles[indexPath.row]) name];
        return cell;
    }else{
        PriceCell *cell = (PriceCell *)[tableView dequeueReusableCellWithIdentifier:priceCell forIndexPath:indexPath];
        NSArray *leftTitle = _priceArray[indexPath.row*2];
//        NSLog(@"row %d", indexPath.row*2);
        NSArray *rightTitle = nil;
        if ((indexPath.row*2+1) < _priceArray.count) {
            rightTitle = _priceArray[(indexPath.row*2+1)];
            cell.rightBut.hidden = NO;
        }
        cell.indexPath = indexPath;
        [cell.leftBut setTitle:leftTitle[2] forState:UIControlStateNormal];
        [cell.rightBut setTitle:rightTitle[2] forState:UIControlStateNormal];
        cell.buttonSeleced = ^(NSInteger butTag, NSIndexPath* cellIndexPath){
            [self presentSearchResultVC:cellIndexPath.row*2+butTag];
        };
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_classfilyType) {
        [_popView setTitles:_details[indexPath.row]];
        _selectedIndex  = indexPath.row;
        [self.classfilyTB reloadData];
    }else{
        [self presentSearchResultVC:0];
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

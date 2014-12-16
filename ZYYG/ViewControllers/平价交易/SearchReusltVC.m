//
//  SearchReusltVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SearchReusltVC.h"
#import "GoodsShowCell.h"
#import "HMSegmentedControl.h"
#import "ChooseView.h"
#import "SearchVC.h"
#import "GoodsModel.h"
#import "ArtDetailVC.h"
#import "SearchFrameVC.h"

@interface SearchReusltVC ()
<UITableViewDataSource, UITableViewDelegate, GoodsShowCellDelegate, UISearchBarDelegate>
{
    HMSegmentedControl *segmentedControl1;// table view title
    NSInteger           _selectedIndex;//选择的第几个
    SelectInfo          *_selectInfo;
    NSMutableArray      *results;
    NSString           *selectedProductID;
}
@property (weak, nonatomic) IBOutlet UITableView *resultTB;
@property (weak, nonatomic) IBOutlet ChooseView *chooseView;

@end

@implementation SearchReusltVC

static NSString *goodsCell = @"GoodsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    results = [[NSMutableArray alloc] init];
    self.navigationItem.rightBarButtonItem = [Utities barButtonItemWithSomething:@"筛选" target:self action:@selector(doRightButton:)];
    [self navBarAddTextField];
    self.resultTB.delegate = self;
    self.resultTB.dataSource = self;
    [self.resultTB registerNib:[UINib nibWithNibName:@"GoodsShowCell" bundle:nil] forCellReuseIdentifier:goodsCell];
    [self.chooseView setChooseFinised:^(id selected){
        if ([selected isKindOfClass:[NSNumber class]]) {
            [self presentSearchVC:selected];
        }else if ([selected isKindOfClass:[UIEvent class]]){
            [self doRightButton:nil];
        }
        
    }];
    
    [self requestForResult];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)doRightButton:(UIBarButtonItem*)item
{
    if (!self.chooseView.hidden) {
        return;
    }
    [self requestForSearchItem];
    
}

- (void)presentChooseView:(NSArray*)arr
{
    self.chooseView.hidden = !self.chooseView.hidden;
    NSString *titleItem = self.chooseView.hidden ? @"筛选" : @"确定";
    self.navigationItem.rightBarButtonItem.title = titleItem;
    [self.chooseView setTitles:arr];
    if (!self.chooseView.hidden) {
        self.chooseView.alpha = 0;
        [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.chooseView.alpha = 1;
        } completion:^(BOOL finished){
            
        }];
    }
}

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    
}

- (void)presentSearchVC:(id)selected
{
    _selectedIndex = [selected   integerValue];
    [self performSegueWithIdentifier:@"ChooseSegue" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[SearchVC class]]) {
        SearchVC *search = (SearchVC*)destVC;
        [search setValue:@(_selectedIndex) forKey:@"searchType"];
        [search setChooseFinished:^(NSInteger type, id content){
           
        }];
    }
    
    destVC.hidesBottomBarWhenPushed = YES;
    if ([(ArtDetailVC*)destVC respondsToSelector:@selector(setProductID:)]) {
        [destVC setValue:selectedProductID forKey:@"productID"];
    }
    if ([destVC isKindOfClass:[SearchFrameVC class]]) {
        SearchFrameVC *vc = (SearchFrameVC*)destVC;
        [vc setSearchType:1];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)navBarAddTextField
{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchBar;
}

- (void)parseRequestResults:(NSArray*)arr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        GoodsModel *model = [[GoodsModel alloc] init];
        [model goodsModelFromSearch:dict];
        [array addObject:model];
    }
    [results removeAllObjects];
    [results addObjectsFromArray:array];
}

- (void)requestForResult
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@TypeGoodsList.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = [_selectInfo createURLDict];
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [self parseRequestResults:result[@"Goods"]];
            [self.resultTB reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestForSearchItem
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@SearchItems.ashx",kServerDomain];
    NSLog(@"url %@", url);
    NSDictionary *dict = nil;
    if (_selectInfo.categaryCode) {
        dict = @{@"CategoryCode":(_selectInfo.categaryCode?:@"")};
    }
    [manager GET:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dismissIndicatorView];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
//            [self parseRequestResults:result[@"Goods"]];
//            [self.resultTB reloadData];
            [self presentChooseView:result[@"SearchItems"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self dismissIndicatorView];
        [self showAlertView:kNetworkNotConnect];
    }];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"searchFrameVC"];
    [self.navigationController pushViewController:vc animated:NO];
    return NO;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"begin");
    [searchBar setShowsCancelButton:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"end");
    [searchBar setShowsCancelButton:NO];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"click");
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (results.count + 1)/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetWidth(tableView.frame) * 3/ 4;
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
    segmentedControl1 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"价格", @"时间", @"待售",@"已售"]];
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
    GoodsShowCell *cell = (GoodsShowCell*)[tableView dequeueReusableCellWithIdentifier:goodsCell forIndexPath:indexPath];
    cell.delegate = self;
    GoodsModel *modelLeft = results[indexPath.row*2];
    cell.LTLab.text = modelLeft.GoodsName;
    cell.LMLab.text = modelLeft.ArtName;
    cell.LBLab.text = [NSString stringWithFormat:@"￥%.2f", modelLeft.AppendPrice];
    [cell.leftImage setImageWithURL:[NSURL URLWithString:modelLeft.picURL]];
    if (results.count > indexPath.row*2+1) {
        cell.showRight = YES;
        GoodsModel* modelRight = results[indexPath.row*2+1];
        cell.showRight = YES;
        cell.RTLab.text = modelRight.GoodsName;
        cell.RMLab.text = modelRight.ArtName;
        cell.RBLab.text = [NSString stringWithFormat:@"￥%.2f",modelRight.AppendPrice];//[goodsDetialRight safeObjectForKey:@"Product_Price"]
        [cell.rightImage setImageWithURL:[NSURL URLWithString:modelRight.picURL]];
    }else{
        cell.showRight = NO;
    }
    
    return cell;
}

#pragma mark - GoodsShowCellDelegate
- (void)imageViewPressed:(NSIndexPath *)indexPath position:(BOOL)position
{
    selectedProductID = [results[indexPath.row*2+position] GoodsCode];
    [self performSegueWithIdentifier:@"showArtDetail" sender:self];
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

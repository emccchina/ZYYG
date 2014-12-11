//
//  SearchVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SearchVC.h"
#import "HMSegmentedControl.h"

@interface SearchVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSInteger        _searchType; //0:价格区间   1:制作风格  2：尺寸
    NSArray         *_priceArray;   //价格 array
    NSArray         *_makeStyleArray;//制作风格
    NSArray         *_sizeArray;//尺寸
    NSArray         *_artistArr;//艺术家
//    NSMutableDictionary *_searchResultDict;//选择结果
    HMSegmentedControl *segmentedControl1;// table view title
    
}
@property (weak, nonatomic) IBOutlet UITableView *searchTB;
@end

@implementation SearchVC

#define kPrice                  @"price"
#define kStyle                  @"style"
#define kSize                   @"size"

static NSString *searchCell = @"SearchCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    _priceArray = @[@"500-1000", @"1000-2000", @"2000-3000", @"3000-5000", @"5000-9999", @"10000-19999", @"2万-3万", @"3万-5万", @"5万-10万", @"10万-30万", @"30万-100万", @"100万-500万", @"500万以上"];
    _makeStyleArray = @[@"水墨", @"工笔", @"其他"];
    _sizeArray = @[@"2平尺以下", @"2——4平尺", @"4——8平尺", @"8——12平尺", @"12平尺以上"];
//    _searchResultDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"-1",  kPrice, @"-1", kStyle, @"-1", kSize, nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    NSArray *arts = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dict in arts) {
        NSString *name = dict[@"state"];
        [arr addObject:name];
    }
    _artistArr = [arr sortedArrayUsingFunction:nickNameSort context:nil];
//    NSMutableArray *arr2 = [NSMutableArray array];
//    for (NSString *nickName in _artistArr) {
//        [arr2 addObject:[nickName substringToIndex:1]];
//    }
//    NSLog(@"first leter %@", arr2);
    self.searchTB.delegate = self;
    self.searchTB.dataSource = self;
    [self.searchTB registerClass:[UITableViewCell class] forCellReuseIdentifier:searchCell];
}

NSInteger nickNameSort(NSString *user1, NSString *user2, void *context) {
    return  [user1 localizedCompare:user2];
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
    _searchType = segmentedControl1.selectedSegmentIndex;
    [self.searchTB reloadData];
    
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (_searchType) {
        case 3:
            return _priceArray.count;
        case 2:
            return _makeStyleArray.count;
        case 1:
            return _sizeArray.count;
        case 0:
            return _artistArr.count;
        default:
            return 0;
            break;
    }

}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell forIndexPath:indexPath];
    cell.textLabel.textColor = kBlackColor;
    NSNumber *selectIndex = nil;
    switch (_searchType) {
        case 3:{
            cell.textLabel.text = _priceArray[indexPath.row];
        }
            break;
        case 2:{
            cell.textLabel.text = _makeStyleArray[indexPath.row];
            break;
        }
        case 1:{
            cell.textLabel.text = _sizeArray[indexPath.row];
        }
            break;
        case 0:{
            cell.textLabel.text = _artistArr[indexPath.row];
        }break;
        default:
            break;
    }
    
    if (selectIndex && [selectIndex integerValue] == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.chooseFinished) {
        self.chooseFinished(self.searchType, @(indexPath.row));
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchType == 0) {
        NSMutableArray* array = [NSMutableArray array];
        for (int i = 0; i < 26; i++) {
            [array addObject:[NSString stringWithFormat:@"%c", 'A'+i]];
        }
        return array;
    }
    return nil;
    
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

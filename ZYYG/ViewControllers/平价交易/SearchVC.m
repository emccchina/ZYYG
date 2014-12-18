//
//  SearchVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/27.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "SearchVC.h"
#import "HMSegmentedControl.h"
#import "SelectInfo.h"
//#import "pinyin.h"
@interface SearchVC ()
<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *tbArr;
    NSMutableArray *sliderTitles;
}
@property (weak, nonatomic) IBOutlet UITableView *searchTB;
@end

@implementation SearchVC


static NSString *searchCell = @"SearchCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showBackItem];
    if (!self.titles) {
        return;
    }
    self.title = self.titles[@"Title"];
    tbArr = [[NSMutableArray alloc] init];
    self.searchTB.delegate = self;
    self.searchTB.dataSource = self;
    [self.searchTB registerClass:[UITableViewCell class] forCellReuseIdentifier:searchCell];
    
    [self showIndicatorView:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [tbArr addObjectsFromArray:[self getTBArr]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissIndicatorView];
            [self.searchTB reloadData];
        });
    });

}
//汉字转拼音
- (NSString *) phonetic:(NSString*)sourceString {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    return source;
}

NSInteger soredArray1(id model1, id model2, void *context)
{
    return [model1 localizedStandardCompare:model2];
}

- (NSMutableArray*)getTBArr
{
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary* title = [NSMutableDictionary dictionary];
    if ([self.titles[@"Code"] isEqualToString:kAuthorCode]) {
        sliderTitles = [[NSMutableArray alloc] init];
        NSArray *contactArr = self.titles[@"TypeInfo"];
        for (NSDictionary *dict in contactArr) {
            NSString *firstLetter = [[self phonetic:dict[@"Name"]] substringToIndex:1];
            NSMutableArray *letterArray = title[firstLetter];
            if (letterArray) {
                [letterArray addObject:dict];
            }else{
                letterArray = [NSMutableArray arrayWithObject:dict];
            }
            [title setObject:letterArray forKey:firstLetter];
        }
        NSArray *keys = [title allKeys];
        NSArray *sortKeys = [keys sortedArrayUsingFunction:soredArray1 context:NULL];
        for (NSString *key in sortKeys) {
            NSString *upKey = [key uppercaseString];
            [sliderTitles addObject:upKey];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:upKey,@"title",title[key], @"row", nil];
            [array addObject:dict];
        }
    }else{
        [title setObject:@"title" forKey:@"title"];
        [title setObject:self.titles[@"TypeInfo"] forKey:@"row"];
        [array addObject:title];
    }
    return array;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tbArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tbArr[section][@"row"] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.titles[@"Code"] isEqualToString:kAuthorCode]) {
        return tbArr[section][@"title"];
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = tbArr[indexPath.section][@"row"][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell forIndexPath:indexPath];
    cell.textLabel.textColor = kBlackColor;
    cell.textLabel.text = dict[@"Name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.chooseFinished) {
        self.chooseFinished(self.titles[@"Code"], tbArr[indexPath.section][@"row"][indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sliderTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
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

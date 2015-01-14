//
//  ChooseView.m
//  ZYYG
//
//  Created by EMCC on 14/12/3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "ChooseView.h"

@implementation ChooseView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (aDecoder) {
        self.userInteractionEnabled = YES;
        CGRect TBRect = self.bounds;
        TBRect.origin.x += 80;
//        TBRect.origin.y += 20;
        TBRect.size.width = kScreenWidth - 80;
        TBRect.size.height = kScreenHeight - 44-20;
        self.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:0.5];
        self.chooseTB = [[UITableView alloc] initWithFrame:TBRect style:UITableViewStyleGrouped];
        self.chooseTB.delegate = self;
        self.chooseTB.dataSource = self;
        [self addSubview:self.chooseTB];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void)setTitles:(NSArray *)newTitles
{
    _titles = newTitles;
    [self.chooseTB reloadData];
}

- (void)setDetails:(NSArray *)details
{
    _details = details;
    [self.chooseTB reloadData];
}

- (void)reloadTitles:(NSArray *)titles details:(NSArray *)details
{
    CGRect TBRect = self.bounds;
    TBRect.size.width -= 80;
    TBRect.origin.x = 80;
    self.chooseTB.frame = TBRect;
    _titles = titles;
    _details = details;
    [self.chooseTB reloadData];
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.chooseFinised) {
        self.chooseFinised(event);
    }
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chooseCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"chooseCell"];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([self.titles[indexPath.row] isKindOfClass:[NSNull class]]) {
        return cell;
    }
    if (self.type) {
        cell.textLabel.text = self.titles[indexPath.row][@"Name"];
    }else{
        cell.textLabel.text = self.titles[indexPath.row][@"Title"];
        cell.detailTextLabel.text = [self.details[indexPath.row] isKindOfClass:[NSDictionary class]] ? self.details[indexPath.row][@"Name"] : @"";
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.chooseFinised) {
        self.chooseFinised(self.titles[indexPath.row]);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  PopView.m
//  ZYYG
//
//  Created by EMCC on 14/12/1.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "PopView.h"
#import "ClassifyModel.h"
@implementation PopView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)newTitles
{
    self = [self initWithFrame:frame];
    if (self) {
//        self.layer.cornerRadius = 3;
        _titles = newTitles;
        myTableView = [[UITableView alloc] initWithFrame:self.bounds];
        myTableView.layer.cornerRadius = 3;
        myTableView.delegate = self;
        myTableView.dataSource = self;
        myTableView.backgroundColor = [UIColor whiteColor];
        [self addSubview:myTableView];
    }
    return self;
}

- (void)setTitles:(NSArray *)newTitles
{
    _titles = newTitles;
    [myTableView reloadData];
}

- (void)setType:(NSInteger)newType
{
    _type = newType;
    [myTableView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _type ? _titles.count : _titles.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && _type == 0) {
        return 80;
    }
    return kPopCellHegith;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *popCell = @"popCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:popCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:popCell];
    }
    if (_type) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = _titles[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.textColor = kBlackColor;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else{
        if (indexPath.row == 0) {
            UIImageView  *imageV = (UIImageView*)[cell viewWithTag:1];
            if (!imageV) {
                imageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.bounds)-20, 60)];
                imageV.tag = 1;
                [cell addSubview:imageV];
    //            imageV.backgroundColor = [UIColor greenColor];
                [imageV setContentMode:UIViewContentModeScaleAspectFit];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            imageV.image = (self.titleImage ? : [UIImage  imageNamed:@"ChinesePrint"]);
            
//            [imageV setImageWithURL:[NSURL URLWithString:@"http://www.baidu.com/img/bd_logo1.png"]];
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.textColor = kBlackColor;
            cell.textLabel.text = (indexPath.row == 1 ? @"全部" : [(ClassifyModel*)(_titles[indexPath.row-1]) name]);
        
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0 && _type == 0) {
        return;
    }
    if (self.selectedFinsied) {
        self.selectedFinsied(_type ? indexPath.row : indexPath.row-1);
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

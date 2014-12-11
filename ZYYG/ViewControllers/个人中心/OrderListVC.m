//
//  OrderListVC.m
//  ZYYG
//
//  Created by champagne on 14-12-3.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "OrderListVC.h"
#import "OrderListCellTop.h"
#import "OrderListCellGoods.h"
#import "OrderListCellSum.h"
#import "OrderListCellBottom.h"
#import "HMSegmentedControl.h"

@interface OrderListVC ()

@property (retain, nonatomic) IBOutlet HMSegmentedControl *segmentView;
@end

@implementation OrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    self.orderListTabelView.delegate = self;
    self.orderListTabelView.dataSource = self;
    [self.orderListTabelView registerNib:[UINib nibWithNibName:@"OrderListCellTop" bundle:nil] forCellReuseIdentifier:@"OrderListCellTop"];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:@"OrderListCellGoods" bundle:nil] forCellReuseIdentifier:@"OrderListCellGoods"];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:@"OrderListCellSum" bundle:nil] forCellReuseIdentifier:@"OrderListCellSum"];
    [self.orderListTabelView registerNib:[UINib nibWithNibName:@"OrderListCellBottom" bundle:nil] forCellReuseIdentifier:@"OrderListCellBottom"];
    
    
    self.segmentView.font=[UIFont fontWithName:@"Helvetica" size:14.0];
    self.segmentView.sectionTitles = @[@"全部", @"未付款",@"待发货",@"待收货",@"已完成"];
    self.segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentView.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segmentView addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    NSLog(@"交易订单");
    
    // Do any additional setup after loading the view.
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
//    _classfilyType = !_classfilyType;
//    _popView.hidden = _classfilyType;
    [self.orderListTabelView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 8;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hight=30;
    if(indexPath.row ==0){
        hight=35;
    }else if(indexPath.row ==1){
        hight=100;
    }else if(indexPath.row ==2){
        hight=100;
    }else if(indexPath.row ==3){
        hight=25;
    }else if(indexPath.row ==4){
        hight=110;
    }
    return hight;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0){
        OrderListCellTop   *topCell=(OrderListCellTop*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCellTop" forIndexPath:indexPath];
        return topCell;
    }else if(indexPath.row ==1){
        OrderListCellGoods   *goodsCell=(OrderListCellGoods*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCellGoods" forIndexPath:indexPath];
        [goodsCell.goodsImage setImageWithURL:[NSURL URLWithString:@"http://www.baidu.com/img/bd_logo1.png"]];
        return goodsCell;
    }else if(indexPath.row ==2){
        OrderListCellGoods   *goodsCell=(OrderListCellGoods*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCellGoods" forIndexPath:indexPath];
        return goodsCell;
    }else if(indexPath.row ==3){
        OrderListCellSum *sumCell=(OrderListCellSum*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCellSum" forIndexPath:indexPath];
        return sumCell;
    }else if(indexPath.row ==4){
       OrderListCellBottom *bootomCell=(OrderListCellBottom*)[tableView dequeueReusableCellWithIdentifier:@"OrderListCellBottom" forIndexPath:indexPath];
        return bootomCell;
    }
    UITableViewCell *cell=[[UITableViewCell alloc] init];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
       [self performSegueWithIdentifier:@"OrderDetail" sender:self];
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

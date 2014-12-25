//
//  CompeteVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "CompeteVC.h"
#import "HMSegmentedControl.h"
#import "PayManager.h"


@interface CompeteVC()
<APayDelegate>
{
    HMSegmentedControl *segmentedControl1;
}

@property (weak, nonatomic) IBOutlet HMSegmentedControl *segment;

@end
@implementation CompeteVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segment.sectionTitles = @[@"艺术领域", @"价格区间"];
    self.segment.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segment.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segment.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segment.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [self.segment addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    [APay startPay:[PaaCreater createrWithOrderNo:@"0987654322" productName:@"艺术" money:@"1"] viewController:self delegate:self mode:kPayMode];
}

- (void)APayResult:(NSString*)result
{
    NSLog(@"%@",result);
    [self showAlertView:[Utities doWithPayList:result]];
}

@end

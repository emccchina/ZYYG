//
//  CompeteVC.m
//  ZYYG
//
//  Created by EMCC on 14/11/19.
//  Copyright (c) 2014年 EMCC. All rights reserved.
//

#import "CompeteVC.h"
#import "HMSegmentedControl.h"
@interface CompeteVC()
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
}

@end

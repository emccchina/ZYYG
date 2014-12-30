//
//  AdressTextField.m
//  ZYYG
//
//  Created by EMCC on 14/12/15.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "AdressTextField.h"

@implementation AdressTextField

- (void)dealloc
{
    [dataBase close];
}

- (void)awakeFromNib
{
    [self insertAddress:self];
    [self readAdressFromDB];
}

- (void)insertAddress:(UITextField*)field
{
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 30)];
    [topView setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doFinish)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace, doneButton, nil];
    
    [topView setItems:buttonsArray];
    [field setInputAccessoryView:topView];
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    field.inputView = picker;
}

- (void)doFinish
{
    [self resignFirstResponder];
//    [selectAreaArr replaceObjectAtIndex:0 withObject:(areaArr[[picker selectedRowInComponent:0]])];
//    [selectAreaArr replaceObjectAtIndex:1 withObject:(cityArr[[picker selectedRowInComponent:1]])];
//    [selectAreaArr replaceObjectAtIndex:2 withObject:(townArr[[picker selectedRowInComponent:2]])];
    self.provience = areaArr[[picker selectedRowInComponent:0]];
    self.city = cityArr[[picker selectedRowInComponent:1]];
    self.town = townArr[[picker selectedRowInComponent:2]];
    
    if (self.editFinished) {
        self.editFinished(self);
    }
    
//    [self restorePlaceArr];
}

- (void)readAdressFromDB
{
//    selectAreaArr = [[NSMutableArray alloc] init];
    NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"adress" ofType:@"db"];
    dataBase = [FMDatabase databaseWithPath:dbPath];
    if (![dataBase open]) {
        NSLog(@"数据库读取失败");
        return;
    }
    NSMutableArray *provices = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", kProvinceAdress];
    FMResultSet *provicesResult = [dataBase executeQuery:sql];
    while ([provicesResult next]) {
        NSInteger proviceID = [provicesResult intForColumn:@"province_id"];
        NSString  *proviceName = [provicesResult stringForColumn:@"province_name"];
        [provices addObject:@[@(proviceID), proviceName]];
    }
    areaArr = [[NSArray alloc] initWithArray:provices];
    [self restorePlaceArr];
    
}

- (void)restorePlaceArr
{
//    [selectAreaArr addObject:areaArr[0]];
    self.provience = areaArr[0];
    cityArr = [self arrayFromDB:kCityAdress upName:kProvinceAdress key:[(NSNumber*)(areaArr[0][0]) intValue]];
//    [selectAreaArr addObject:cityArr[0]];
    self.city = cityArr[0];
    townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[(NSNumber*)(cityArr[0][0]) integerValue]];
//    [selectAreaArr addObject:townArr[0]];
    self.town = townArr[0];
//    [picker reloadAllComponents];
    
}

- (NSArray*)arrayFromDB:(NSString*)tableName upName:(NSString*)upName key:(NSInteger)key
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@_id=%ld", tableName, upName, (long)key];
    FMResultSet *s = [dataBase executeQuery:sql];
    while ([s next]) {
        //retrieve values for each record
        NSInteger areaID = [s intForColumn:[NSString stringWithFormat:@"%@_id", tableName]];
        NSString  *areaName = [s stringForColumn:[NSString stringWithFormat:@"%@_name", tableName]];
        NSInteger UPID = [s intForColumn:[NSString stringWithFormat:@"%@_id", upName]];
        NSArray *arr = @[@(areaID), areaName, @(UPID)];
        [array addObject:arr];
    }
    if (!array.count) {
        return @[@[@"0",@"",@"0"]];
    }
    return array;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return areaArr.count;
        case 1:
            return cityArr.count;
        case 2:
            return townArr.count;
        default:
            return 0;
    }
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return areaArr[row][1];
        case 1:
            return cityArr[row][1];
        case 2:
            return townArr[row][1];
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    NSLog(@"select %d, %d", row, component);
    switch (component) {
        case 0:{
            NSNumber *provinceID = areaArr[row][0];
            cityArr = [self arrayFromDB:kCityAdress upName:kProvinceAdress key:[provinceID integerValue]];
            NSLog(@"%@", cityArr[0][0]);
            townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[(NSNumber*)(cityArr[0][0]) intValue]];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        }
            break;
        case 1:{
            NSNumber *cityID = cityArr[row][0];
            townArr = [self arrayFromDB:kTownAdress upName:kCityAdress key:[cityID integerValue]];
            [pickerView reloadComponent:2];
        }
            break;
        case 2:{
            
        }
            break;
        default:
            break;
    }
    
}


@end

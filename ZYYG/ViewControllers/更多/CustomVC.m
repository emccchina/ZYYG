//
//  CustomVC.m
//  ZYYG
//
//  Created by EMCC on 14/12/5.
//  Copyright (c) 2014年 wu. All rights reserved.
//

#import "CustomVC.h"
#import "SpecialDiscuss.h"
#import "ImageScrollCell.h"
#import "LetterModel.h"
// 私人定制 单一请求
@interface CustomVC ()
{
    NSMutableArray *images;
    NSMutableArray *manages;
    NSString        *selectedProductID;//选择的id
}

@end

@implementation CustomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    images = [[NSMutableArray alloc] init];
    manages  = [[NSMutableArray alloc] init];
    [self showBackItem];
    [self requestCustom];
    
    [self.customTableVIew registerNib:[UINib nibWithNibName:@"SpecialDiscuss" bundle:nil] forCellReuseIdentifier:@"SpecialDiscuss"];
    [self.customTableVIew registerNib:[UINib nibWithNibName:@"ImageScrollCell" bundle:nil] forCellReuseIdentifier:@"imageCell"];
    
    self.customTableVIew.delegate=self;
    self.customTableVIew.dataSource=self;
    self.title = @"私人定制";
    NSLog(@"私人定制");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//请求
- (void)requestCustom
{
    [self showIndicatorView:kNetworkConnecting];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@PrivateCustom.ashx",kServerDomain];
    NSLog(@"url %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinished];
        NSLog(@"request is %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id result = [self parseResults:responseObject];
        if (result) {
            [self parseBannerInfo:result[@"HeadList"]];
            [self parseManageInfo:result[@"FootList"]];
            [self.customTableVIew reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFinished];
        [self showAlertView:kNetworkNotConnect];
    }];
}

- (void)requestFinished
{
    [self dismissIndicatorView];
    [self.customTableVIew headerEndRefreshingWithResult:JHRefreshResultSuccess];
}
//顶部图片点击
- (void)scrollviewImageClick:(NSInteger)index
{
    NSDictionary *dict = images[index];
    BOOL  isLocal = [dict[@"IsLocal"] boolValue];
    if (isLocal) {
        NSString *URL = dict[@"Href"];
        NSArray *stringArr = [URL componentsSeparatedByString:@"="];
        NSString *productID = [stringArr lastObject];
        if (productID) {
            selectedProductID = productID;
            [self performSegueWithIdentifier:@"showArtDetail" sender:self];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"Href"]]];
    }

}

//解析顶部广告
- (void)parseBannerInfo:(NSMutableArray *)bannerArr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in bannerArr) {
        NSDictionary *newDict=[NSDictionary dictionaryWithObjectsAndKeys:dict[@"ImageUrl"],@"Url",dict[@"Url"],@"Href" ,nil];
        [array addObject:newDict];
    }
    [images removeAllObjects];
    [images addObjectsFromArray:array];
}
//解析经理人数据
- (void)parseManageInfo:(NSMutableArray *)manageArr
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in manageArr) {
        LetterModel *model = [[LetterModel alloc] init];
        [model initFromManager:dict];
        [array addObject:model];
    }
    [manages removeAllObjects];
    [manages addObjectsFromArray:array];
}

#pragma mark -tableView

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section ==0)
        return 1;
    return 20;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==3) {
        return manages.count;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       return CGRectGetWidth(tableView.frame) * 256 / 640;
    }else if (indexPath.section==1) {
        return 360;
    }else if (indexPath.section==2) {
        return 260;
    }
    return 80;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section ==1){
        return @"定制方法一:";
    }else if (section ==2) {
        return @"定制方法二:";
    }else if (section ==3) {
        return @"销售经理人列表:";
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        ImageScrollCell *scrollCell = (ImageScrollCell*)[tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
        scrollCell.style = 0;
        scrollCell.images = images;
        scrollCell.click = ^(NSInteger index){
            [self scrollviewImageClick:index];
        };
        [scrollCell reloadScrollViewData];
        return scrollCell;
    }else if (indexPath.section==1) {
        SpecialDiscuss *sCell = (SpecialDiscuss *)[tableView dequeueReusableCellWithIdentifier:@"SpecialDiscuss" forIndexPath:indexPath];
        [sCell.L1Image setImage:[UIImage imageNamed:@"custom1"]];
        [sCell.L2Image setImage:[UIImage imageNamed:@"custom2"]];
        [sCell.L3Image setImage:[UIImage imageNamed:@"custom3"]];
        [sCell.L4Image setImage:[UIImage imageNamed:@"custom4"]];
        
        sCell.tit1.text=@"定制需求";
        sCell.lab1.numberOfLines=0;
        sCell.lab1.text=@"通过销售经理指定平台的签约艺术家,提出作品需求并支付创作定金.";
        sCell.tit2.text=@"需求确认";
        sCell.lab2.numberOfLines=0;
        sCell.lab2.text=@"销售经理人与艺术家确认创作意向,确定创作风格,材质规格等创作细节.";
        sCell.tit3.text=@"定制化创作";
        sCell.lab3.numberOfLines=0;
        sCell.lab3.text=@"根据客户需求,艺术家着手定制化创作.";
        sCell.tit4.text=@"交付用户";
        sCell.lab4.numberOfLines=0;
        sCell.lab4.text=@"经理人与客户验收并支付尾款.";
        
        [sCell.M1Image setImage:[UIImage imageNamed:@"customnext"]];
        [sCell.M2Image setImage:[UIImage imageNamed:@"customnext"]];
        [sCell.M3Image setImage:[UIImage imageNamed:@"customnext"]];
        
        
        return sCell;
    }else if (indexPath.section==2) {
        SpecialDiscuss *sCell = (SpecialDiscuss *)[tableView dequeueReusableCellWithIdentifier:@"SpecialDiscuss" forIndexPath:indexPath];
        [sCell.L1Image setImage:[UIImage imageNamed:@"custom5"]];
        [sCell.L2Image setImage:[UIImage imageNamed:@"custom6"]];
        [sCell.L3Image setImage:[UIImage imageNamed:@"custom3"]];
        sCell.L4Image.hidden=YES;
//        [sCell.L4Image setImage:[UIImage imageNamed:@"custom4"]];
        
        sCell.tit1.text=@"定制需求";
        sCell.lab1.numberOfLines=0;
        sCell.lab1.text=@"与销售经理人沟通,对易购500平台未提供的艺术品提出所购期望.";
        sCell.tit2.text=@"需求确认";
        sCell.lab2.numberOfLines=0;
        sCell.lab2.text=@"销售经理人与艺术家确认创作意向,确定创作风格,材质规格等创作细节.";
        sCell.tit3.text=@"定制化创作";
        sCell.lab3.numberOfLines=0;
        sCell.lab3.text=@"根据客户需求,艺术家着手定制化创作.";
        
        sCell.tit4.hidden=YES;
        sCell.lab4.hidden=YES;
//        sCell.tit4.text=@"交付用户";
//        sCell.lab4.numberOfLines=0;
//        sCell.lab4.text=@"经理人与客户验收并支付尾款.";
        
        [sCell.M1Image setImage:[UIImage imageNamed:@"customnext"]];
        [sCell.M2Image setImage:[UIImage imageNamed:@"customnext"]];
        sCell.M3Image.hidden=YES;
//        [sCell.M3Image setImage:[UIImage imageNamed:@"customnext"]];
        
        return sCell;
    }else{
        LetterModel *mana=manages[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConsultantCell" forIndexPath:indexPath];
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
        [imageView setImageWithURL:[NSURL URLWithString:mana.LetterCode] placeholderImage:[UIImage imageNamed:@"defualtImage"]];
        UILabel *label1= (UILabel*)[cell viewWithTag:2];
        label1.text = mana.Title;
        UILabel* label2 = (UILabel*)[cell viewWithTag:3];
        label2.text = mana.SendName;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        LetterModel *mana=manages[indexPath.row];
        NSString *tel = mana.SendName;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", tel]]];
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

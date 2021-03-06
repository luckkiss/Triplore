//
//  TPMeRecentTableViewController.m
//  Triplore
//
//  Created by 宋 奎熹 on 2017/6/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TPMeRecentTableViewController.h"

#import "TPVideo.h"
#import "TPVideoManager.h"
#import "TPVideoModel.h"
#import "TPVideoSingleTableViewCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "MJRefreshAutoGifFooter.h"
#import "SVProgressHUD.h"

static NSString *singleCellIdentifier = @"TPVideoSingleTableViewCell";
static NSString *seriesCellIdentifier = @"TPVideoSeriesTableViewCell";

@interface TPMeRecentTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) NSMutableArray* videos;

@end

@implementation TPMeRecentTableViewController

- (void)continueLoading{
    self.videos = [[NSMutableArray alloc] init];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *clearBarItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearRecent)];
    self.navigationItem.rightBarButtonItem = clearBarItem;
    self.navigationItem.title = @"观看记录";
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadRecentVideos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRecentVideos{
    NSLog(@"Load Recent");
    __weak __typeof__(self) weakSelf = self;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    [[TPVideoManager fetchRecentVideos] enumerateObjectsUsingBlock:^(TPVideo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tempArr addObject:[[TPVideoModel alloc] initWithTPVideo:obj]];
    }];
    NSLog(@"%lu", (unsigned long)tempArr.count);
    [weakSelf.videos removeAllObjects];
    [weakSelf.videos addObjectsFromArray:tempArr];
    [weakSelf.tableView reloadData];
}

- (void)clearRecent{
    if ([TPVideoManager clearRecentRecord]) {
        [SVProgressHUD showSuccessWithStatus:@"清空成功"];
    } else {
        [SVProgressHUD showErrorWithStatus:@"清空失败"];
    }
    [SVProgressHUD dismissWithDelay:2.0 completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TPVideoModel *video = self.videos[indexPath.section];
    TPVideoSingleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:singleCellIdentifier forIndexPath:indexPath];
    cell.cellDelegate = self;
    [cell setVideo:video];
    [cell setFavorite:[TPVideoManager isFavoriteVideo:((TPVideoModel *)self.videos[indexPath.section]).videoid]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = CGRectGetWidth(self.view.frame);
    return (width / 2 - 10) / 16 * 9 + 20;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        TPVideoModel *video = self.videos[indexPath.row];
        [TPVideoManager deleteRecentVideo:video.videoid];
        [self loadRecentVideos];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"               ";
}

#pragma mark - DZNEmptyTableViewDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"暂无观看记录";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:TPColor,
                                 NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end

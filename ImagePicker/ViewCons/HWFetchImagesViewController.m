//
//  HWFetchImagesViewController.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWFetchImagesViewController.h"
#import "HWImagesManager.h"
#import "HWImagesCollectionViewController.h"
#import "HWFetchImagesModel.h"
#import "HWImageModel.h"

@interface HWFetchListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation HWFetchListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, self.bounds.size.width - 100, 80)];
        [self.contentView addSubview:_coverImage];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

- (void)configCellWithModel:(HWFetchImagesModel *)model {
    HWImageModel *imageM = model.imageModels[0];
    _coverImage.image = imageM.thumbImage;
    _nameLabel.text = [NSString stringWithFormat:@"%@(%ld)", model.name, (long)model.imageModels.count];
}

@end

@interface HWFetchImagesViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) HWImagesCollectionViewController *imagesViewCon;
@property (nonatomic, assign) BOOL firstTime;

@end

@implementation HWFetchImagesViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _firstTime = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"相册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnClicked:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    if (_firstTime) {
        _firstTime = NO;
        self.dataArray = HWImagesManager.sharedManager.fetchDataArray;
        [self.navigationController pushViewController:[[HWImagesCollectionViewController alloc] initWithModel:self.dataArray[0]] animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doneBtnClicked:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtnClicked:(UIBarButtonItem *)sender {
    [HWImagesManager clearAllModels];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWFetchListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fetchCell"];
    if (cell == nil) {
        cell = [[HWFetchListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fetchCell"];
    }
    [cell configCellWithModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [HWImagesManager clearAllModels];
    [self.navigationController pushViewController:[[HWImagesCollectionViewController alloc] initWithModel:self.dataArray[indexPath.row]] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

@end

//
//  HWImagesCollectionViewController.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWImagesCollectionViewController.h"
#import "HWPreviewViewController.h"
#import "HWFetchImagesModel.h"
#import "HWImagesManager.h"
#import "HWImageModel.h"

@interface HWImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *contentImage;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) HWImageModel *model;

@end

@implementation HWImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentImage = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 5, frame.size.width - 5, frame.size.height - 5)];
        _contentImage.contentMode = UIViewContentModeScaleAspectFill;
        _contentImage.clipsToBounds = YES;
        [self.contentView addSubview:_contentImage];
        
        _selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 30, 5, 30, 30)];
        [_selectedBtn setImage:[UIImage imageNamed:@"chooseImage_normal"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:@"chooseImage_selected"] forState:UIControlStateSelected];
        [_selectedBtn addTarget:self action:@selector(chooseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectedBtn];
        
        [HWImagesManager.sharedManager addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [HWImagesManager.sharedManager removeObserver:self forKeyPath:@"dataSource"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"dataSource"]) {
        _selectedBtn.selected = [HWImagesManager containModel:self.model];
    }
}

- (void)configCellWithModel:(HWImageModel *)model {
    self.model = model;
    [HWImagesManager.sharedManager getThumbImageOfAsset:model.asset result:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _contentImage.image = image;
        });
    }];
    _selectedBtn.selected = [HWImagesManager containModel:self.model];
}

- (void)chooseBtnClicked {
    _selectedBtn.selected = !_selectedBtn.selected;
    _selectedBtn.selected ? [HWImagesManager addImageModel:self.model] : [HWImagesManager removeImageModel:self.model];
}

@end

@interface HWImagesCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) HWFetchImagesModel *fetchModel;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HWImagesCollectionViewController

- (instancetype)initWithModel:(HWFetchImagesModel *)model {
    self = [super init];
    if (self) {
        _fetchModel = model;
        [HWImagesManager.sharedManager addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelBtnClicked:)];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.doneBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.bottomView = nil;
}

- (void)dealloc {
    [HWImagesManager.sharedManager removeObserver:self forKeyPath:@"dataSource"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event response
- (void)doneBtnClicked:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtnClicked:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"dataSource"]) {
        HWImagesManager.sharedManager.dataSource.count > 0 ? [self.doneBtn setTitle:[NSString stringWithFormat:@"完成(%ld)", (long)HWImagesManager.sharedManager.dataSource.count] forState:UIControlStateNormal] : [self.doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchModel.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configCellWithModel:self.fetchModel.imageModels[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HWPreviewViewController *previewCon = [[HWPreviewViewController alloc] initWithDatas:self.fetchModel.imageModels];
    previewCon.index = indexPath.row;
    [self.navigationController pushViewController:previewCon animated:YES];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Getter 
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width / 4, self.view.bounds.size.width / 4);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 46) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[HWImageCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 46, self.view.bounds.size.width, 46)];
        _bottomView.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomView;
}

- (UIButton *)doneBtn {
    if (_doneBtn == nil) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, 8, 80, 30)];
        _doneBtn.layer.cornerRadius = 5;
        _doneBtn.clipsToBounds = YES;
        _doneBtn.backgroundColor = [UIColor colorWithRed:0.1 green:0.7 blue:0.1 alpha:1];
        HWImagesManager.sharedManager.dataSource.count > 0 ? [_doneBtn setTitle:[NSString stringWithFormat:@"完成(%ld)", (long)HWImagesManager.sharedManager.dataSource.count] forState:UIControlStateNormal] : [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

@end

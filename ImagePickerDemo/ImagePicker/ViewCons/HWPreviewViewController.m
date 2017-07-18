//
//  HWPreviewViewController.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWPreviewViewController.h"
#import "HWImagesManager.h"
#import "HWImageModel.h"

@interface HWPreviewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation HWPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.activityView];
    }
    return self;
}

- (void)configCellWithModel:(HWImageModel *)model {
    [self.activityView startAnimating];
    self.imageView.image = nil;
    self.imageView.image = model.thumbImage;
    [HWImagesManager.sharedManager getStandImageOfAsset:model.asset succeed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            image ? (self.imageView.image = image) : (self.imageView.image = model.thumbImage);
            self.imageView.image = image;
        });
    }];
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.center = self.contentView.center;
    }
    return _activityView;
}



@end

@interface HWPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *chooseBtn;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HWPreviewViewController

- (instancetype)initWithDatas:(NSArray *)datas {
    self = [super init];
    if (self) {
        _dataSource = datas;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    
    _chooseBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_chooseBtn setImage:[UIImage imageNamed:@"chooseImage_normal"] forState:UIControlStateNormal];
    [_chooseBtn setImage:[UIImage imageNamed:@"chooseImage_selected"] forState:UIControlStateSelected];
    [_chooseBtn addTarget:self action:@selector(chooseBtnClciked:) forControlEvents:UIControlEventTouchUpInside];
    _chooseBtn.selected = [HWImagesManager containModel:self.dataSource[_index]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_chooseBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event response

- (void)tapToChangeNavi:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:0.2f animations:^{
        self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.hidden;
    }];
}

- (void)chooseBtnClciked:(UIButton *)sender {
    sender.selected = !sender.selected;
    int index = self.collectionView.contentOffset.x / self.view.bounds.size.width;
    HWImageModel *model = self.dataSource[index];
    sender.selected ? [HWImagesManager addImageModel:model] : [HWImagesManager removeImageModel:model];
}

#pragma mark - UICollectionViewDelegate 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configCellWithModel:_dataSource[indexPath.row]];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = scrollView.contentOffset.x / self.view.bounds.size.width;
    HWImageModel *model = self.dataSource[index];
    self.chooseBtn.selected = [HWImagesManager containModel:model];
}

#pragma mark - Getter and Setter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = self.view.bounds.size;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView setContentInset:UIEdgeInsetsMake(- 64, 0, 0, 0)];
        [_collectionView registerClass:[HWPreviewCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView setContentOffset:CGPointMake(self.view.bounds.size.width * _index, 0)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToChangeNavi:)];
        [_collectionView addGestureRecognizer:tap];
    }
    return _collectionView;
}

@end


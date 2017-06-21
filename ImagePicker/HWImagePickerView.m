//
//  HWImagePickerView.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/16.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWImagePickerView.h"
#import "HWImagesManager.h"
#import "HWImageModel.h"
#import "HWFetchImagesViewController.h"

@interface HWImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) HWImageModel *model;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HWImagePickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 20, 0, 20, 20)];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"chooseImage_delete"] forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.width - 20)];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_deleteBtn];
    }
    return self;
}

- (void)deleteBtnClicked:(UIButton *)sender {
    [HWImagesManager removeImageModel:self.model];
}

- (void)configCellByModel:(HWImageModel *)model {
    self.model = model;
    _deleteBtn.hidden = NO;
    _imageView.image = model.thumbImage;
}

- (void)addImageCell {
    _deleteBtn.hidden = YES;
    _imageView.image = [UIImage imageNamed:@"chooseImage_add"];
}

@end

@interface HWImagePickerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

@implementation HWImagePickerView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        
        CGFloat const itemWidth = (frame.size.width > frame.size.height ? frame.size.height : frame.size.width) - 10;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [_collectionView registerClass:[HWImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"pickerCell"];
        [HWImagesManager.sharedManager addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionNew context:nil];
        
        [self addSubview:line];
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)dealloc {
    [HWImagesManager.sharedManager removeObserver:self forKeyPath:@"dataSource"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"dataSource"]) {
        [_collectionView reloadData];
    }
}
            
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"pickerCell" forIndexPath:indexPath];
    indexPath.row == HWImagesManager.sharedManager.dataSource.count ? [cell addImageCell] : [cell configCellByModel:HWImagesManager.sharedManager.dataSource[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == HWImagesManager.sharedManager.dataSource.count) {
        UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:[HWFetchImagesViewController new]];
        if (self.naviBlock) {
            self.naviBlock(naviCon);
        }else {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:naviCon animated:YES completion:nil];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return HWImagesManager.sharedManager.dataSource.count + 1;
}

- (NSArray *)selectedArray {
    return HWImagesManager.sharedManager.dataSource;
}

@end

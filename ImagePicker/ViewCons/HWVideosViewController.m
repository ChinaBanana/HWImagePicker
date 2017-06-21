//
//  HWVideosViewController.m
//  newqinwa
//
//  Created by Coco Wu on 2017/6/20.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "HWVideosViewController.h"
#import "HWImagesManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface HWVideosCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectedBtn;

@end

@implementation HWVideosCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 5, frame.size.width - 5, frame.size.height - 5)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _selectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 30, 5, 30, 30)];
        [_selectedBtn setImage:[UIImage imageNamed:@"chooseImage_normal"] forState:UIControlStateNormal];
        [_selectedBtn setImage:[UIImage imageNamed:@"chooseImage_selected"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:_selectedBtn];
    }
    return self;
}

- (void)configCellByAsset:(AVURLAsset *)asset {
    _imageView.image = [self getPreviewOfVideo:asset.URL];
}

- (UIImage *)getPreviewOfVideo:(NSURL *)videoUrl {
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    
    NSError *error;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:&error];
    if (error) {
        NSLog(@"%@", error.description);
        return nil;
    }
    UIImage *previeImage = [[UIImage alloc] initWithCGImage:imageRef];
    return previeImage;
}

@end

@interface HWVideosViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIButton *_currentBtn;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AVPlayerViewController *playViewController;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, copy) void (^ selectedBlock)(AVURLAsset *asset);

@end

@implementation HWVideosViewController

- (instancetype)initWithBlock:(void (^)(AVURLAsset *asset))selected
{
    self = [super init];
    if (self) {
        self.selectedBlock = selected;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChoose:)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelChoose:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedBtnClicked:(UIButton *)sender {
    self.selectedBlock((AVURLAsset *)HWImagesManager.sharedManager.videosArray[sender.tag]);
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return HWImagesManager.sharedManager.videosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HWVideosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videosCell" forIndexPath:indexPath];
    [cell configCellByAsset:HWImagesManager.sharedManager.videosArray[indexPath.row]];
    cell.selectedBtn.tag = indexPath.row;
    [cell.selectedBtn addTarget:self action:@selector(selectedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AVURLAsset *asset = (AVURLAsset *)HWImagesManager.sharedManager.videosArray[indexPath.row];
    self.player = [[AVPlayer alloc] initWithURL:asset.URL];
    [self.playViewController setPlayer:self.player];
    [self presentViewController:self.playViewController animated:YES completion:^{
        [self.player play];
    }];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width / 4, self.view.bounds.size.width / 4);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 46) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[HWVideosCollectionViewCell class] forCellWithReuseIdentifier:@"videosCell"];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (AVPlayerViewController *)playViewController {
    if (_playViewController == nil) {
        _playViewController = [[AVPlayerViewController alloc] init];
    }
    return _playViewController;
}

@end


//
//  HWImagesManager.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWImagesManager.h"
#import "HWImageModel.h"
#import "HWFetchImagesModel.h"
#import <Photos/Photos.h>

@interface HWImagesManager ()<PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHPhotoLibrary *phlibiary;
@property (nonatomic, strong) PHImageManager *phImangeMnager;
@property (nonatomic, strong) PHCachingImageManager *catchingManager;

@end

@implementation HWImagesManager

static HWImagesManager *_imageManager = nil;
+ (HWImagesManager *)sharedManager {
    if (_imageManager == nil) {
        _imageManager = [[HWImagesManager alloc] init];
    }
    return _imageManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _phlibiary = [PHPhotoLibrary sharedPhotoLibrary];
        [_phlibiary registerChangeObserver:self];
        _phImangeMnager = [PHImageManager defaultManager];
        _catchingManager = [PHCachingImageManager new];
        _fetchDataArray = [NSMutableArray new];
        _videosArray = [NSMutableArray new];
        _catchEnabled = NO;
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusDenied:
                
                break;
            case PHAuthorizationStatusNotDetermined:{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                }];
            }
                break;
            case PHAuthorizationStatusAuthorized:{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [self initilzeDatas];
                });
            }
                break;
            case PHAuthorizationStatusRestricted:
                
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)dealloc {
    [_phlibiary unregisterChangeObserver:self];
    [_catchingManager stopCachingImagesForAllAssets];
}

#pragma mark - Public methods
+ (BOOL)containModel:(HWImageModel *)model {
    return [HWImagesManager.sharedManager.dataSource containsObject:model];
}

+ (void)addImageModel:(HWImageModel *)model {
    [HWImagesManager.sharedManager.dataSource containsObject:model] ? : [[HWImagesManager.sharedManager mutableArrayValueForKey:@"dataSource"] addObject:model];
}

+ (void)removeImageModel:(HWImageModel *)model {
    (![HWImagesManager.sharedManager.dataSource containsObject:model]) ? : [[HWImagesManager.sharedManager mutableArrayValueForKey:@"dataSource"] removeObject:model];
}

+ (void)clearAllModels {
    [[HWImagesManager.sharedManager mutableArrayValueForKey:@"dataSource"] removeAllObjects];
}

/// 获取不同规格的图片
- (void)getThumbImageOfAsset:(PHAsset *)asset result:(void (^)(UIImage *image))handler{
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [_phImangeMnager requestImageForAsset:asset targetSize:CGSizeMake(80, 80) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        handler(result);
    }];
}

- (void)getStandImageOfAsset:(PHAsset *)asset succeed:(void (^)(UIImage *image))handler {
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
    option.networkAccessAllowed = YES;
    
    [_phImangeMnager requestImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSData *imageData = UIImageJPEGRepresentation(result, 0.1);
        if (!imageData) {
            imageData = UIImagePNGRepresentation(result);
        }
        handler([UIImage imageWithData:imageData]);
    }];
}

- (void)getOrginalImageOfAsset:(PHAsset *)asset succeed:(void (^)(UIImage *image))handler {
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        NSLog(@"%f, %@", progress, error);
    };
    
    [_phImangeMnager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        handler(result);
    }];
}

#pragma mark - Pravite methods
- (void)initilzeDatas {
    [_videosArray removeAllObjects];
    [_fetchDataArray removeAllObjects];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
    
        if (result.count > 0){
            HWFetchImagesModel *fetchModel = [HWFetchImagesModel new];
            fetchModel.fetchRusult = result;
            fetchModel.name = obj.localizedTitle;
            __block NSMutableArray *imageArr = [NSMutableArray array];
            [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [imageArr addObject:[[HWImageModel alloc] initWithAsset:obj]];
            }];
            fetchModel.imageModels = imageArr;
            [_fetchDataArray addObject:fetchModel];
        }
    }];
    
    PHFetchResult *videosFetch = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
    if (videosFetch.count == 0) return;
    [videosFetch enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHVideoRequestOptions *videoOption = [PHVideoRequestOptions new];
        [_phImangeMnager requestAVAssetForVideo:obj options:videoOption resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (asset) [_videosArray addObject:asset];
        }];
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver delegate

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self initilzeDatas];
}

#pragma mark - Getter and Setter

- (void)setCatchEnabled:(BOOL)catchEnabled {
    _catchEnabled = catchEnabled;
    if(catchEnabled){
        [self initilzeDatas];
    } else {
        [_catchingManager stopCachingImagesForAllAssets];
    }
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end

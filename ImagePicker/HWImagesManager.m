
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
@property (nonatomic, strong) PHCachingImageManager *cachingManager;

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
        _cachingManager = [PHCachingImageManager new];
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusDenied:
                
                break;
            case PHAuthorizationStatusNotDetermined:{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            [self initilzeDatas];
                        });
                    }
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

#pragma mark - Pravite methods
- (void)initilzeDatas {
    
    _fetchDataArray = [NSMutableArray new];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:nil];
        
        if (result.count > 0){
            HWFetchImagesModel *fetchModel = [HWFetchImagesModel new];
            fetchModel.name = obj.localizedTitle;
            NSMutableArray *imageArr = [NSMutableArray array];
            
            [result enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                /// 图片会占用很多内存？
                PHImageRequestOptions *option = [PHImageRequestOptions new];
                option.synchronous = NO;
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                
                [_phImangeMnager requestImageForAsset:obj targetSize:CGSizeMake(50, 50) contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    [imageArr addObject:[[HWImageModel alloc] initWithInfo:info image:result asset:obj]];
                }];
            }];
            fetchModel.imageModels = imageArr;
            [_fetchDataArray addObject:fetchModel];
        }
    }];
}

- (void)getOrginalImageOfAsset:(PHAsset *)asset succeed:(void (^)(UIImage *image))handler {
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = NO;
    option.networkAccessAllowed = YES;
    
//    option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
//        NSLog(@"%f, %@", progress, error);
//    };
    
    [_cachingManager startCachingImagesForAssets:@[asset] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option];
    
    [_phImangeMnager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [_cachingManager stopCachingImagesForAllAssets];
        handler(result);
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver delegate

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
}

#pragma mark - Getter
- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end

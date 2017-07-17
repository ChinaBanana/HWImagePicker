//
//  HWImagesManager.h
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class HWImageModel;
@interface HWImagesManager : NSObject

@property (nonatomic, class, readonly) HWImagesManager *sharedManager;
@property (nonatomic, strong) NSMutableArray *fetchDataArray;
@property (nonatomic, strong) NSMutableArray *videosArray;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL catchEnabled; // 是否开启缓存，当开启缓存时，缓存原照片，这里不建议开启，会占用非常多的内存；

- (void)getOrginalImageOfAsset:(PHAsset *)asset succeed:(void (^)(UIImage *image))handler;

+ (BOOL)containModel:(HWImageModel *)model;
+ (void)addImageModel:(HWImageModel *)model;
+ (void)removeImageModel:(HWImageModel *)model;
+ (void)clearAllModels;

@end

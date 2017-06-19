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

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *fetchDataArray;

- (void)getOrginalImageOfAsset:(PHAsset *)asset succeed:(void (^)(UIImage *image))handler;

+ (BOOL)containModel:(HWImageModel *)model;
+ (void)addImageModel:(HWImageModel *)model;
+ (void)removeImageModel:(HWImageModel *)model;
+ (void)clearAllModels;

@end

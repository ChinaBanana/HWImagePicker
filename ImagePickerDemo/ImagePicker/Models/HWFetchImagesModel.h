//
//  HWFetchImagesModel.h
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAssetCollection, PHFetchResult;
@interface HWFetchImagesModel : NSObject

//@property (nonatomic, strong) PHAssetCollection *collection;
@property (nonatomic, strong) PHFetchResult *fetchRusult;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *imageModels;

@end

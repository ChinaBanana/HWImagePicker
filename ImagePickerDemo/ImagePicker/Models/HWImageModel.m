//
//  HWImageModel.m
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "HWImageModel.h"
#import "HWImagesManager.h"

@implementation HWImageModel

- (instancetype)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
    }
    return self;
}

@end

//
//  HWImageModel.h
//  TestProject
//
//  Created by Coco Wu on 2017/6/13.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@interface HWImageModel : NSObject

@property (nonatomic, readonly, strong) NSDictionary *infos;
@property (nonatomic, readonly, strong) UIImage *thumbImage; // 缩略图
@property (nonatomic, readonly, strong) PHAsset *asset;

@property (nonatomic, strong) UIImage *standerdImage; // 压缩标准图
@property (nonatomic, strong) UIImage *orginalImage; // 原图

- (instancetype)initWithInfo:(NSDictionary *)info image:(UIImage *)image asset:(PHAsset *)asset;;

@end

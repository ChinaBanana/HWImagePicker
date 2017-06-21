//
//  HWVideosViewController.h
//  newqinwa
//
//  Created by Coco Wu on 2017/6/20.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVURLAsset;
@interface HWVideosViewController : UIViewController

- (instancetype)initWithBlock:(void (^)(AVURLAsset *asset))selected;

@end

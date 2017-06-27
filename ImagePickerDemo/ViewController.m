//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by Coco Wu on 2017/6/19.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "ViewController.h"
#import "HWImagePicker.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *addVideoBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 只需要引入HWImagePicker.h 初始化，添加到当前视图就OK了，是不是超简单
    HWImagePickerView *pickerView = [[HWImagePickerView alloc] initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, 80)];
    [self.view addSubview:pickerView];
    
    // 选择完的图片都在这里
    // NSArray *array = pickerView.selectedArray;
}

/// 选择视频
- (IBAction)addVideoBtnClicked:(id)sender {
    HWVideosViewController *videoCon = [[HWVideosViewController alloc] initWithBlock:^(AVURLAsset *asset) {
        
        // 选择视频完成后的操作
        AVPlayerViewController *playCon = [[AVPlayerViewController alloc] init];
        [playCon setPlayer:[AVPlayer playerWithURL:asset.URL]];
        
        // 视频数据
        // NSData *data = [NSData dataWithContentsOfURL:asset.URL];
    }];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:videoCon] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

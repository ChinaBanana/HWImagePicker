//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by Coco Wu on 2017/6/19.
//  Copyright © 2017年 cyt. All rights reserved.
//

#import "ViewController.h"
#import "HWImagePicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 只需要引入HWImagePicker.h 初始化，添加到当前视图就OK了，是不是超简单
    HWImagePickerView *pickerView = [[HWImagePickerView alloc] initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, 80)];
    __weak UIViewController *weakSelf = self;
    pickerView.naviBlock = ^(UINavigationController *naviCon) {
        [weakSelf presentViewController:naviCon animated:YES completion:nil];
    };
    [self.view addSubview:pickerView];
    
    // 选择完的图片都在这里
    NSArray *array = pickerView.selectedArray;
    NSLog(@"%@", array);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

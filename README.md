# HWImagePicker
仿微信图片选择器

#### USE 
将ImagePicker文件夹加入到你的工程中，在需要使用的文件中 
```
#import "HWImagePicker.h"
```
初始化，加入到父视图中即可，自定义frame
```
HWImagePickerView *pickerView = [[HWImagePickerView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 80)];
[self.view addSubview:pickerView];
```
选择完成后的图片存在数组中， 数组中存储HWImageModel，包含ThumbImage，standardImage，originalImage 三种尺寸的Image，根据需要从model中获取即可。
```
NSArray *array = pickerView.selectedArray;
```

#### Issue
如果当前视图已经是模态出的ViewController，则需要实现pickerView的naviBlock
```
__weak UIViewController *weakSelf = self;
pickerView.naviBlock = ^(UINavigationController *naviCon) {
    [weakSelf presentViewController:naviCon animated:YES completion:nil];
};
```

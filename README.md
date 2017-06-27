# HWImagePicker
仿微信图片选择器

![ImagePicker.gif](http://upload-images.jianshu.io/upload_images/2992566-775770de1fbb71d6.gif?imageMogr2/auto-orient/strip)

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
#### 选择视频
```
HWVideosViewController *videoCon = [[HWVideosViewController alloc] initWithBlock:^(AVURLAsset *asset) { 
    // 选择视频完成后的操作   
    // 视频数据
    // NSData *data = [NSData dataWithContentsOfURL:asset.URL];
}];
```

**还不是很完善，如有问题，欢迎指出**

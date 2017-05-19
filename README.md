DJBannerView 
==============

A ViewPager that can scroll automatically. <br/>

## Screenshots

![image](/gif/demo.gif)

## Requirements

- iOS 7.0 or later
- Xcode 7.3 or later

## Installation

1. 在 `Podfile` 中添加 `pod 'DJBannerView'`。
```ruby
pod 'DJBannerView'
```
2. 执行 `pod install` 或 `pod update`。
```bash
$ pod install
```
3. 导入 `<DJBannerView/DJBannerView.h>`。
``` objective-c
#import <DJBannerView/DJBannerView.h>
#import <DJBannerView/DJPageBannerView.h>
#import <DJBannerView/DJManualBannerView.h>
```

## Licenses

All source code is licensed under the [MIT License](https://github.com/iunion/DJBannerView/blob/master/LICENSE).


## Architecture

### BannerView

- `DJBannerView`
- `DJPageBannerView`
- `DJManualBannerView`

### BannerViewScrollDirection

- `BannerViewScrollDirectionLandscape  /** 水平滚动 **/`
- `BannerViewScrollDirectionPortait    /** 垂直滚动 **/`

### BannerViewPageStyle

- `BannerViewPageStyle_None`        /** 不显示 **/
- `BannerViewPageStyle_Left`        /** 居左 **/
- `BannerViewPageStyle_Middle`      /** 居中 **/
- `BannerViewPageStyle_Right`       /** 居右 **/

## Usage

### DJBannerView
``` objective-c
self.bannerView = [[DJBannerView alloc] initWithFrame:CGRectMake(0, 50.0f, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH*140/320) scrollDirection:BannerViewScrollDirectionPortait images:dataArray];

[self.bannerView setRollingDelayTime:4.0f];
[self.bannerView setDelegate:self];
[self.bannerView setPageControlStyle:BannerViewPageStyle_Right];
[self.view addSubview:self.bannerView];

[self.bannerView startRolling];
```

### DJPageBannerView
``` objective-c
DJPageBannerView *pageBannerView = [[DJPageBannerView alloc] initWithFrame:CGRectMake(0, bannerView.frame.origin.y+bannerView.frame.size.height+20.0f, UI_SCREEN_WIDTH, (UI_SCREEN_WIDTH-80.0f)*140/320) scrollDirection:BannerViewScrollDirectionLandscape images:dataArray pageWidth:UI_SCREEN_WIDTH-80.0f padding:10.0f];
[pageBannerView setDelegate:self];
[pageBannerView setPageControlStyle:BannerViewPageStyle_Middle];
pageBannerView.showClose = NO;
[pageBannerView setCorner:8.0f];
[self.view addSubview:pageBannerView];
```

### DJManualBannerView
``` objective-c
self.manualBannerView = [[DJManualBannerView alloc] initWithFrame:CGRectMake(0.0f, pageBannerView.frame.origin.y+pageBannerView.frame.size.height+20.0f, UI_SCREEN_WIDTH, Image_Height) scrollDirection:BannerViewScrollDirectionLandscape images:nil padding:20.0f pageWidth:Image_Width dataSource:self];
self.manualBannerView.hasLeftPadding = YES;
[self.manualBannerView setPageControlStyle:BannerViewPageStyle_None];
[self.manualBannerView reloadBannerWithData:nil];
[self.manualBannerView setCorner:6.0f];
[self.view addSubview:self.manualBannerView];
```

## Author
- [Dennis Deng](https://github.com/iunion)


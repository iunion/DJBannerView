//
//  ViewController.m
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/2.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "ViewController.h"
#import "DJBannerView.h"
#import "DJPageBannerView.h"
#import "DJManualBannerView.h"
#import "UIImageView+WebCache.h"

#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

#define Image_Width         160.0f
#define Image_Height        60.0f

@interface ViewController ()
<
    DJBannerViewDelegate,
    DJBannerViewDataSource
>

@property (nonatomic, strong) DJBannerView *bannerView;

@property (nonatomic, strong) DJManualBannerView *manualBannerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    NSString *imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0211/68/2/4170109a41ca935610bf8_b.png";
    [dataArray addObject:imageUrl];
    imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0127/19/9/4170109a267ca641c41ebb_b.png";
    [dataArray addObject:imageUrl];
    imageUrl = @"http://pic02.babytreeimg.com/foto3/photos/2014/0207/59/4/4170109a17eca86465f8a4_b.jpg";
    [dataArray addObject:imageUrl];
    
    self.bannerView = [[DJBannerView alloc] initWithFrame:CGRectMake(0, 50.0f, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH*140/320) scrollDirection:BannerViewScrollDirectionPortait images:dataArray];
    
    [self.bannerView setRollingDelayTime:4.0f];
    [self.bannerView setDelegate:self];
    //[self.bannerView setCorner:8];
    [self.bannerView setPageControlStyle:BannerViewPageStyle_Right];
    //[self.m_BannerView showClose:YES];
    [self.bannerView startRolling];
    
    [self.view addSubview:self.bannerView];
    
    NSMutableArray *dataArray1 = [NSMutableArray arrayWithCapacity:0];
    imageUrl = @"http://pic05.babytreeimg.com/foto3/photos/2014/0124/88/2/4170109a13aca59db86761_b.png";
    [dataArray1 addObject:imageUrl];
    imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0124/18/3/4170109a253ca5b0d88192_b.png";
    [dataArray1 addObject:imageUrl];
    
    DJBannerView *bannerView = [[DJBannerView alloc] initWithFrame:CGRectMake(0.0f, self.bannerView.frame.size.height+60.0f, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH*70/320) scrollDirection:BannerViewScrollDirectionLandscape images:dataArray1];
    
    [bannerView setRollingDelayTime:2.0f];
    [bannerView setDelegate:self];
    [bannerView setPageControlStyle:BannerViewPageStyle_Middle];
    [bannerView showClose:YES];
    [bannerView startRolling];
    [self.view addSubview:bannerView];
    
    DJPageBannerView *pageBannerView = [[DJPageBannerView alloc] initWithFrame:CGRectMake(0, bannerView.frame.origin.y+bannerView.frame.size.height+20.0f, UI_SCREEN_WIDTH, (UI_SCREEN_WIDTH-80.0f)*140/320) scrollDirection:BannerViewScrollDirectionLandscape images:dataArray pageWidth:UI_SCREEN_WIDTH-80.0f padding:10.0f];
    [pageBannerView setDelegate:self];
    [pageBannerView setPageControlStyle:BannerViewPageStyle_Middle];
    [pageBannerView showClose:NO];
    [pageBannerView setCorner:8.0f];
    [self.view addSubview:pageBannerView];
    
    self.manualBannerView = [[DJManualBannerView alloc] initWithFrame:CGRectMake(0.0f, pageBannerView.frame.origin.y+pageBannerView.frame.size.height+20.0f, UI_SCREEN_WIDTH, Image_Height) scrollDirection:BannerViewScrollDirectionLandscape images:nil padding:20.0f pageWidth:Image_Width dataSource:self];
    //[self.m_ManualScrollView setCorner:6];
    self.manualBannerView.isLeftPadding = YES;
    [self.manualBannerView setPageControlStyle:BannerViewPageStyle_None];
    [self.manualBannerView reloadBannerWithData:nil];
    [self.manualBannerView setCorner:6.0f];
    [self.view addSubview:self.manualBannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 重新启动自动滚动
    // 有些情况自动滚动会停止以此来重启
    [self.bannerView refreshRolling];
}


#pragma mark -
#pragma mark MQBannerViewDataSource

- (NSUInteger)bannerViewCountOfPages:(UIView *)bannerView
{
    return 4;
}

- (UIView *)bannerView:(UIView *)bannerView pageAtIndex:(NSUInteger)index
{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    NSString *imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0211/68/2/4170109a41ca935610bf8_b.png";
    [dataArray addObject:imageUrl];
    imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0127/19/9/4170109a267ca641c41ebb_b.png";
    [dataArray addObject:imageUrl];
    imageUrl = @"http://pic02.babytreeimg.com/foto3/photos/2014/0207/59/4/4170109a17eca86465f8a4_b.jpg";
    [dataArray addObject:imageUrl];
    imageUrl = @"http://pic01.babytreeimg.com/foto3/photos/2014/0124/18/3/4170109a253ca5b0d88192_b.png";
    [dataArray addObject:imageUrl];

    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Image_Width, Image_Height)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:dataArray[index]] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    return imageView;
}


@end

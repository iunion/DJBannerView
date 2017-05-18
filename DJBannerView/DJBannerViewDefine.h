//
//  DJBannerViewDefine.h
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/2.
//  Copyright © 2016年 DJ. All rights reserved.
//

#ifndef DJBannerViewDefine_h
#define DJBannerViewDefine_h


#define Banner_StartTag         1000
#define Banner_CStartTag        2000

#define Banner_PageHeight       15.0f
#define Banner_PageWidth        60.0f
#define Banner_PageBottomGap    3.0f

// scrollView滚动的方向
typedef NS_ENUM(NSInteger, BannerViewScrollDirection)
{
    // 水平滚动
    BannerViewScrollDirectionLandscape,
    // 垂直滚动
    BannerViewScrollDirectionPortait
};

// PageControl位置
typedef NS_ENUM(NSInteger, BannerViewPageStyle)
{
    BannerViewPageStyle_None,
    BannerViewPageStyle_Left,
    BannerViewPageStyle_Middle,
    BannerViewPageStyle_Right
};

@protocol DJBannerViewDelegate <NSObject>

@optional
//- (void)imageCachedDidFinish:(UIView *)bannerView;

// banner滚动完成
- (void)bannerView:(nonnull UIView *)bannerView didScrollToIndex:(NSUInteger)index;

// banner点击事件
- (void)bannerView:(nonnull UIView *)bannerView didSelectIndex:(NSUInteger)index;

// banner关闭
- (void)bannerViewDidClosed:(nonnull UIView *)bannerView;

@end


@protocol DJBannerViewDataSource <NSObject>

// page数量
- (NSUInteger)bannerViewCountOfPages:(nonnull UIView *)bannerView;
// 自定义pageView
- (nonnull UIView *)bannerView:(nonnull UIView *)bannerView pageAtIndex:(NSUInteger)index;

@end

#endif /* DJBannerViewDefine_h */

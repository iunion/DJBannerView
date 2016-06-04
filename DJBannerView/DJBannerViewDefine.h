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

typedef NS_ENUM(NSInteger, BannerViewScrollDirection)
{
    // 水平滚动
    BannerViewScrollDirectionLandscape,
    // 垂直滚动
    BannerViewScrollDirectionPortait
};

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

- (void)bannerView:(nonnull UIView *)bannerView didScrollToIndex:(NSUInteger)index;

- (void)bannerView:(nonnull UIView *)bannerView didSelectIndex:(NSUInteger)index;

- (void)bannerViewDidClosed:(nonnull UIView *)bannerView;

@end


@protocol DJBannerViewDataSource <NSObject>

- (NSUInteger)bannerViewCountOfPages:(nonnull UIView *)bannerView;
- (nonnull UIView *)bannerView:(nonnull UIView *)bannerView pageAtIndex:(NSUInteger)index;

@end

#endif /* DJBannerViewDefine_h */

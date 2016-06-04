//
//  DJPageBannerView.h
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/2.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJBannerViewDefine.h"


@interface DJPageBannerView : UIView

@property (nullable, nonatomic, weak) id <DJBannerViewDelegate> delegate;

// scrollView滚动的方向
@property (nonatomic, assign) BannerViewScrollDirection scrollDirection;

@property (nonatomic, assign) NSTimeInterval rollingDelayTime;

@property (nullable, nonatomic, strong) UIImage *placeholderImage;

// page宽
@property (nonatomic, assign) CGFloat pageWidth;
// page之间间隔
@property (nonatomic, assign) CGFloat pagePadding;


- (nonnull instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(nullable NSArray *)images pageWidth:(CGFloat)pageWidth padding:(CGFloat)padding;

- (void)reloadBannerWithData:(nonnull NSArray *)images;

- (void)setCorner:(NSInteger)cornerRadius;

- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle;

// 解决切换View滚动停止问题
- (void)refreshRolling;

- (void)startRolling;
- (void)stopRolling;

- (void)showClose:(BOOL)show;

@end


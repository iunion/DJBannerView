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

@property (nonatomic, weak) id <DJBannerViewDelegate> delegate;

// scrollView滚动的方向
@property (nonatomic, assign) BannerViewScrollDirection scrollDirection;

@property (nonatomic, assign) NSTimeInterval rollingDelayTime;

@property (nonatomic, strong) UIImage *placeholderImage;

// page之间间隔
@property (nonatomic, assign) CGFloat pagePadding;


- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images padding:(CGFloat)padding;

- (void)reloadBannerWithData:(NSArray *)images;

- (void)setCorner:(NSInteger)cornerRadius;

- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle;

// 解决切换View滚动停止问题
- (void)refreshRolling;

- (void)startRolling;
- (void)stopRolling;

- (void)showClose:(BOOL)show;

@end


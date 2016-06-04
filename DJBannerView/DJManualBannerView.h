//
//  DJManualBannerView.h
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/3.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJBannerViewDefine.h"


@interface DJManualBannerView : UIView

@property (nonatomic, weak) id <DJBannerViewDelegate> delegate;
@property (nonatomic, weak) id <DJBannerViewDataSource> dataSource;

// scrollView滚动的方向
@property (nonatomic, assign) BannerViewScrollDirection scrollDirection;

@property (nonatomic, strong) UIImage *placeholderImage;

// page宽
@property (nonatomic, assign) CGFloat pageWidth;
// page之间间隔
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) BOOL isLeftPadding;


- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images padding:(CGFloat)padding pageWidth:(CGFloat)pageWidth dataSource:(id <DJBannerViewDataSource>)adataSource;

- (void)reloadBannerWithData:(NSArray *)images;

- (void)setCorner:(NSInteger)cornerRadius;

- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle;

- (void)showClose:(BOOL)show;

@end

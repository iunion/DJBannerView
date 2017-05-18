//
//  DJPageBannerView.m
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/2.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "DJPageBannerView.h"
#import "UIImageView+WebCache.h"


// 只能奇数 5
#define Banner_CacheCount       5


@interface DJPageBannerView ()
<
    UIScrollViewDelegate
>
{
    BOOL isRolling;
    
    NSInteger totalPage;
    NSInteger startPageIndex;
}

// 只能奇数 5
@property (nonatomic, assign) NSUInteger cacheSize;

@property (nonatomic, weak) UIView *bgView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIButton *closeButton;

// 存放所有需要滚动的图片URL NSString
@property (nonatomic, strong) NSArray *imageArray;

@property (nonatomic, assign) NSInteger currentPage;


- (void)refreshScrollView;

- (NSInteger)getPageIndex:(NSInteger)index;
- (NSArray *)getDisplayImagesWithPageIndex:(NSInteger)pageIndex;

@end


@implementation DJPageBannerView

- (void)dealloc
{
    _delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images pageWidth:(CGFloat)pageWidth padding:(CGFloat)padding
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.clipsToBounds = NO;
        
        _cacheSize = Banner_CacheCount;
        
        _placeholderImage = nil;
        
        _imageArray = [[NSArray alloc] initWithArray:images];
        
        _scrollDirection = direction;
        
        // 第一张图片在图片数组的位置
        startPageIndex = _cacheSize/2;
        // 滚动从第一张开始
        _currentPage = startPageIndex;
        
        totalPage = _imageArray.count;
        
        _pagePadding = padding;
        _pageWidth = pageWidth;

        CGRect bgFrame;
        // 在水平方向滚动
        if (_scrollDirection == BannerViewScrollDirectionLandscape)
        {
            bgFrame = CGRectMake((self.bounds.size.width-_pageWidth)*0.5, 0, _pageWidth, self.bounds.size.height);
        }
        // 在垂直方向滚动
        else if (_scrollDirection == BannerViewScrollDirectionPortait)
        {
            bgFrame = CGRectMake(0, (self.bounds.size.height-_pageWidth)*0.5, self.bounds.size.width, _pageWidth);
        }
        UIView *view = [[UIView alloc] initWithFrame:bgFrame];
        view.backgroundColor = [UIColor clearColor];
        view.clipsToBounds = NO;
        _bgView = view;
        [self addSubview:_bgView];

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [_bgView addGestureRecognizer:singleTap];
        _bgView.exclusiveTouch = YES;
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:_bgView.bounds];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.clipsToBounds = NO;

        _scrollView = scrollView;
        [_bgView addSubview:_scrollView];

        // 在水平方向滚动
        if (_scrollDirection == BannerViewScrollDirectionLandscape)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * _cacheSize,
                                                scrollView.frame.size.height);
        }
        // 在垂直方向滚动
        else if (_scrollDirection == BannerViewScrollDirectionPortait)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                                scrollView.frame.size.height * _cacheSize);
        }

        for (NSInteger i = 0; i < _cacheSize; i++)
        {
            UIView *view = [[UIView alloc] initWithFrame:scrollView.bounds];
            view.backgroundColor = [UIColor clearColor];
            
            CGRect imageFrame = CGRectMake(_pagePadding, 0, view.frame.size.width-2*_pagePadding, view.frame.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.userInteractionEnabled = YES;
            imageView.tag = Banner_StartTag+i;
            [view addSubview:imageView];

            // 水平滚动
            if (_scrollDirection == BannerViewScrollDirectionLandscape)
            {
                view.frame = CGRectOffset(view.frame, scrollView.frame.size.width * i, 0);
            }
            // 垂直滚动
            else if (_scrollDirection == BannerViewScrollDirectionPortait)
            {
                view.frame = CGRectOffset(view.frame, 0, scrollView.frame.size.height * i);
            }
            
            [scrollView addSubview:view];
        }

        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(5, frame.size.height-(Banner_PageHeight+Banner_PageBottomGap), Banner_PageWidth, Banner_PageHeight)];
        pageControl.numberOfPages = _imageArray.count;
        _pageControl = pageControl;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];

        pageControl.currentPage = 0;
        
        [self refreshScrollView];
    }
    
    return self;
}

- (void)reloadBannerWithData:(NSArray *)images
{
    if (isRolling)
    {
        [self stopRolling];
    }
    
    self.imageArray = [[NSArray alloc] initWithArray:images];
    self.currentPage = startPageIndex;
    
    totalPage = self.imageArray.count;

    self.pageControl.numberOfPages = totalPage;
    self.pageControl.currentPage = 0;
    
    [self refreshScrollView];
}


#pragma mark -
#pragma mark set

- (void)setRollingDelayTime:(NSTimeInterval)rollingDelayTime
{
    if (rollingDelayTime <= 0)
    {
        [self stopRolling];
        
        return;
    }

    if (rollingDelayTime < 1)
    {
        rollingDelayTime = 1;
    }
    
    _rollingDelayTime = rollingDelayTime;
}

- (void)setCorner:(NSInteger)cornerRadius
{
    for (NSInteger i = 0; i < Banner_CacheCount; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        if (imageView)
        {
            imageView.layer.cornerRadius = cornerRadius;
            if (cornerRadius == 0)
            {
                imageView.layer.masksToBounds = NO;
            }
            else
            {
                imageView.layer.masksToBounds = YES;
            }
        }
    }
}

- (void)setPageControlStyle:(BannerViewPageStyle)pageStyle
{
    CGRect frame = self.pageControl.frame;

    switch (pageStyle)
    {
        case BannerViewPageStyle_None:
        {
            self.pageControl.hidden = YES;
            return;
        }
        case BannerViewPageStyle_Left:
        {
            frame.origin.x = 5;
            break;
        }
        case BannerViewPageStyle_Right:
        {
            frame.origin.x = self.frame.size.width-Banner_PageWidth-5;
            break;
        }
        case BannerViewPageStyle_Middle:
        {
            frame.origin.x = (self.frame.size.width-Banner_PageWidth)*0.5;
            break;
        }
        default:
            break;
    }
    
    self.pageControl.frame = frame;
    self.pageControl.hidden = NO;
}

- (void)setPagePadding:(CGFloat)padding
{
    if (padding < 0)
    {
        return;
    }
    
    _pagePadding = padding;
    for (NSInteger i = 0; i < self.cacheSize; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        if (imageView)
        {
            CGRect frame = CGRectMake(_pagePadding, 0, self.scrollView.bounds.size.width-2*_pagePadding, self.scrollView.bounds.size.height);

            imageView.frame = frame;
        }
    }
}

- (void)setShowClose:(BOOL)show
{
    if (show)
    {
        if (!self.closeButton)
        {
            UIButton *bannerCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [bannerCloseButton setFrame:CGRectMake(self.frame.size.width-40, 0, 40, 40)];
            [bannerCloseButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [bannerCloseButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            [bannerCloseButton addTarget:self action:@selector(closeBanner) forControlEvents:UIControlEventTouchUpInside];
            [bannerCloseButton setImage:[UIImage imageNamed:@"banner_close"] forState:UIControlStateNormal];
            bannerCloseButton.exclusiveTouch = YES;
            self.closeButton = bannerCloseButton;
            [self addSubview:bannerCloseButton];
        }
        
        self.closeButton.hidden = NO;
    }
    else
    {
        if (self.closeButton)
        {
            self.closeButton.hidden = YES;
        }
    }
}


#pragma mark -
#pragma mark action

- (void)closeBanner
{
    [self stopRolling];

    if ([self.delegate respondsToSelector:@selector(bannerViewDidClosed:)])
    {
        [self.delegate bannerViewDidClosed:self];
    }
}


#pragma mark - Custom Method

- (void)refreshScrollView
{
    NSArray *curimageClass = [self getDisplayImagesWithPageIndex:self.currentPage];
    
    for (NSInteger i = 0; i < self.cacheSize; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        NSString *url = curimageClass[i];
        if (imageView && [imageView isKindOfClass:[UIImageView class]])
        {
            if (url.length)
            {
                [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:self.placeholderImage options:SDWebImageRetryFailed|SDWebImageLowPriority];
            }
            else if (self.placeholderImage)
            {
                imageView.image = self.placeholderImage;
            }
        }
    }
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width*startPageIndex, 0);
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height*startPageIndex);
    }
    
    self.pageControl.currentPage = self.currentPage-startPageIndex;
    
    if ([self.delegate respondsToSelector:@selector(bannerView:didScrollToIndex:)])
    {
        [self.delegate bannerView:self didScrollToIndex:self.currentPage-startPageIndex];
    }
}

- (NSArray *)getDisplayImagesWithPageIndex:(NSInteger)page
{
    if (self.imageArray.count == 0)
    {
        return  nil;
    }
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
    // 取cacheSize大小范围的数据，这里就是为什么是奇数
    for (NSUInteger i=page-startPageIndex; i<=page+startPageIndex; i++)
    {
        NSInteger index = [self getPageIndex:i]-startPageIndex;
        [images addObject:self.imageArray[index]];
    }
    
    return images;
}

// 从视觉index转换为存储index
- (NSInteger)getPageIndex:(NSInteger)index
{
    if (totalPage == 1)
    {
        return startPageIndex;
    }
    
    NSInteger pageIndex = startPageIndex + ((totalPage+index-startPageIndex) % totalPage);
    return pageIndex;
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSInteger x = aScrollView.contentOffset.x;
    NSInteger y = aScrollView.contentOffset.y;
    //NSLog(@"did  x=%d  y=%d", x, y);
    
    if (isRolling)
    {
        // 用于手动拖动时取消已加入的滚动延迟线程
        //NSLog(@"scrollViewDidScroll cancelPreviousPerformRequestsWithTarget");
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
    }
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        // 往下翻一张
        if (x >= (startPageIndex+1) * self.scrollView.frame.size.width)
        {
            self.currentPage = [self getPageIndex:self.currentPage+1];
            [self refreshScrollView];
        }
        
        if (x <= (startPageIndex-1) * self.scrollView.frame.size.width)
        {
            self.currentPage = [self getPageIndex:self.currentPage-1];
            [self refreshScrollView];
        }
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        // 往下翻一张
        if (y >= (startPageIndex+1) * self.scrollView.frame.size.height)
        {
            self.currentPage = [self getPageIndex:self.currentPage+1];
            [self refreshScrollView];
        }
        
        if (y <= (startPageIndex-1) * self.scrollView.frame.size.height)
        {
            self.currentPage = [self getPageIndex:self.currentPage-1];
            [self refreshScrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    //NSInteger x = aScrollView.contentOffset.x;
    //NSInteger y = aScrollView.contentOffset.y;
    
    //NSLog(@"--end  x=%d  y=%d", x, y);
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width*startPageIndex, 0);
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height*startPageIndex);
    }
    
    if (isRolling)
    {
        // 用于手动拖动时继续继续滚动
        //NSLog(@"scrollViewDidEndDecelerating performSelector");
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
        [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
}


#pragma mark -
#pragma mark Rolling

- (void)refreshRolling
{
    if (self.imageArray.count < 1)
    {
        return;
    }
    
    if (!isRolling)
    {
        [self refreshScrollView];
        [self startRolling];
    }
}

- (void)startRolling
{
    if (self.imageArray.count <= 1)
    {
        return;
    }
    
    if (self.rollingDelayTime < 1)
    {
        return;
    }
    
    [self stopRolling];
    
    isRolling = YES;
    //NSLog(@"startRolling performSelector");
    [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    // 从后台回来后重新启动动画
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRolling) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)stopRolling
{
    isRolling = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    //取消已加入的延迟线程
    //NSLog(@"stopRolling cancelPreviousPerformRequestsWithTarget");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
}

- (void)rollingScrollAction
{
    //NSLog(@"rollingScrollAction");
    //NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));

    [UIView animateWithDuration:0.25 animations:^{
        // 水平滚动
        if (self.scrollDirection == BannerViewScrollDirectionLandscape)
        {
            self.scrollView.contentOffset = CGPointMake((startPageIndex+1)*self.scrollView.frame.size.width-0.5, 0);
        }
        // 垂直滚动
        else if (self.scrollDirection == BannerViewScrollDirectionPortait)
        {
            self.scrollView.contentOffset = CGPointMake(0, (startPageIndex+1)*self.scrollView.frame.size.height-0.5);
        }
        //NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    } completion:^(BOOL finished) {
        if (finished)
        {
            self.currentPage = [self getPageIndex:self.currentPage+1];
            [self refreshScrollView];
            
            if (isRolling)
            {
                //NSLog(@"rollingScrollAction performSelector");
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
                [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            }
        }
        else
        {
            isRolling = NO;
        }
    }];
}


#pragma mark -
#pragma mark action

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self.bgView];
    //NSLog(@"tapPoint: %@", NSStringFromCGPoint(tapPoint));
    
    NSUInteger index = 0;
    
    if (self.imageArray.count > 0)
    {
        // 水平滚动
        if (self.scrollDirection == BannerViewScrollDirectionLandscape)
        {
            CGFloat width = self.bgView.bounds.size.width;
            if (tapPoint.x <= 0)
            {
                index = [self getPageIndex:self.currentPage-1] - startPageIndex;
            }
            else if (tapPoint.x <= width)
            {
                index = self.currentPage-startPageIndex;
            }
            else if (tapPoint.x > width)
            {
                index = [self getPageIndex:self.currentPage+1] - startPageIndex;
            }
        }
        // 垂直滚动
        else if (self.scrollDirection == BannerViewScrollDirectionPortait)
        {
            CGFloat height = self.bgView.bounds.size.height;
            if (tapPoint.y <= 0)
            {
                index = [self getPageIndex:self.currentPage-1] - startPageIndex;
            }
            else if (tapPoint.y <= height)
            {
                index = self.currentPage-startPageIndex;
            }
            else if (tapPoint.y > height)
            {
                index = [self getPageIndex:self.currentPage+1] - startPageIndex;
            }
        }
        
        if (index < self.imageArray.count )
        {
            NSLog(@"Banner Click: %@", @(index));
            if ([self.delegate respondsToSelector:@selector(bannerView:didSelectIndex:)])
            {
                [self.delegate bannerView:self didSelectIndex:index];
            }
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!CGRectContainsPoint(self.bgView.frame, point))
    {
        if (CGRectContainsPoint(self.bounds, point))
        {
            return self.scrollView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end

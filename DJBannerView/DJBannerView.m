//
//  DJBannerView.m
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/2.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "DJBannerView.h"
#import "UIImageView+WebCache.h"


// 只能奇数 3
#define Banner_CacheCount       3


@interface DJBannerView ()
<
    UIScrollViewDelegate
>
{
    BOOL isRolling;
    
    NSInteger totalPage;
    NSInteger startPageIndex;
}

// 只能奇数 3
@property (nonatomic, assign) NSUInteger cacheSize;

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


@implementation DJBannerView

- (void)dealloc
{
    _delegate = nil;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollingScrollAction) object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.clipsToBounds = YES;
        
        _cacheSize = Banner_CacheCount;
        
        _placeholderImage = nil;
        
        _imageArray = [[NSArray alloc] initWithArray:images];
        
        _scrollDirection = direction;
        
        // 第一张图片在图片数组的位置
        startPageIndex = _cacheSize/2;
        _currentPage = startPageIndex;
        
        totalPage = _imageArray.count;

        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [scrollView setClipsToBounds:NO];
        
        _scrollView = scrollView;
        [self addSubview:_scrollView];
        
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
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
            imageView.userInteractionEnabled = YES;
            imageView.tag = Banner_StartTag+i;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [singleTap setNumberOfTapsRequired:1];
            [singleTap setNumberOfTouchesRequired:1];
            [imageView addGestureRecognizer:singleTap];
            imageView.exclusiveTouch = YES;
            
            // 水平滚动
            if (_scrollDirection == BannerViewScrollDirectionLandscape)
            {
                imageView.frame = CGRectOffset(imageView.frame, scrollView.frame.size.width * i, 0);
            }
            // 垂直滚动
            else if (_scrollDirection == BannerViewScrollDirectionPortait)
            {
                imageView.frame = CGRectOffset(imageView.frame, 0, scrollView.frame.size.height * i);
            }
            
            [scrollView addSubview:imageView];
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
    if (rollingDelayTime == 0)
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
    if (self.scrollView)
    {
        self.scrollView.layer.cornerRadius = cornerRadius;
        if (cornerRadius == 0)
        {
            self.scrollView.layer.masksToBounds = NO;
        }
        else
        {
            self.scrollView.layer.masksToBounds = YES;
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

- (void)showClose:(BOOL)show
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
    for (NSUInteger i=self.currentPage-startPageIndex; i<=self.currentPage+startPageIndex; i++)
    {
        NSInteger index = [self getPageIndex:i]-startPageIndex;
        [images addObject:self.imageArray[index]];
    }
    
    return images;
}

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
    
    //取消已加入的延迟线程
    if (isRolling)
    {
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
    
    [self stopRolling];
    
    isRolling = YES;
    //NSLog(@"startRolling performSelector");
    [self performSelector:@selector(rollingScrollAction) withObject:nil afterDelay:self.rollingDelayTime inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)stopRolling
{
    isRolling = NO;
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

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.imageArray.count)
    {
        NSUInteger index = self.currentPage-startPageIndex;
        if (index<self.imageArray.count)
        {
            if ([self.delegate respondsToSelector:@selector(bannerView:didSelectIndex:)])
            {
                [self.delegate bannerView:self didSelectIndex:index];
            }
        }
    }
}


@end

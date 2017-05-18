//
//  DJManualBannerView.m
//  DJBannerViewSample
//
//  Created by dengjiang on 16/6/3.
//  Copyright © 2016年 DJ. All rights reserved.
//

#import "DJManualBannerView.h"
#import "UIImageView+WebCache.h"


@interface DJManualBannerView ()
<
    UIScrollViewDelegate
>
{
    NSInteger totalPage;
}

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIButton *closeButton;

// 存放所有需要滚动的图片URL NSString
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSInteger currentPage;


- (void)refreshScrollView;

@end

@implementation DJManualBannerView

- (instancetype)initWithFrame:(CGRect)frame scrollDirection:(BannerViewScrollDirection)direction images:(NSArray *)images padding:(CGFloat)padding pageWidth:(CGFloat)pageWidth dataSource:(id <DJBannerViewDataSource>)adataSource
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.scrollDirection = direction;
        
        self.padding = padding;
        self.pageWidth = pageWidth;
        
        CGRect scrollViewFrame = CGRectMake(0, 0, pageWidth, self.bounds.size.height);
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self setClipsToBounds:NO];
        [scrollView setClipsToBounds:NO];
        
        self.scrollView = scrollView;
        [self addSubview:self.scrollView];
        
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(5, frame.size.height-(Banner_PageHeight+Banner_PageBottomGap), Banner_PageWidth, Banner_PageHeight)];
        self.pageControl = pageControl;
        pageControl.userInteractionEnabled = NO;
        [self addSubview:pageControl];
        
        self.dataSource = adataSource;
        
        [self reloadBannerWithData:images];
    }
    
    return self;
}

- (void)reloadBannerWithData:(NSArray *)images
{
    if (images.count)
    {
        self.imageArray = [[NSMutableArray alloc] initWithArray:images];
        
        totalPage = self.imageArray.count;
    }
    else if (self.dataSource)
    {
        self.imageArray = [[NSMutableArray alloc] initWithCapacity:0];
        totalPage = [self.dataSource bannerViewCountOfPages:self];
    }
    
    self.currentPage = 0;
    self.pageControl.numberOfPages = totalPage;
    self.pageControl.currentPage = 0;
    
    while (self.scrollView.subviews.count > 0)
    {
        UIView *child = self.scrollView.subviews.lastObject;
        [child removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < totalPage; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:self.scrollView.bounds];
        view.backgroundColor = [UIColor clearColor];
        
        UIView *addView = nil;
        if (self.dataSource)
        {
            addView = [self.dataSource bannerView:self pageAtIndex:i];
            NSAssert(addView, @"Cannot show the pages!");
            if (self.hasLeftPadding)
            {
                addView.frame = CGRectMake(self.padding, 0, view.bounds.size.width-self.padding, view.bounds.size.height);
            }
            else
            {
                addView.frame = CGRectMake(0, 0, view.bounds.size.width-self.padding, view.bounds.size.height);
            }
            addView.tag = Banner_StartTag+i;
            addView.userInteractionEnabled = YES;
            [view addSubview:addView];
        }
        else
        {
            CGRect frame;
            if (self.hasLeftPadding)
            {
                frame = CGRectMake(self.padding, 0, view.bounds.size.width-self.padding, view.bounds.size.height);
            }
            else
            {
                frame = CGRectMake(0, 0, view.bounds.size.width-self.padding, view.bounds.size.height);
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.userInteractionEnabled = YES;
            imageView.tag = Banner_StartTag+i;
            [view addSubview:imageView];
            addView = imageView;
        }
        
        // 水平滚动
        if (self.scrollDirection == BannerViewScrollDirectionLandscape)
        {
            view.frame = CGRectOffset(view.frame, self.scrollView.frame.size.width * i, 0);
        }
        // 垂直滚动
        else if (self.scrollDirection == BannerViewScrollDirectionPortait)
        {
            view.frame = CGRectOffset(view.frame, 0, self.scrollView.frame.size.height * i);
        }
        
        [self.scrollView addSubview:view];
        
        UIControl *control = [[UIControl alloc] initWithFrame:view.bounds];
        control.tag = Banner_CStartTag+i;
        [view addSubview:control];
        [control addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        control.exclusiveTouch = YES;
    }
    
    // 在水平方向滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * totalPage+self.padding,
                                                   self.scrollView.frame.size.height);
    }
    // 在垂直方向滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                   self.scrollView.frame.size.height * totalPage+self.padding);
    }
    
    [self refreshScrollView];
}


#pragma mark -
#pragma mark set

- (void)setCorner:(NSInteger)cornerRadius
{
    for (NSInteger i = 0; i < totalPage; i++)
    {
        UIView *view = (UIView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        if (view)
        {
            view.layer.cornerRadius = cornerRadius;
            if (cornerRadius == 0)
            {
                view.layer.masksToBounds = NO;
            }
            else
            {
                view.layer.masksToBounds = YES;
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

- (void)setPadding:(CGFloat)padding
{
    if (padding < 0)
    {
        return;
    }
    
    _padding = padding;
    for (NSInteger i = 0; i < totalPage; i++)
    {
        UIView *view = (UIView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        if (view)
        {
            CGRect frame;
            if (self.hasLeftPadding)
            {
                frame = CGRectMake(self.padding, 0, self.scrollView.bounds.size.width-self.padding, self.scrollView.bounds.size.height);
            }
            else
            {
                frame = CGRectMake(0, 0, self.scrollView.bounds.size.width-self.padding, self.scrollView.bounds.size.height);
            }
            view.frame = frame;
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
    if ([self.delegate respondsToSelector:@selector(bannerViewDidClosed:)])
    {
        [self.delegate bannerViewDidClosed:self];
    }
}


#pragma mark - Custom Method

- (void)refreshScrollView
{
    for (NSInteger i = 0; i < totalPage; i++)
    {
        //UIView *view = nil;
        if (self.dataSource)
        {
            //view = (UIView *)[self.scrollView viewWithTag:Banner_StartTag+i];
        }
        else
        {
            UIImageView *imageView = (UIImageView *)[self.scrollView viewWithTag:Banner_StartTag+i];
            NSString *url = self.imageArray[i];
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
                //view = imageView;
            }
        }
    }
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width*0, 0);
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height*0);
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSInteger x = aScrollView.contentOffset.x;
    NSInteger y = aScrollView.contentOffset.y;
    //NSLog(@"did  x=%d  y=%d", x, y);
    
    NSInteger width = aScrollView.contentSize.width;
    NSInteger height = aScrollView.contentSize.height;
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        if (width < self.frame.size.width)
        {
            aScrollView.contentOffset = CGPointZero;
            
            return;
        }
        if ((width-x) < self.frame.size.width)
        {
            CGPoint point = aScrollView.contentOffset;
            point.x = aScrollView.contentSize.width - self.frame.size.width;
            aScrollView.contentOffset = point;
        }
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        if (height < self.frame.size.height)
        {
            aScrollView.contentOffset = CGPointZero;
            
            return;
        }
        if ((height-y) < self.frame.size.height)
        {
            CGPoint point = aScrollView.contentOffset;
            point.y = aScrollView.contentSize.height - self.frame.size.height;
            aScrollView.contentOffset = point;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    NSInteger x = aScrollView.contentOffset.x;
    NSInteger y = aScrollView.contentOffset.y;
    //NSLog(@"did  x=%d  y=%d", x, y);
    
    NSInteger width = aScrollView.contentSize.width;
    NSInteger height = aScrollView.contentSize.height;
    
    // 水平滚动
    if (self.scrollDirection == BannerViewScrollDirectionLandscape)
    {
        if (width < self.frame.size.width)
        {
            aScrollView.contentOffset = CGPointZero;
            
            return;
        }
        if ((width-x) < self.frame.size.width)
        {
            CGPoint point = aScrollView.contentOffset;
            point.x = aScrollView.contentSize.width - self.frame.size.width;
        }
    }
    // 垂直滚动
    else if (self.scrollDirection == BannerViewScrollDirectionPortait)
    {
        if (height < self.frame.size.height)
        {
            aScrollView.contentOffset = CGPointZero;
            
            return;
        }
        if ((height-y) < self.frame.size.height)
        {
            CGPoint point = aScrollView.contentOffset;
            point.y = aScrollView.contentSize.height - self.frame.size.height;
        }
    }
}


#pragma mark -
#pragma mark action

- (void)click:(UIControl *)control
{
    NSInteger index = control.tag-Banner_CStartTag;
    NSLog(@"click at index: %@", @(index));
    
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectIndex:)])
    {
        [self.delegate bannerView:self didSelectIndex:index];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (NSInteger i = 0; i < totalPage; i++)
    {
        UIControl *control = (UIControl *)[self.scrollView viewWithTag:Banner_CStartTag+i];
        if (control)
        {
            if (CGRectContainsPoint([self convertRect:control.frame fromView:control], point))
            {
                return control;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end

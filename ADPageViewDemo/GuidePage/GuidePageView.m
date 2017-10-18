//
//  GuidePageView.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/18.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "GuidePageView.h"

static NSString *const kAppVersion = @"appVersion";
static NSString *const kCFBundleShortVersionString = @"CFBundleShortVersionString";


@interface GuidePageView ()<UIScrollViewDelegate> {
    UIScrollView  *launchScrollView;
    UIPageControl *page;
}

@end

@implementation GuidePageView
NSArray *images;
BOOL isScrollOut;//在最后一页再次滑动是否隐藏引导页
CGRect enterBtnFrame;
NSString *enterBtnImage;
static GuidePageView *launchView = nil;

#pragma mark - Init methods
//不带按钮的引导页
+ (instancetype)sharedWithImages:(NSArray *)imageNames {
    images = imageNames;
    isScrollOut = YES;
    launchView = [[GuidePageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    launchView.backgroundColor = [UIColor whiteColor];
    return launchView;
}

//带按钮的引导页
+ (instancetype)sharedWithImages:(NSArray *)imageNames buttonImage:(NSString *)buttonImageName buttonFrame:(CGRect)frame {
    images = imageNames;
    isScrollOut = NO;
    enterBtnFrame = frame;
    enterBtnImage = buttonImageName;
    launchView = [[GuidePageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    launchView.backgroundColor = [UIColor whiteColor];
    return launchView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"currentColor" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"nomalColor" options:NSKeyValueObservingOptionNew context:nil];
        UIWindow *window = [[UIApplication sharedApplication] windows].lastObject;
        [window addSubview:self];
        [self addImages];
    }
    return self;
}

//添加引导页图片
- (void)addImages {
    [self createScrollView];
}

- (void)createScrollView {
    launchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    launchScrollView.showsHorizontalScrollIndicator = NO;
    launchScrollView.bounces = NO;
    launchScrollView.pagingEnabled = YES;
    launchScrollView.delegate = self;
    launchScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * images.count, SCREEN_HEIGHT);
    [self addSubview:launchScrollView];
    
    for (int i = 0; i < images.count; i ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageView.image = [UIImage imageNamed:images[i]];
        [launchScrollView addSubview:imageView];
        if (i == images.count - 1) {
            //判断要不要添加button
            if (!isScrollOut) {
                UIButton *enterButton = [[UIButton alloc] initWithFrame:CGRectMake(enterBtnFrame.origin.x, enterBtnFrame.origin.y, enterBtnFrame.size.width, enterBtnFrame.size.height)];
                [enterButton setImage:[UIImage imageNamed:enterBtnImage] forState:UIControlStateNormal];
                [enterButton addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
                [imageView addSubview:enterButton];
                imageView.userInteractionEnabled = YES;
            }
        }
    }
    page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 30)];
    page.numberOfPages = images.count;
    page.backgroundColor = [UIColor clearColor];
    page.currentPage = 0;
    page.defersCurrentPageDisplay = YES;
    [self addSubview:page];
}

#pragma mark - Event response
//进入按钮
- (void)enterBtnClick {
    [self hideGuidView];
}

//隐藏引导页
- (void)hideGuidView {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    int cuttentIndex = (int)(scrollView.contentOffset.x + SCREEN_WIDTH/2)/SCREEN_WIDTH;
    if (cuttentIndex == images.count - 1) {
        if ([self isScrolltoLeft:scrollView]) {
            if (!isScrollOut) {
                return ;
            }
            [self hideGuidView];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == launchScrollView) {
        int cuttentIndex = (int)(scrollView.contentOffset.x + SCREEN_WIDTH/2)/SCREEN_WIDTH;
        page.currentPage = cuttentIndex;
    }
}

#pragma mark - Private methods
//判断滚动方向
- (BOOL)isScrolltoLeft:(UIScrollView *)scrollView {
    //YES为向左滚动，NO为右滚动
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        return YES;
    }else{
        return NO;
    }
}

//KVO监测值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentColor"]) {
        page.currentPageIndicatorTintColor = self.currentColor;
    }
    if ([keyPath isEqualToString:@"nomalColor"]) {
        page.pageIndicatorTintColor = self.nomalColor;
    }
}
@end

//
//  ADPageView.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/18.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "ADPageView.h"
static int const showTime = 3;
static NSString *const adImageName = @"adImageName";
static NSString *const adUrl = @"adUrl";

@interface ADPageView ()

@property (nonatomic, strong) UIImageView *adView;
@property (nonatomic, strong) UIButton *skipBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeCount;

//广告图片本地地址
@property (nonatomic, copy) NSString *imagePath;
//新广告图片URL
@property (nonatomic, copy) NSString *imageUrl;
//新广告URL
@property (nonatomic, copy) NSString *adUrl;

@end

@implementation ADPageView

static ADPageView *adPageView = nil;

#pragma mark - Lazy methods
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerDown) userInfo:nil repeats:YES];
    }
    return _timer;
}

#pragma mark - Public methods
+ (instancetype)showAdPageView {
    adPageView = [[ADPageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    adPageView.backgroundColor = [UIColor whiteColor];
    
    return adPageView;
}

#pragma mark - Init methods
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //广告页
        _adView = [[UIImageView alloc] initWithFrame:frame];
        _adView.userInteractionEnabled = YES;
        _adView.contentMode = UIViewContentModeScaleAspectFit;
        _adView.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToAd)];
        [_adView addGestureRecognizer:tap];
        
        //跳过按钮
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.backgroundColor = RGBAColor(38, 38, 38, 0.6);
        _skipBtn.layer.cornerRadius = 4;
        [_skipBtn setTitle:[NSString stringWithFormat:@"跳过%d",showTime] forState:UIControlStateNormal];
        [_skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _skipBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_skipBtn addTarget:self action:@selector(dismissAdView) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_adView];
        [self addSubview:_skipBtn];
        _skipBtn.sd_layout
        .widthIs(60)
        .heightIs(30)
        .topSpaceToView(self, 20)
        .rightSpaceToView(self, 20);
        
        [self showAdView];
    }
    return self;
}

//展示广告
- (void)showAdView {
    
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    //先从sd缓存读取，有则显示
    NSString *imagePath = [[imageManager imageCache] defaultCachePathForKey:adImageName];
    NSData * imageData = [NSData dataWithContentsOfFile:imagePath];
    
    if (imageData) {
        [self adViewWithData:imageData];
    }
    
    NSArray *imageArray = @[@"http://img.hb.aicdn.com/4cdbe766dc5a206da266a262ee87d9e5cf19eafb26a9d-xqBO2L_fw658", @"http://img.hb.aicdn.com/926c595bfb97b663077940b6598f63fa318dda092c174-hmqXI3_fw658", @"http://img.hb.aicdn.com/0e0d63ad054e9d48a3abb497c2c18e4b4293af4e134f6-CuXVbn_fw658", @"http://img.hb.aicdn.com/d534a50adbf8c0a6a886f28b7cc7148a723be6c42f511-9gvr0u_fw658"];
    NSURL *url = [NSURL URLWithString:imageArray[arc4random() % imageArray.count]];
    
    SDWebImageDownloader *downManager = [SDWebImageDownloader sharedDownloader];
    //不管缓存是否存在图片，都重新请求新的图片，删除旧的，保存新的图片
    [imageManager cachedImageExistsForURL:url  completion:^(BOOL isInCache) {
        //删除
        [[SDImageCache sharedImageCache] removeImageForKey:adImageName withCompletion:nil];
    }];
    [downManager downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        //保存
        if (image && finished) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:adImageName completion:nil];
        }
    }];
}

- (void)adViewWithData:(NSData *)data {
    [self startTimer];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    _adView.image = [UIImage imageWithData:data];
    _adView.contentMode = UIViewContentModeScaleAspectFill;
}


//开始倒计时
- (void)startTimer {
    _timeCount = showTime;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - Event response
- (void)timerDown {
    _timeCount --;
    [_skipBtn setTitle:[NSString stringWithFormat:@"跳过%zd",_timeCount] forState:UIControlStateNormal];
    if (_timeCount == 0) {
        [self dismissAdView];
    }
}


- (void)pushToAd {
    [self dismissAdView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToAd" object:nil];
}

//移除广告页
- (void)dismissAdView {
    [self.timer invalidate];
    self.timer = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



@end

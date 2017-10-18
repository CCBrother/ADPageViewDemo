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

//初始化展示广告View
- (void)showAdView {
    //先出沙盒读取路径
    NSString *filePath = [self getFilePathWithImageName:UserDefaultObjectForKey(adImageName)];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (isExist) {
        
        [self startTimer];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        
        [_skipBtn setTitle:[NSString stringWithFormat:@"跳过%d",showTime] forState:UIControlStateNormal];
        _adView.image = [UIImage imageWithContentsOfFile:filePath];
        _adView.contentMode = UIViewContentModeScaleAspectFill;
        _adUrl = UserDefaultObjectForKey(adUrl);
    }
    //无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
    [self getAdImage];
}

- (void)getAdImage {
    NSArray *imageArray = @[@"http://img.hb.aicdn.com/4cdbe766dc5a206da266a262ee87d9e5cf19eafb26a9d-xqBO2L_fw658", @"http://img.hb.aicdn.com/926c595bfb97b663077940b6598f63fa318dda092c174-hmqXI3_fw658", @"http://img.hb.aicdn.com/0e0d63ad054e9d48a3abb497c2c18e4b4293af4e134f6-CuXVbn_fw658", @"http://img.hb.aicdn.com/d534a50adbf8c0a6a886f28b7cc7148a723be6c42f511-9gvr0u_fw658"];
    NSString *imageUrl = imageArray[arc4random() % imageArray.count];
    NSString *imageName = [imageUrl lastPathComponent];
    //拼接沙盒路径
    NSString *filePath = [self getFilePathWithImageName:imageName];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    //如果图片不存在，则重新下载，删除老图片
    if (!isExist) {
        [self downLoadAdImageWithUrl:imageUrl imageName:imageName];
    }
}

//下载图片
- (void)downLoadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName {
    
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        //开始存储图片
        NSString *filePath = [self getFilePathWithImageName:imageName];
        NSLog(@"image:%@-----imageUrl:%@-----imageName:%@-----filePath:%@",image,imageUrl,imageName,filePath);
        if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {
            [self deleteOldImage];
            //存新图片和新广告链接
            UserDefaultSetObjectForKey(imageName, adImageName);
            UserDefaultSetObjectForKey(imageUrl, adUrl);
            UserDefaultSynchronize;
        }
    }];
}

//删除旧照片
- (void)deleteOldImage {
    NSString *imageName = UserDefaultObjectForKey(adImageName);
    if (imageName) {
        NSString *filePath = [self getFilePathWithImageName:imageName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

//开始倒计时
- (void)startTimer {
    _timeCount = showTime;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}



//根据图片名称生成路径
- (NSString *)getFilePathWithImageName:(NSString *)imageName {
    if (imageName) {
        NSString *cachePaths = kPathCache;
        NSString *imagePath = [cachePaths stringByAppendingPathComponent:imageName];
        return imagePath;
    }
    return nil;
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

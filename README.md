# ADPageViewDemo
## 一、广告页功能思路
* APP第一次安装或版本更新时，有引导页的时候不展示广告，第二次开始展示广告

* 创建一个展示广告的Imageview

* 添加跳过广告的倒计时按钮

* 添加广告页面点击事件，点击广告图片跳转到响应页面；广告链接地址也需要用NSUserDefaults存储。注意：广告详情页面是从首页push进去的

* 加载：在启动页展示的时间里，开始加载广告，先将图片通过SD异步下载到本地，并保存图片名，每次打开app时先根据本地存储的图片名查找沙盒中是否存在该图片，如果存在，则显示广告页。在启动页加载完成之后应该去判断广告是否有加载出来

* 判断广告图片是否更新：无论本地是否存在广告图片，每次启动都需要重新调用广告接口，根据图片名称或者图片id等方法判断广告是否更新，如果获取的图片名称或者图片id跟本地存储的不一致，则需要重新下载新图片，并删除旧图片

* 广告页面的底部和启动图的底部一般都是相同的，给我们的感觉就是启动图加载完之后把广告图放在了启动图上，而且不能有偏差，比如下图淘宝启动画面。美工在制作广告图的时候要注意这点

* APP在后台：如果app在后台待机太久，再次进来前台的时候也应该展示广告，所以在applicationDidEnterBackground的时候应该把时间存起来。在applicationWillEnterForeground的时候对比时间差，判断是否显示

* 增加广告显示开关：后台在开发广告api的时候可以增加一个字段来判断是否启用广告，如果后台关闭了广告，将沙盒中的图片删除即可

* 添加统计：看广告详情有多少人观看，有多少人会跳过等

## 二、步骤
#### 1、首先判断APP是否是第一次进入或者版本更新，如果是，启动引导页；如果不是，再判断是否需要显示广告。
```
if ([Manager isFirstLaunch]) {
        //一句代码启动引导页
        [GuidePageView sharedWithImages:@[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg"] buttonImage:@"post_normal" buttonFrame:CGRectMake(0, -10, SCREEN_WIDTH, SCREEN_HEIGHT)];`
    }else {
        //显示广告页
        //后台在开发广告api的时候增加一个字段来判断是否启用广告
        if (self.isShowAdPage) {}
        //一句代码调用广告页
        [ADPageView showAdPageView];
   }
```
#### 2、创建一个展示广告的Imageview和添加跳过广告的倒计时按钮
```
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
```
#### 3、广告页加载，先从SD缓存查找，有，则显示，并下载更新，删除旧图片；没有，下载，保存。
```
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

```

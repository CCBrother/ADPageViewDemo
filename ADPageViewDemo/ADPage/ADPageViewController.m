//
//  ADPageViewController.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/18.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "ADPageViewController.h"

@interface ADPageViewController ()

@end

@implementation ADPageViewController

#pragma mark - Init Methods

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"广告页";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.adUrl]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

#pragma mark - Event response

#pragma mark - Notifications

#pragma mark - UITableViewDelegate

#pragma mark - XXXDelegate

#pragma mark - Custom views

#pragma mark - Setter Getter Methods

#pragma mark - Public methods

#pragma mark - Private methods


@end

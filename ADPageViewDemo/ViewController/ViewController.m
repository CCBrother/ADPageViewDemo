//
//  ViewController.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/17.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "ViewController.h"
#import "ADPageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor cyanColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToAd) name:@"pushToAd" object:nil];
}

- (void)pushToAd {
    ADPageViewController *adVC = [[ADPageViewController alloc] init];
    adVC.adUrl = @"https://www.baidu.com/index.php?tn=monline_3_dg";
    [self.navigationController pushViewController:adVC animated:YES];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

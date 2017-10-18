//
//  Manager.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/17.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "Manager.h"

static NSString *const kAppVersion = @"appVersion";
static NSString *const kCFBundleShortVersionString = @"CFBundleShortVersionString";

@implementation Manager

//判断是否是首次登录或者版本更新
+ (BOOL)isFirstLaunch {
    //获取当前版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = infoDic[kCFBundleShortVersionString];
    //获取上次启动应用保存的appVersion
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
    //版本升级或首次登录
    if (version == nil || ![version isEqualToString:currentVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kAppVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"首次登录或版本升级");
        return YES;
    }else {
        NSLog(@"不是首次登录或版本升级");
        return NO;
    }
}

@end

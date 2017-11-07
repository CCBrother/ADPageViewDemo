//
//  AppDelegate.m
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/17.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import "AppDelegate.h"
#import "Manager.h"
#import "ViewController.h"
#import "GuidePageView.h"
#import "ADPageView.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL *isShowAdPage;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = SCREEN_BOUNDS;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    //启动图延迟
    [NSThread sleepForTimeInterval:1.f];
    
    //首先判断是否是第一次进入或者版本更新，如果是，启动引导页；如果不是，再判断是否需要显示广告。
    if ([Manager isFirstLaunch]) {
        //启动引导页
        [GuidePageView sharedWithImages:@[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg"] buttonImage:@"post_normal" buttonFrame:CGRectMake(0, -10, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }else {
        //显示广告页
        //后台在开发广告api的时候增加一个字段来判断是否启用广告
        if (self.isShowAdPage) {}
        [ADPageView showAdPageView];
    }
    return YES;
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

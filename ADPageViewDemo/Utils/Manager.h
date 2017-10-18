//
//  Manager.h
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/17.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manager : NSObject

//判断是否是首次登录或者版本更新
+ (BOOL)isFirstLaunch;

@end

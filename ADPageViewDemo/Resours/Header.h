//
//  Header.h
//  ADPageViewDemo
//
//  Created by ZhangCc on 2017/10/18.
//  Copyright © 2017年 ZhangCc. All rights reserved.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */



//--------------------获取屏幕宽度与高度--------------------
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define SCREEN_BOUNDS  [UIScreen mainScreen].bounds

//--------------------NSUserDefaults 存／取／删对象--------------------
//存储对象
#define UserDefaultSetObjectForKey(__VALUE__,__KEY__) [[NSUserDefaults standardUserDefaults] setObject:__VALUE__ forKey:__KEY__]

//获得存储的对象
#define UserDefaultObjectForKey(__KEY__) [[NSUserDefaults standardUserDefaults] objectForKey:__KEY__]

//删除对象
#define UserDefaultRemoveObjectForKey(__KEY__) \ {\ [[NSUserDefaults standardUserDefaults] removeObjectForKey:__KEY__];\ [[NSUserDefaults standardUserDefaults] synchronize];\ }

//同步对象
#define UserDefaultSynchronize [[NSUserDefaults standardUserDefaults] synchronize]

//--------------------颜色--------------------
//设置RGB颜色
#define RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]//用10进制表示颜色，例如（255,255,255）黑色
//设置RGBA颜色
#define RGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(r)/255.0 alpha:a]
//设置随机颜色
#define RandomColor ZKRGBColor(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))
//清空颜色
#define ClearColor [UIColor clearColor]

//--------------------沙盒目录文件--------------------
//获取 temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

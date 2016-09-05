//
//  AppDelegate.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "AppDelegate.h"
#import "WXController.h"
#import <TSMessage.h>
#import "WXViewModel.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 1初始化并设置WXController实例作为App的根视图控制器
    self.window.rootViewController = [[WXController alloc] initWithViewModel:[WXViewModel new]];
    // 2设置默认的视图控制器来显示你的TSMessages。这样做，你将不再需要手动指定要使用的控制器来显示警告
    [TSMessage setDefaultViewController:self.window.rootViewController];
    
    
    return YES;
}



@end

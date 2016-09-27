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
#import "WXViewModelServicesImpl.h"
#import "LaunchViewController.h"

@interface AppDelegate ()




@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    
    
    // 初始化窗口
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 初始化启动控制器
    LaunchViewController *lauchVc = [[UIStoryboard storyboardWithName:@"LaunchAnimation" bundle:nil] instantiateInitialViewController];
    self.window.rootViewController = lauchVc;
    
    @weakify(self);
    lauchVc.completionBlock = ^ {
        @strongify(self);
        // 1网络服务ViewModel
        WXViewModelServicesImpl *viewModelServices = [[WXViewModelServicesImpl alloc] init];
        // 2WXController的ViewModel
        WXViewModel *viewModel = [[WXViewModel alloc] initWithServices:viewModelServices];
        // 3初始化并设置WXController实例作为App的根视图控制器
        WXController *wxVc = [[WXController alloc] initWithViewModel:viewModel];
        wxVc.view.alpha = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                wxVc.view.alpha = 1.0;
            }];
        });
        self.window.rootViewController = wxVc;
        // 4设置默认的视图控制器来显示你的TSMessages。这样做，你将不再需要手动指定要使用的控制器来显示警告
        [TSMessage setDefaultViewController:self.window.rootViewController];
        
    };
    
   
    
    
    
    
    return YES;
}



@end

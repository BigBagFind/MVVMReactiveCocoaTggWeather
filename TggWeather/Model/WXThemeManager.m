//
//  WXThemeManager.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/22.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXThemeManager.h"

@implementation WXThemeManager


/** 单例初始化 */
+ (instancetype)shareThemeManager {
    static WXThemeManager * themeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 主题中心初始化
        themeManager = [[WXThemeManager alloc] init];
    });
    return themeManager;
}


/** 发送更改单位通知 */
- (void)postWeatherUnitChangeNotification:(NSObject *)object {
    
    // 存储本次主题
    [self.themeModel saveWeatherUnit:object];
    // 获取本次主题
    [_themeModel getWeatherUnit];
    
    [WXNotification postNotificationName:WXChangeWeatherUnitNotification object:object];
}



- (WXThemeModel *)themeModel {
    if (!_themeModel) {
        _themeModel = [WXThemeModel new];
        [_themeModel getWeatherUnit];
    }
    return _themeModel;
}












@end


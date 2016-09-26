//
//  ThemeModel.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/23.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXThemeModel.h"
#import "WXThemeManager.h"


typedef NS_ENUM(NSInteger, WXWeatherUnitType) {
    WXWeatherUnitypeFahrenheit          = 0,  // 华氏度
    WXWeatherUnitTypeCelsius            = 1   // 摄氏度
};



@implementation WXThemeModel


- (void)saveWeatherUnit:(NSObject *)object {
    [WXUserDefaults setObject:object forKey:WXWeatherUnit];
    [WXUserDefaults synchronize];
}

// 从本地读取当前的主题模式，更改后我们只需要更改本地数据 然后重新调用这个方法即可
- (void)getWeatherUnit {
    //从本地读取
    NSNumber *unit = [WXUserDefaults objectForKey:WXWeatherUnit];
    NSInteger unitInt;
    if (unit) {
        unitInt = [unit integerValue];
    } else {
        unitInt = 0;
    }
    
    switch (unitInt) {
        case WXWeatherUnitypeFahrenheit: {
            self.unit = @"F";
        }
            break;
            
        case WXWeatherUnitTypeCelsius: {
            self.unit = @"C";
        }
            break;

        default:
            break;
    }
    
}

















@end

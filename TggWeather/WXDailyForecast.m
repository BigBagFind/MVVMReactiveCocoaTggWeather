//
//  WXDailyForecast.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1先继承父类，与之都相同
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2改变其中2个不同的keyValue，你需要为daily forecast做的是改变max和min键映射。
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3返回给预测Model，返回新的映射。
    return paths;
}


@end

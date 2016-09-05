//
//  WXManager.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//


#import <ReactiveCocoa/ReactiveCocoa.h>
// 1请注意，你没有引入WXDailyForecast.h，你会始终使用WXCondition作为预报的类。 WXDailyForecast的存在是为了帮助Mantle转换JSON到Objective-C。
#import "WXCondition.h"

@import Foundation;
@import CoreLocation;

@interface WXManager : NSObject


// 2使用instancetype而不是WXManager，子类将返回适当的类型
+ (instancetype)sharedManager;

// 3这些属性将存储您的数据。由于WXManager是一个单例，这些属性可以任意访问。设置公共属性为只读，因为只有管理者能更改这些值。
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

// 4这个方法启动或刷新整个位置和天气的查找过程。
- (void)findCurrentLocation;







@end

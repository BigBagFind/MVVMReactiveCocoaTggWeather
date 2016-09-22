//
//  WXWeather.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import <ReactiveCocoa.h>

@protocol WXWeather <NSObject>


/** 根据经纬度抓取当前天气情况 */
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;

/** 根据经纬度抓取当天小时预测 */
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;

/** 根据经纬度抓取当周每天预测 */
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;




@end

//
//  WXClient.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//\

@import CoreLocation;
@import Foundation;

#import <ReactiveCocoa/ReactiveCocoa.h>


@interface WXClient : NSObject





- (RACSignal *)fetchJSONFromURL:(NSURL *)url;

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;




@end

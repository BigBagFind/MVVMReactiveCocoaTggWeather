//
//  WXViewModel.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/4.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXViewModel.h"
#import "WXLocationImpl.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <TSMessages/TSMessage.h>
#import "WXThemeManager.h"

@interface WXViewModel ()<CLLocationManagerDelegate>

/** implementeServices */
@property (nonatomic, strong) id<WXViewModelServices> services;

/** LocationManager */
@property (nonatomic, strong) WXLocationImpl *locationManager;

// 声明你在公共接口中添加的相同的属性，但是这一次把他们定义为可读写，因此您可以在后台更改他们。
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;

@property (nonatomic, strong, readwrite) NSArray *hourlyForecasts;

@property (nonatomic, strong, readwrite) NSArray *dailyForecasts;


/** 小时格式 */
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;

/** 每天格式 */
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end


@implementation WXViewModel


/** 重写初始化方法 */
- (instancetype)initWithServices:(id<WXViewModelServices>)services {
    self = [super init];
    if (self) {
        _services = services;
        NSLog(@"_services :%@",_services);
        // 如果是小写的"hh"，那么时间将会跟着系统设置变成12小时或者24小时制
        // 大写的"HH"，则强制为24小时制
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        // EEEE为星期几，EEE为周几
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEE";
        
        [self initialize];
        
        // 添加通知观察单位的改变
        [[WXNotification rac_addObserverForName:WXChangeWeatherUnitNotification object:nil] subscribeNext:^(id x) {
            /*
             华氏度(℉)=32+摄氏度(℃)×1.8，
             
             摄氏度(℃)=（华氏度(℉)-32）÷1.8。
             */
            if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
                // 大的温度
                self.temperature = [NSString stringWithFormat:@"%.1lf",([self.temperature doubleValue] - 32) / 1.8];
                
                // 波动的高低温度
                CGFloat highTemp = ([self.high doubleValue] - 32) / 1.8;
                CGFloat lowTemp = ([self.low doubleValue] - 32) / 1.8;
                highTemp = (highTemp > 0) ? highTemp : 0;
                lowTemp = (lowTemp > 0) ? lowTemp : 0;
                self.high = @(highTemp);
                self.low = @(lowTemp);
                self.hilo = [NSString stringWithFormat:@"%.1f° / %.1f°",highTemp,lowTemp];
                
                // 逐时日报
                for (WXCondition *condition in self.hourlyForecasts) {
                    condition.temperature = @(([condition.temperature floatValue] - 32) / 1.8);
                }
                
                // 逐周报
                for (WXCondition *condition in self.dailyForecasts) {
                    condition.tempHigh = @(([condition.tempHigh floatValue] - 32) / 1.8);
                    condition.tempLow = @(([condition.tempLow floatValue] - 32) / 1.8);
                }
                

            } else {
                self.temperature = [NSString stringWithFormat:@"%.0lf",[self.temperature doubleValue] * 1.8 + 32];
                CGFloat highTemp = ([self.high doubleValue] * 1.8) + 32;
                CGFloat lowTemp = ([self.low doubleValue] * 1.8) + 32;
                highTemp = (highTemp > 0) ? highTemp : 0;
                lowTemp = (lowTemp > 0) ? lowTemp : 0;
                self.high = @(highTemp);
                self.low = @(lowTemp);
                self.hilo = [NSString stringWithFormat:@"%.0f° / %.0f°",highTemp,lowTemp];
                for (WXCondition *condition in self.hourlyForecasts) {
                    condition.temperature = @(([condition.temperature floatValue] * 1.8 + 32));
                }
                for (WXCondition *condition in self.dailyForecasts) {
                    condition.tempHigh = @(([condition.tempHigh floatValue] * 1.8 + 32));
                    condition.tempLow = @(([condition.tempLow floatValue] * 1.8 + 32));
                }
            }
            self.hourlyForecasts = [NSArray arrayWithArray:self.hourlyForecasts];
            self.dailyForecasts = [NSArray arrayWithArray:self.dailyForecasts];
        }];
        
    }
    return self;
}

- (void)initialize {
    
/*************** LocationInitialze ******************/
    
    [self updateCurrentConditions];
    
    self.locationManager = [WXLocationImpl new];
    [self.locationManager findCurrentLocation];
    // 管理器使用一个返回信号的ReactiveCocoa脚本来观察自身的currentLocation。这与KVO类似，但更为强大。
    self.fetchDataSignal = [[RACObserve(self.locationManager, currentLocation)
       // 为了继续执行方法链，currentLocation必须不为nil。
       ignore:nil]
       // -flattenMap：非常类似于-map：，但不是映射每一个值，它把数据变得扁平，并返回包含三个信号中的一个对象。通过这种方式，你可以考虑将三个进程作为单个工作单元。
       flattenMap:^RACStream *(CLLocation *newLocation) {
           NSLog(@"newLocation:%@",newLocation);
           return [RACSignal merge:@[
                                     [self updateCurrentConditions],
                                     [self updateDailyForecast],
                                     [self updateHourlyForecast]
                                    ]];
       }];

/*************** RACTableHeaderInitialze ******************/
    
    // 1观察currentCondition。
    [RACObserve(self, currentCondition) subscribeNext:^(WXCondition *newCondition) {
        // 2使用气象数据更新文本标签；你为文本标签使用newCondition的数据，订阅者的参数保证是最新值
        if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
            self.temperature = [NSString stringWithFormat:@"%.1f",([newCondition.temperature doubleValue] - 32) / 1.8];
        } else {
            self.temperature = [NSString stringWithFormat:@"%.0f",[newCondition.temperature doubleValue]];
        }
        self.condition = [newCondition.condition capitalizedString];
        self.city = [newCondition.locationName capitalizedString];
    
        // 3使用映射的图像文件名来创建一个图像，并将其设置为视图的图标
        self.iconName = [newCondition imageName];
     }];
    
     // 1RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    [[RACSignal combineLatest:
        // 2观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
        @[
          RACObserve(self, currentCondition.tempHigh),
          RACObserve(self, currentCondition.tempLow)
         ]
     // 3从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
     reduce:^(NSNumber *hi, NSNumber *low) {
         if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
             self.high = @(([hi doubleValue] - 32) / 1.8);
             self.low =  @(([low doubleValue] - 32) / 1.8);
             CGFloat highTemp = ([hi doubleValue] - 32) / 1.8;
             CGFloat lowTemp = ([low doubleValue] - 32) / 1.8;
             highTemp = (highTemp > 0) ? highTemp : 0;
             lowTemp = (lowTemp > 0) ? lowTemp : 0;
             return [NSString stringWithFormat:@"%.1f° / %.1f°",highTemp,lowTemp];
         } else {
             self.high = hi;
             self.low = low;
             return [NSString stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
         }
     }]
     subscribeNext:^(NSString *text) {
         self.hilo = text;
     }];
    
/*************** RACTableCellInitialze ******************/
 
    

}



- (NSString *)dailyStrWith:(WXCondition *)weather {
    return [self.dailyFormatter stringFromDate:weather.date];
}


- (NSString *)hourlyStrWith:(WXCondition *)weather {
    return [self.dailyFormatter stringFromDate:weather.date];
}


#pragma mark - FetchData
- (RACSignal *)updateCurrentConditions {
    NSLog(@"update:%@",self.locationManager.currentLocation);
    NSLog(@"services：%@",self.services);
    NSLog(@"getWeather:%@",[self.services getWeatherService]);
    return [[[self.services getWeatherService] fetchCurrentConditionsForLocation:self.locationManager.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        NSLog(@"condition:%@",condition);
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    NSLog(@"update:%@",self.locationManager.currentLocation);
    return [[[self.services getWeatherService] fetchHourlyForecastForLocation:self.locationManager.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        // 初始化处理数据
        if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
            for (WXCondition *condition in conditions) {
                condition.temperature = @(([condition.temperature floatValue] - 32) / 1.8);
            }
        }
        self.hourlyForecasts = conditions;
        NSLog(@"%@",conditions);
    }];
}

- (RACSignal *)updateDailyForecast {
    NSLog(@"update:%@",self.locationManager.currentLocation);
    return [[[self.services getWeatherService] fetchDailyForecastForLocation:self.locationManager.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        // 初始化处理数据
        if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
            for (WXCondition *condition in conditions) {
                condition.tempHigh = @(([condition.tempHigh floatValue] - 32) / 1.8);
                condition.tempLow = @(([condition.tempLow floatValue] - 32) / 1.8);
            }
        }
        self.dailyForecasts = conditions;
        NSLog(@"%@",conditions);
    }];
}








@end

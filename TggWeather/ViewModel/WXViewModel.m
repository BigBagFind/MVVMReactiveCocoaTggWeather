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
         // 2使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值
         self.temperature = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         self.condition = [newCondition.condition capitalizedString];
         self.city = [newCondition.locationName capitalizedString];
         // 3使用映射的图像文件名来创建一个图像，并将其设置为视图的图标
         self.iconName = [newCondition imageName];
     }];
    
     // 1RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    [[RACSignal combineLatest:
     // 2观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
     @[RACObserve(self, currentCondition.tempHigh),
        RACObserve(self, currentCondition.tempLow)]
     // 3从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
     reduce:^(NSNumber *hi, NSNumber *low) {
         return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
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
        self.hourlyForecasts = conditions;
        NSLog(@"%@",conditions);
    }];
}

- (RACSignal *)updateDailyForecast {
    NSLog(@"update:%@",self.locationManager.currentLocation);
    return [[[self.services getWeatherService] fetchDailyForecastForLocation:self.locationManager.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecasts = conditions;
        NSLog(@"%@",conditions);
    }];
}








@end

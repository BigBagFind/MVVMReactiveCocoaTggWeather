
//
//  WXManager.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>

@interface WXManager ()<CLLocationManagerDelegate>


// 1声明你在公共接口中添加的相同的属性，但是这一次把他们定义为可读写，因此您可以在后台更改他们。
@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// 2为查找定位和数据抓取声明一些私有变量。
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;


@end


@implementation WXManager


+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}



- (id)init {
    if (self = [super init]) {
        // 1创建一个位置管理器，并设置它的delegate为self。
        if([CLLocationManager locationServicesEnabled]) {
            // 1.创建CLLocationManage
            if (!_locationManager) {
                _locationManager = [[CLLocationManager alloc] init] ;
            }
            // 2.设置CLLocationManage实例委托和精度
            _locationManager.delegate = self;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [_locationManager requestWhenInUseAuthorization];
            }
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        } else {
            
        }
        // 2为管理器创建WXClient对象。这里处理所有的网络请求和数据分析，这是关注点分离的最佳实践。
        _client = [[WXClient alloc] init];
        
        // 3管理器使用一个返回信号的ReactiveCocoa脚本来观察自身的currentLocation。这与KVO类似，但更为强大。
     [[[[RACObserve(self, currentLocation)
        // 4为了继续执行方法链，currentLocation必须不为nil。
         ignore:nil]
         // 5- flattenMap：非常类似于-map：，但不是映射每一个值，它把数据变得扁平，并返回包含三个信号中的一个对象。通过这种方式，你可以考虑将三个进程作为单个工作单元。
        flattenMap:^RACStream *(CLLocation *newLocation) {
            return [RACSignal merge:@[
                                      [self updateCurrentConditions],
                                      [self updateDailyForecast],
                                      [self updateHourlyForecast]
                                     ]];
        }]
        // 6将信号传递给主线程上的观察者。
        deliverOn:RACScheduler.mainThreadScheduler]
        // 7这不是很好的做法，在你的模型中进行UI交互，但出于演示的目的，每当发生错误时，会显示一个banner。
        subscribeError:^(NSError *error) {
            [TSMessage showNotificationWithTitle:@"Error"
                                        subtitle:@"There was a problem fetching the latest weather."
                                            type:TSMessageNotificationTypeError];
        }];
        }
    return self;
}


- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    //判断定位操作是否被允许
    // 4.启动请求
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 1忽略第一个位置更新，因为它一般是缓存值。
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    // 2一旦你获得一定精度的位置，停止进一步的更新。
    if (location.horizontalAccuracy > 0) {
        // 3设置currentLocation，将触发您之前在init中设置的RACObservable。
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}




- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        NSLog(@"%@",condition);
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
        NSLog(@"%@",conditions);
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
        NSLog(@"%@",conditions);
    }];
}





@end

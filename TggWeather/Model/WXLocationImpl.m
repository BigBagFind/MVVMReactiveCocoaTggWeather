//
//  WXLocationImpl.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXLocationImpl.h"

@interface WXLocationImpl ()<CLLocationManagerDelegate>

// 为查找定位和数据抓取声明一些私有变量。
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, assign) BOOL isFirstUpdate;

@property (nonatomic, strong, readwrite) CLLocation *currentLocation;


@end

@implementation WXLocationImpl


- (instancetype)init {
    self = [super init];
    if (self) {
        // 创建一个位置管理器，并设置它的delegate为self。
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
            NSLog(@"打开隐私->定位->谢谢");
        }
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





@end

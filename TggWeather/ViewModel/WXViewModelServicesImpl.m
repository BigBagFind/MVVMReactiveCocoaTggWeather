//
//  WXViewModelServicesImpl.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXViewModelServicesImpl.h"
#import "WXWeahtherImpl.h"

@interface WXViewModelServicesImpl ()

/** 为ViewModel挂上具体实现的model */
@property (strong, nonatomic) WXWeahtherImpl *weatherService;



@end


@implementation WXViewModelServicesImpl


- (instancetype)init {
    self = [super init];
    if (self) {
        _weatherService = [WXWeahtherImpl new];
        NSLog(@"%@",_weatherService);
    }
    return self;
}

// 获取到具体实现的model,这里即是weatherService
- (id<WXWeather>)getWeatherService {
    NSLog(@"getWeatherService");
    return self.weatherService;
}






@end



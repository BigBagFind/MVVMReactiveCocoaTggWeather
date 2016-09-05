//
//  WXViewModel.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/4.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXViewModel.h"
#import "WXManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation WXViewModel


- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)initialize {
    // 开始定位
    [[WXManager sharedManager] findCurrentLocation];
    
    // 1观察WXManager单例的currentCondition。
    [RACObserve([WXManager sharedManager], currentCondition) subscribeNext:^(WXCondition *newCondition) {
         // 3使用气象数据更新文本标签；你为文本标签使用newCondition的数据，而不是单例。订阅者的参数保证是最新值
         self.temperature = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         self.condition = [newCondition.condition capitalizedString];
         self.city = [newCondition.locationName capitalizedString];
         // 4使用映射的图像文件名来创建一个图像，并将其设置为视图的图标
         self.iconName = [newCondition imageName];
     }];
    
     // 1RAC（…）宏有助于保持语法整洁。从该信号的返回值将被分配给hiloLabel对象的text。
    [[RACSignal combineLatest:
     // 2观察currentCondition的高温和低温。合并信号，并使用两者最新的值。当任一数据变化时，信号就会触发。
     @[RACObserve([WXManager sharedManager], currentCondition.tempHigh),
        RACObserve([WXManager sharedManager], currentCondition.tempLow)]
     // 3从合并的信号中，减少数值，转换成一个单一的数据，注意参数的顺序与信号的顺序相匹配。
     reduce:^(NSNumber *hi, NSNumber *low) {
         return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
     }]
     subscribeNext:^(NSString *text) {
         self.hilo = text;
     }];
    
    // 观察array属性
    RAC(self,hourlyForecasts) = RACObserve([WXManager sharedManager], hourlyForecast);
    RAC(self,dailyForecasts) = RACObserve([WXManager sharedManager], dailyForecast);
}




@end

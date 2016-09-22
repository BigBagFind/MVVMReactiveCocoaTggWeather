//
//  WXViewModel.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/4.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXViewModelServices.h"
#import "WXCondition.h"

@interface WXViewModel : NSObject

/** 当前温度 */
@property (nonatomic, copy) NSString *temperature;

/** 当前天气状况，如cloud */
@property (nonatomic, copy) NSString *condition;

/** 当前城市名 */
@property (nonatomic, copy) NSString *city;

/** 图片名称 */
@property (nonatomic, copy) NSString *iconName;

/** 最高和最低气温 */
@property (nonatomic, copy) NSString *hilo;



// 这些属性将存储您的数据，这些属性可以任意访问。设置公共属性为只读，因为只有管理者能更改这些值。
@property (nonatomic, strong, readonly) WXCondition *currentCondition;

/** 每日预测数据 */
@property (nonatomic, strong, readonly) NSArray *dailyForecasts;

/** 每时预测数据 */
@property (nonatomic, strong, readonly) NSArray *hourlyForecasts;

/** 获取数据信号 */
@property (nonatomic, strong) RACSignal *fetchDataSignal;





// ViewModel，初始化带一个指向WXViewModelServices协议的对象
- (instancetype)initWithServices:(id<WXViewModelServices>)services;



- (NSString *)dailyStrWith:(WXCondition *)weather;


- (NSString *)hourlyStrWith:(WXCondition *)weather;







@end

//
//  WXViewModel.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/4.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>

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

/** 每日预测数据 */
@property (nonatomic, strong) NSArray *dailyForecasts;

/** 每时预测数据 */
@property (nonatomic, strong) NSArray *hourlyForecasts;


@end

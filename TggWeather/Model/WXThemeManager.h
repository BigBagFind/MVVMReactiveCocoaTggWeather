//
//  WXThemeManager.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/22.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXThemeModel.h"


@protocol WXThemeProcotol<NSObject>


/** 执行改变天气单位 */
- (void)executeChangeWeatherUnit;



@end



@interface WXThemeManager : NSObject


/** 持有一个主题模型 */
@property (nonatomic, strong) WXThemeModel *themeModel;


/** 单例 */
+ (instancetype)shareThemeManager;


/** 发送更改单位通知 */
- (void)postWeatherUnitChangeNotification:(NSObject *)object;







@end

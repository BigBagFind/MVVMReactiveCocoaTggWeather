//
//  WXLocationImpl.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface WXLocationImpl : NSObject


// 这些属性将存储您的数据。由于WXManager是一个单例，这些属性可以任意访问。设置公共属性为只读，因为只有管理者能更改这些值。
@property (nonatomic, strong, readonly) CLLocation *currentLocation;


// 这个方法启动或刷新整个位置和天气的查找过程。
- (void)findCurrentLocation;



@end

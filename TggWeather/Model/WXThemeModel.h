//
//  ThemeModel.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/23.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface WXThemeModel : NSObject




@property (nonatomic, copy) NSString *unit;



- (void)saveWeatherUnit:(NSObject *)object;


- (void)getWeatherUnit ;




@end

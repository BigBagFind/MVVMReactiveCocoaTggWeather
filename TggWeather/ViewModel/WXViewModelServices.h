//
//  WXViewModelServices.h
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXWeather.h"

@protocol WXViewModelServices <NSObject>



- (id<WXWeather>)getWeatherService;




@end
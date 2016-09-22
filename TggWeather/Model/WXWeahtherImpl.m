//
//  WXWeahtherImpl.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/10.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "WXWeahtherImpl.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXWeahtherImpl ()


@property (nonatomic, strong) NSURLSession *session;


@end



@implementation WXWeahtherImpl

/** 重写初始化 */
- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

/**
 *  获取当前天气的网络请求
 *
 *  @param coordinate CLlocation的经纬度
 *
 *  @return 返回的是一个带condition模型的信号
 */
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    // 1使用CLLocationCoordinate2D对象的经纬度数据来格式化URL。
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial&APPID=aaa75dead2f8a91d8d7c5b03ee1c4e04",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2用你刚刚建立的创建信号的方法。由于返回值是一个信号，你可以调用其他ReactiveCocoa的方法。 在这里，您将返回值映射到一个不同的值 – 一个NSDictionary实例。
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        NSLog(@"CurrentConditions：\n%@",json);
        // 3 Json字典转换model，需要执行MTLJSONSerializing
        WXCondition *condition = [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
        return condition;
    }];
}



/**
 *  获取小时预报
 *
 *  @param coordinate 经纬度
 *
 *  @return 返回一个带模型数组的信号
 */
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12&APPID=aaa75dead2f8a91d8d7c5b03ee1c4e04",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1再次使用-fetchJSONFromUR方法，映射JSON。注意：重复使用该方法节省了多少代码！
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        NSLog(@"HourlyForecast：\n%@",json);
        // 2使用JSON的”list”key创建RACSequence。 RACSequences让你对列表进行ReactiveCocoa操作
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // 3映射新的对象列表。调用-map：方法，针对列表中的每个对象，返回新对象的列表。
        return [[list map:^(NSDictionary *item) {
    
            // 4再次使用MTLJSONAdapter来转换JSON到WXCondition对象。
            WXCondition *condition = [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            return condition;
            // 5使用RACSequence的-map方法，返回另一个RACSequence，所以用这个简便的方法来获得一个NSArray数据。
        }] array];
    }];
}


/**
 *  获取每天预报
 *
 *  @param coordinate 经纬度
 *
 *  @return 返回一个带模型数组的信号
 */
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7&APPID=aaa75dead2f8a91d8d7c5b03ee1c4e04",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        NSLog(@"DailyForecast：%@",json);
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            NSLog(@"%@",item);
            WXDailyForecast *forecast = [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
            return forecast;
        }] array];
    }];
    
}



/**
 *  基础网络请求
 *
 *  @param url get的url
 *
 *  @return 信号
 */
- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    // 1返回信号。请记住，这将不会执行，直到这个信号被订阅。 - fetchJSONFromURL：创建一个对象给其他方法和对象使用；这种行为有时也被称为工厂模式。
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 2创建一个NSURLSessionDataTask（在iOS7中加入）从URL取数据。你会在以后添加的数据解析。
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    // 3当JSON数据存在并且没有错误，发送给订阅者序列化后的JSON数组或字典。
                    [subscriber sendNext:json];
                } else {
                    // 4在任一情况下如果有一个错误，通知订阅者。
                    [subscriber sendError:jsonError];
                }
            } else {
                // 5
                [subscriber sendError:error];
            }
            
            // 6无论该请求成功还是失败，通知订阅者请求已经完成。
            [subscriber sendCompleted];
        }];
        // 7一旦订阅了信号，启动网络请求。
        [dataTask resume];
        
        // 8创建并返回RACDisposable对象，它处理当信号摧毁时的清理工作。
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        // 9增加了一个“side effect”，以记录发生的任何错误。side effect不订阅信号，相反，他们返回被连接到方法链的信号。你只需添加一个side effect来记录错误。
        NSLog(@"%@",error);
    }];
}

@end

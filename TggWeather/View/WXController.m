//
//  WXController.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/8/31.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <TSMessages/TSMessage.h>
#import "WXController.h"
#import "RACEXTScope.h"
#import "WXThemeManager.h"

@interface WXController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>


/** viewModel */
@property (nonatomic, strong) WXViewModel *viewModel;

/** 背景图 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

/** 毛玻璃 */
@property (nonatomic, strong) UIImageView *blurredImageView;

/** 切换温度单位 */
@property (nonatomic, strong) UISegmentedControl *segControl;

/** 天气列表 */
@property (nonatomic, strong) UITableView *tableView;

/** 温度 */
@property (nonatomic, strong) UILabel *temperatureLabel;

/** 高低温度 */
@property (nonatomic, strong) UILabel *hiloLabel;

/** 城市 */
@property (nonatomic, strong) UILabel *cityLabel;

/** 当前天气描述 */
@property (nonatomic, strong) UILabel *conditionsLabel;

/** 当前天气描述图 */
@property (nonatomic, strong) UIImageView *iconView;


/** 拿到全屏高度 */
@property (nonatomic, assign) CGFloat screenHeight;

/** 滑动手势 */
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGes;


@end



@implementation WXController


- (instancetype)initWithViewModel:(WXViewModel *)viewModel {
    self = [super init];
    if (self) {
        // 拿到初始化的ViewModel
        self.viewModel = viewModel;
    }
    return self;
}



#pragma mark - LifeCycle

- (void)dealloc {
    [WXNotification removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareBasicViews];
    [self prepareMainViews];
    [self bindViewModel];
    
    // 添加变化手势
    @weakify(self);
    self.swipeGes = [[UISwipeGestureRecognizer alloc] init];
    self.swipeGes.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:self.swipeGes];
    [[[self.swipeGes rac_gestureSignal]
      flattenMap:^RACStream *(id value) {
          return self.viewModel.executeRandomSignal;
      }]
     subscribeNext:^(UIImage *image) {
         @strongify(self);
         [UIView transitionWithView:self.backgroundImageView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
             self.backgroundImageView.image = image;
             [self.blurredImageView setImageToBlur:image completionBlock:nil];
         } completion:nil];
     }];

}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)prepareBasicViews {
    
    UIImage *background = [UIImage imageNamed:[WXUserDefaults objectForKey:WXBackgroundImage]];
    
    // 2
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 3 毛玻璃视图，为imageView设置毛玻璃
    // 当alpha > 0,用来挡住下面的imageView
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // 4
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

- (void)prepareMainViews {
    // 1
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // 1
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    // 2
    CGFloat inset = 20;
    // 3
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    // 4
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    // 5
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // 1
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // 2
    // bottom left
    self.temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    self.temperatureLabel.backgroundColor = [UIColor clearColor];
    self.temperatureLabel.textColor = [UIColor whiteColor];
    self.temperatureLabel.text = @"0°";
    self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:self.temperatureLabel];
    
    // bottom left
    self.hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    self.hiloLabel.backgroundColor = [UIColor clearColor];
    self.hiloLabel.textColor = [UIColor whiteColor];
    self.hiloLabel.text = @"0° / 0°";
    self.hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:self.hiloLabel];
    
    // top
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    self.cityLabel.backgroundColor = [UIColor clearColor];
    self.cityLabel.textColor = [UIColor whiteColor];
    self.cityLabel.text = @"Loading...";
    self.cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.cityLabel];
    
    self.conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    self.conditionsLabel.backgroundColor = [UIColor clearColor];
    self.conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:self.conditionsLabel];
    
    // 3
    // bottom left
    self.iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:self.iconView];
    
    // 新增segControl
    NSArray *items = @[@"°F",@"°C"];
    self.segControl = [[UISegmentedControl alloc] initWithItems:items];
    self.segControl.frame = CGRectMake(self.view.frame.size.width - 88, 20, 80, 35);
    [self.view addSubview:self.segControl];
    self.segControl.tintColor = [UIColor whiteColor];
    NSNumber *unit = [WXUserDefaults objectForKey:WXWeatherUnit];
    self.segControl.selectedSegmentIndex = [unit integerValue];
}

#pragma mark - 捆绑ViewModel

- (void)bindViewModel {
    /*************** PageOne--->TableHeader ******************/
    // 忽略初始化的－17.8
    // 过滤没有数据的情况null
    // 改变字体大小
    @weakify(self);
    [[[[RACObserve(self.viewModel, temperature) deliverOnMainThread] ignore:@"-17.8"]
       filter:^BOOL(NSString *value) {
         return value.length > 0;
       }]
       subscribeNext:^(NSString *temp) {
           @strongify(self);
           self.temperatureLabel.text = [NSString stringWithFormat:@"%@°",temp];
           if ([[WXThemeManager shareThemeManager].themeModel.unit isEqualToString:@"C"]) {
               self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:100];
           } else {
               self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
           }
       }];
    
    // 最高和最低气温
    RAC(self.hiloLabel, text) = [RACObserve(self.viewModel, hilo) deliverOnMainThread];
    
    // 当前天气状况，如cloud
    RAC(self.conditionsLabel, text) = [RACObserve(self.viewModel, condition) deliverOnMainThread];
    // 当前城市名,过滤没定位到的位置，保持loading
    RAC(self.cityLabel, text) = [[RACObserve(self.viewModel, city)
    filter:^BOOL(NSString *text) {
        NSLog(@"text：%@",text);
        return text && text.length > 0;
    }] deliverOnMainThread];
    // 图片名称，转换到image
    RAC(self.iconView, image) = [[RACObserve(self.viewModel, iconName) map:^id(NSString *iconName) {
        return [UIImage imageNamed:iconName];
    }] deliverOnMainThread];
   
    // 观察合并array且刷新table
    [[[RACSignal combineLatest:
      @[RACObserve(self.viewModel, hourlyForecasts),
        RACObserve(self.viewModel, dailyForecasts)]]
     deliverOnMainThread]
     subscribeNext:^(NSString *text) {
         [self.tableView reloadData];
     }];
    
    // segControl
    [[[self.segControl rac_signalForControlEvents:UIControlEventValueChanged]
       map:^id(UISegmentedControl *control) {
        return @(control.selectedSegmentIndex);
      }] subscribeNext:^(NSNumber *selectedIndex) {
          [[WXThemeManager shareThemeManager] postWeatherUnitChangeNotification:selectedIndex];
      }];
    
    /*************** PageTwo--->Section ******************/
    // 网络错误更新UI
    [[self.viewModel.fetchDataSignal deliverOnMainThread] subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error"
                                     subtitle:@"There was a problem fetching the latest weather."
                                         type:TSMessageNotificationTypeError];
    }];
    
    // 观察array属性
    [[[RACObserve(self.viewModel, hourlyForecasts)
      ignore:nil]
      deliverOn:RACScheduler.mainThreadScheduler]
      subscribeNext:^(NSArray *newForecast) {
        NSLog(@"hourlyForecasts:%@",self.viewModel.hourlyForecasts);
         [self.tableView reloadData];
      }];
    
    // 观察array属性来更新tableView
    [[[RACObserve(self.viewModel, dailyForecasts)
      ignore:nil]
      deliverOn:RACScheduler.mainThreadScheduler]
      subscribeNext:^(NSArray *newForecast) {
          NSLog(@"dailyForecasts:%@",self.viewModel.dailyForecasts);
         [self.tableView reloadData];
      }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO: Return count of forecast
    // 1第一部分是对的逐时预报。使用最近6小时的预预报，并添加了一个作为页眉的单元格。
    if (section == 0) {
        return MIN([self.viewModel.hourlyForecasts count], 8) + 1;
    }
    // 2接下来的部分是每日预报。使用最近6天的每日预报，并添加了一个作为页眉的单元格。
    return MIN([self.viewModel.dailyForecasts count], 7) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // 3
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    // TODO: Setup the cell
    if (indexPath.section == 0) {
        // 1每个部分的第一行是标题单元格。
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        } else {
            // 2获取每小时的天气和使用自定义配置方法配置cell。
            WXCondition *weather = self.viewModel.hourlyForecasts[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    } else if (indexPath.section == 1) {
        // 1
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            // 3获取每天的天气，并使用另一个自定义配置方法配置cell。
            WXCondition *weather = self.viewModel.dailyForecasts[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}


// 1配置和添加文本到作为section页眉单元格。你会重用此为每日每时的预测部分。
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

// 2格式化逐时预报的单元格。
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.viewModel hourlyStrWith:weather];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

// 3格式化每日预报的单元格。
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.viewModel dailyStrWith:weather];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // 3
    self.blurredImageView.alpha = percent;
    
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >= self.view.frame.size.height) {
        self.swipeGes.enabled = NO;
    } else {
        self.swipeGes.enabled = YES;
    }
}


#pragma mark -  StatusBarColor

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end

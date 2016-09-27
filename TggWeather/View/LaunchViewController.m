//
//  LaunchViewController.m
//  TggWeather
//
//  Created by 铁拳科技 on 16/9/27.
//  Copyright © 2016年 铁哥哥. All rights reserved.
//

#import "LaunchViewController.h"




@interface LaunchViewController ()


@property (weak, nonatomic) IBOutlet UILabel *weatherTitle;




@end



@implementation LaunchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateKeyframesWithDuration:0.7 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.2 animations:^{
                self.weatherTitle.transform = CGAffineTransformScale(self.weatherTitle.transform, 0.85, 0.85);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.5 animations:^{
                self.weatherTitle.transform = CGAffineTransformScale(self.weatherTitle.transform, 10, 20);
                self.view.alpha = 0;
            }];
        } completion:^(BOOL finished) {
            self.completionBlock();
        }];
    });
   
    
    
}




@end

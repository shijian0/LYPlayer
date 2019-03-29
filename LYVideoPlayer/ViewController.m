//
//  ViewController.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/18.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "ViewController.h"
#import "LYPlayer.h"
#import "UIView+ReSize.h"
#import "UserData.h"
@interface ViewController ()
@property (nonatomic,strong)LYPlayer * player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[LYPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*9/16)];
    self.player.tempSuperView = self.view;

    NSString * url = @"http://cdn.xnwimg.com/down/f:%7BE74A93DE-60E0-7D7C-155D-165EF8E6428F%7D/test3.mp4";
    url = @"http://cdn.xnwimg.com/down/f:%7BC362B48F-2AA8-6BFC-7FCA-92B14BC1CE83%7D/test2.mp4";
    [self.player setVideoURL:url];
    
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.player.frame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.width, self.view.width*9/16);
    } else {
        // Fallback on earlier versions
    }
}

@end

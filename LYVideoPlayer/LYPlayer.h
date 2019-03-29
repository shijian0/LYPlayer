//
//  LYPlayerView.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/18.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//播放器的几种状态
typedef NS_ENUM(NSInteger, TBPlayerState) {
    TBPlayerStateBuffering = 1,
    TBPlayerStatePlaying   = 2,
    TBPlayerStateStopped   = 3,
    TBPlayerStatePause     = 4
};
@interface LYPlayer : UIView
@property (nonatomic,strong)NSString *videoURL;
@property (nonatomic,strong)UIView *tempSuperView;
@property (nonatomic,assign)TBPlayerState playerStatus;

@end

NS_ASSUME_NONNULL_END

//
//  LYPlayerView.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/18.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "LYPlayerMaskView.h"
#import "LYLoaderURLConnection.h"
#import "NSTimer+WeakTimer.h"
@interface LYPlayer()<LYLoaderURLConncetionDelegate,LYPlayerMaskViewDelegate>
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem *playerItem;
@property (nonatomic,strong)LYPlayerMaskView *playerMaskView;
@property (nonatomic,strong)AVPlayerLayer *playerLayer;
@property (nonatomic,strong)AVURLAsset *urlAsset;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)LYLoaderURLConnection *loader;
//总时长
@property (nonatomic,assign)CGFloat duration;

@end

@implementation LYPlayer

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"classclassclass:%@",keyPath);
    AVPlayerItem * playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//        NSLog(@"loadedTimeRanges");
        [self calculateDownloadProgress:self.playerItem];
    }else if ([keyPath isEqualToString:@"status"]){
        if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"status:%ld",(long)self.playerItem.status);
            self.duration = self.playerItem.duration.value / self.playerItem.duration.timescale; //视频总时间
            [self updateTotalTime:self.duration];
            [self setSliderValue:self.duration];
            if (self.timer == nil) {
                __weak __typeof(self) weakSelf = self;
                self.timer = [NSTimer LY_scheduleWeakTimer:1.0 repeats:YES block:^{
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    CGFloat current = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;
                    [strongSelf updateCurrentTime:current];
                    [strongSelf updateSliderValue:current];
                }];
            }
            [self.player play];
//            [self seekToTime:0];

        }else if (self.playerItem.status == AVPlayerStatusFailed){
            NSLog(@"AVPlayerStatusFailed:%@",[self.playerItem.error description]);
        }
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"loading22222");
//        self.loader.task.isLoading = YES;
        if (self.playerItem.isPlaybackBufferEmpty) {
            [self.playerMaskView hideIndicatorView:NO];

        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        NSLog(@"loading111111");
//        self.loader.task.isLoading = NO;

        if (self.playerItem.isPlaybackLikelyToKeepUp) {
            [self.playerMaskView hideIndicatorView:YES];

        }
    }
}

- (void)monitoring:(AVPlayerItem*)playerItem{

    __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
    }];
}
- (void)updateCurrentTime:(CGFloat)duration{
    [self.playerMaskView setCurrentTimeString:[self getTimeString:duration]];
}
- (NSString *)getTimeString:(CGFloat)duration{
    long videoLenght = ceil(duration);
    NSString * totalTimeString = nil;
    if (videoLenght < 3600) {
        totalTimeString = [NSString stringWithFormat:@"%02li:%02li",lround(floor(videoLenght/60.0f)),lround(floor(videoLenght/1.f))%60];
    }else{
        totalTimeString = [NSString stringWithFormat:@"%02lif:%02li:%02li",lround(floor(videoLenght/3600.f)),lround(floor(videoLenght%3600)/60.f),lround(floor(videoLenght/1.f))%60];
    }
    return totalTimeString;
}
- (void)updateTotalTime:(CGFloat)duration{
    [self.playerMaskView setTotalTimeString:[self getTimeString:duration]];
}
- (void)setSliderValue:(CGFloat)duration{
    [self.playerMaskView setSliderValue:duration];
}
- (void)seekToTime:(CGFloat)seconds{
    [self.player pause];
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, self.duration);
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}
- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem{
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
//    self.loadedProgress = timeInterval / totalDuration;
    [self.playerMaskView updateProgressValue:timeInterval/totalDuration];
//    NSLog(@"本次缓冲时间范围:%.2f~%.2f;%.2f:共缓冲：%.2f",startSeconds,durationSeconds,duration,timeInterval);
}
- (void)updateSliderValue:(CGFloat)value{
//    NSLog(@"slider:%f",value/self.duration);
    [self.playerMaskView updateSliderValue:value]; //当前进度
}
#pragma -mark maskView delegate
- (void)LYPlayerMaskViewDelegate_sliderBeginChange:(LYPlayerMaskView *)view slider:(UISlider *)slider{
//    NSLog(@"slider begin");
    [self updateCurrentTime:slider.value];
}
- (void)LYPlayerMaskViewDelegate_sliderBeginChangeEnd:(LYPlayerMaskView *)view slider:(UISlider *)slider{
//    NSLog(@"slider end");
    [self seekToTime:slider.value];
    [self updateCurrentTime:slider.value];
}
- (void)LYPlayerMaskViewDelegate_play:(LYPlayerMaskView *)view button:(UIButton *)sender{
    if (sender.tag == PLAYERBUTTONSTATUS_Play) {
        [self.playerMaskView setPlayButtonTitle:@"播放"];
        self.playerMaskView.playButton.tag = PLAYERBUTTONSTATUS_Pause;
        [self.player pause];
    }else if (sender.tag == PLAYERBUTTONSTATUS_Pause){
        [self.playerMaskView setPlayButtonTitle:@"暂停"];
        self.playerMaskView.playButton.tag = PLAYERBUTTONSTATUS_Play;
        [self.player play];
    }else if (sender.tag == PLAYERBUTTONSTATUS_rePlay){
        [self.playerMaskView setPlayButtonTitle:@"暂停"];
        self.playerMaskView.playButton.tag = PLAYERBUTTONSTATUS_Play;
        [self seekToTime:0];
    }
}

- (void)setVideoURL:(NSString *)videoURL{
    //每次都先移出监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    //
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRange"];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
//    第一次才添加
    if (self.superview == nil) {
        [self.tempSuperView addSubview:self];
    }
    //第一次才创建
    [self addSubview:self.playerMaskView];
    self.playerMaskView.frame = self.bounds;
        
    //
    if (![videoURL hasPrefix:@"http"]) {
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoURL]];
    }else{
        //缓存添加
        self.loader = [[LYLoaderURLConnection alloc]init];
        self.loader.delegate = self;
    
        NSURL *playUrl = [self.loader getSchemeVideoURL:[NSURL URLWithString:videoURL]];

        AVURLAsset* urlAsset = [AVURLAsset URLAssetWithURL:playUrl options:nil];
        [urlAsset.resourceLoader setDelegate:self.loader queue:dispatch_get_main_queue()];
        self.playerItem = nil;
        [self.player pause];
        self.player = nil;
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
//        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoURL]];

    }
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    [self setNeedsLayout];//需手动调一下layoutSubviews

    //设置
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.shouldRasterize = YES;
    self.playerLayer.rasterizationScale = [UIScreen mainScreen].scale;

    [self.player setRate:1];

    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stall:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    
}
- (void)moviePlayDidEnd:(NSNotification *)noti{
    NSLog(@"moviePlayDidEnd");
    [self.playerMaskView setPlayButtonTitle:@"重播"];
    self.playerMaskView.playButton.tag = PLAYERBUTTONSTATUS_rePlay;
}
- (void)stall:(NSNotification *)noti{
    NSLog(@"%s", __func__);
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.maskView.frame = self.bounds;
}

- (LYPlayerMaskView *)playerMaskView{
    if (!_playerMaskView) {
        _playerMaskView = [[LYPlayerMaskView alloc]initWithFrame:self.frame];
        _playerMaskView.delegate = self;
    }
    return _playerMaskView;
}
@end

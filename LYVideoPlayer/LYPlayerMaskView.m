//
//  LYPlayerMaskView.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/18.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYPlayerMaskView.h"
#import "UIView+ReSize.h"
#import "NSTimer+WeakTimer.h"
#import "LYCirclePointActivityIndicator.h"
@interface LYPlayerMaskView()
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *fullButton;
@property (strong, nonatomic) UILabel *speedLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL operationIsHide;
@property (strong, nonatomic) LYCirclePointActivityIndicator *indicatorView;

@end

@implementation LYPlayerMaskView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.progressView];
        [self addSubview:self.slider];
        [self addSubview:self.playButton];
        [self addSubview:self.currentTimeLabel];
        [self addSubview:self.totalTimeLabel];
        [self addSubview:self.indicatorView];
        self.operationIsHide = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
//        [self addSubview:self.closeButton];
//        [self addSubview:self.fullButton];
//        [self addSubview:self.speedLabel];
        [self tap:nil];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return self;
}
- (void)dealloc{
    NSLog(@"dalloc");
}
- (void)tap:(UIGestureRecognizer*)tap{
    self.operationIsHide = !self.operationIsHide;

    [self autoHideTimer];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    __weak __typeof(self) weakSelf = self;
    self.timer = [NSTimer LY_scheduleWeakTimer:5 repeats:YES block:^{
        [weakSelf.timer invalidate];
        weakSelf.timer = nil;
        weakSelf.operationIsHide = YES;
        [weakSelf autoHideTimer];
    }];
}
- (void)autoHideTimer{
    self.slider.hidden = self.operationIsHide;
    self.progressView.hidden = self.operationIsHide;
    self.playButton.hidden = self.operationIsHide;
    self.currentTimeLabel.hidden = self.operationIsHide;
    self.totalTimeLabel.hidden = self.operationIsHide;
}
- (void)hideIndicatorView:(BOOL)hide{
    self.indicatorView.hidden= hide;
}
- (void)updateProgressValue:(CGFloat)value{
    [self.progressView setProgress:value];
}
- (void)updateSliderValue:(CGFloat)value{
     self.slider.value = value;
}
- (void)setSliderValue:(CGFloat)value{
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = (NSInteger)value;
}
- (void)setCurrentTimeString:(NSString*)currentTime{
    self.currentTimeLabel.text = currentTime;
}
- (void)setTotalTimeString:(NSString*)totalTime{
    self.totalTimeLabel.text = [NSString stringWithFormat:@"/ %@",totalTime];
}
- (void)setPlayButtonTitle:(NSString*)title{
    [self.playButton setTitle:title forState:UIControlStateNormal];
}
//slider action
- (void)sliderChange:(UISlider*)slider{
    if ([self.delegate respondsToSelector:@selector(LYPlayerMaskViewDelegate_sliderBeginChange:slider:)]) {
        [self.delegate LYPlayerMaskViewDelegate_sliderBeginChange:self slider:slider];
    }
}
- (void)changePlayStatus{
    self.playButton.selected = !self.playButton.selected;
}
- (void)play{
    if ([self.delegate respondsToSelector:@selector(LYPlayerMaskViewDelegate_play:button:)]) {
        [self.delegate LYPlayerMaskViewDelegate_play:self button:self.playButton];
    }
}
- (void)full:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(LYPlayerMaskViewDelegate_play:button:)]) {
        [self.delegate LYPlayerMaskViewDelegate_play:self button:sender];
    }
}
- (void)close:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(LYPlayerMaskViewDelegate_play:button:)]) {
        [self.delegate LYPlayerMaskViewDelegate_play:self button:sender];
    }
}
- (void)sliderChangeEnd:(UISlider*)slider{
    if ([self.delegate respondsToSelector:@selector(LYPlayerMaskViewDelegate_sliderBeginChangeEnd:slider:)]) {
        [self.delegate LYPlayerMaskViewDelegate_sliderBeginChangeEnd:self slider:slider];
    }
}
#pragma -mark layoutSubviews
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat mar = 10,width = 30;
    
    self.playButton.frame = CGRectMake(0, 0, width, width);
    self.playButton.center = CGPointMake(self.width/2, self.height/2);
    
    [self.totalTimeLabel sizeToFit];
    self.totalTimeLabel.frame = CGRectMake(0, 0, self.totalTimeLabel.width, self.totalTimeLabel.height);
    self.totalTimeLabel.right = self.right-mar;
    self.totalTimeLabel.bottom = self.bottom-mar;
    
    [self.currentTimeLabel sizeToFit];
    self.currentTimeLabel.frame = CGRectMake(0, 0, self.currentTimeLabel.width, self.currentTimeLabel.height);
    self.currentTimeLabel.right = self.totalTimeLabel.left;
    self.currentTimeLabel.bottom = self.bottom-mar;
    
    self.slider.frame = CGRectMake(mar-2, self.height-2*mar, self.width-3*mar-self.totalTimeLabel.width-self.currentTimeLabel.width+4, mar);
    self.progressView.frame = CGRectMake(mar, self.height-2*mar, self.width-3*mar-self.totalTimeLabel.width-self.currentTimeLabel.width, mar);
    
    self.progressView.center = self.slider.center;
    
    self.closeButton.frame = CGRectMake(0, mar, width, width);
    self.closeButton.right = self.right-mar;
    
    self.fullButton.frame = CGRectMake(0, mar, width, width);
    self.fullButton.bottom = self.bottom-mar;
    self.fullButton.right = self.right-mar;
    
    self.indicatorView.center = self.center;
}
#pragma -mark getter
- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]initWithFrame:CGRectZero];
        [_slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
        [_slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _slider;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectZero];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}
- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setTitle:@"暂停" forState:UIControlStateNormal];
        [_playButton setTitle:@"播放" forState:UIControlStateSelected];
        _playButton.tag = PLAYERBUTTONSTATUS_Play;
        _playButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _playButton;
}

- (UILabel *)currentTimeLabel{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [UILabel new];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.0];
        _currentTimeLabel.textColor = [UIColor redColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.text = @" 00:00";
    }
    return _currentTimeLabel;
}
- (UILabel *)totalTimeLabel{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [UILabel new];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0];
        _totalTimeLabel.textColor = [UIColor redColor];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = @" / 00:00";
    }
    return _totalTimeLabel;
}
- (UIButton *)fullButton{
    if (!_fullButton) {
        _fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullButton setTitle:@"全屏" forState:UIControlStateNormal];
        _fullButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [_fullButton addTarget:self action:@selector(full:) forControlEvents:UIControlEventTouchUpInside];
        [_fullButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _fullButton;
}
- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14.];
        [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _closeButton;
}
- (LYCirclePointActivityIndicator *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[LYCirclePointActivityIndicator alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}
@end

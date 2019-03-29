//
//  LYPlayerMaskView.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/18.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LYPlayerMaskView;

typedef NS_ENUM(NSInteger,PLAYERBUTTONSTATUS) {
    PLAYERBUTTONSTATUS_Play,
    PLAYERBUTTONSTATUS_Pause,
    PLAYERBUTTONSTATUS_rePlay
};

@protocol LYPlayerMaskViewDelegate <NSObject>
- (void)LYPlayerMaskViewDelegate_play:(LYPlayerMaskView *)view button:(UIButton *)sender;
- (void)LYPlayerMaskViewDelegate_sliderBeginChange:(LYPlayerMaskView *)view slider:(UISlider *)slider;//开始拖动
- (void)LYPlayerMaskViewDelegate_sliderBeginChangeEnd:(LYPlayerMaskView *)view slider:(UISlider *)slider;//拖动结束

@end

@interface LYPlayerMaskView : UIView
@property (nonatomic,assign)id<LYPlayerMaskViewDelegate> delegate;
@property (strong, nonatomic) UIButton *playButton;

- (void)setCurrentTimeString:(NSString*)currentTime;
- (void)setTotalTimeString:(NSString*)totalTime;
- (void)setSliderValue:(CGFloat)value;
- (void)updateSliderValue:(CGFloat)value;
- (void)updateProgressValue:(CGFloat)value;
- (void)changePlayStatus;
- (void)setPlayButtonTitle:(NSString*)title;
- (void)play;
- (void)hideIndicatorView:(BOOL)hide;
@end

NS_ASSUME_NONNULL_END

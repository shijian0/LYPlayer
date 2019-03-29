//
//  NSTimer+WeakTimer.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/28.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "NSTimer+WeakTimer.h"

@implementation NSTimer (WeakTimer)
+ (void)LY_block:(NSTimer*)timer{
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
+ (NSTimer*)LY_scheduleWeakTimer:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(void))block{
  return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(LY_block:) userInfo:[block copy] repeats:repeats];
}
@end

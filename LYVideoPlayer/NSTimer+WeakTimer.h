//
//  NSTimer+WeakTimer.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/28.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (WeakTimer)
+ (NSTimer*)LY_scheduleWeakTimer:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END

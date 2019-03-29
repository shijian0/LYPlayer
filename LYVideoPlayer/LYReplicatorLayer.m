//
//  LYReplicatorLayer.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/29.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYReplicatorLayer.h"

@implementation LYReplicatorLayer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor yellowColor];
        CGFloat width = 4;
        CAShapeLayer * shapeLayer = [CAShapeLayer new];
        shapeLayer.backgroundColor = [UIColor redColor].CGColor;
        shapeLayer.bounds = CGRectMake(0, 0, width, width);
        shapeLayer.cornerRadius = width/2;
        shapeLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        ani.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(10, 10, 1)];
        ani.duration = 2;
        
        CABasicAnimation * ani2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        ani2.fromValue = @1;
        ani2.toValue = @0;
        ani2.duration = 2;
        
        CAAnimationGroup * group = [CAAnimationGroup animation];
        group.animations = @[ani,ani2];
        group.duration = 2;
        group.repeatCount = HUGE;
        [shapeLayer addAnimation:group forKey:nil];
        
        CAReplicatorLayer * replayer = [CAReplicatorLayer layer];
        [replayer addSublayer:shapeLayer];
        replayer.instanceCount = 3;
        replayer.instanceDelay = 0.5;
        [self.layer addSublayer:replayer];
    }
    return self;
}

@end

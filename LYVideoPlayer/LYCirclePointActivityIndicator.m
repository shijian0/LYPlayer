//
//  LYCirclePointActivityIndicator.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/28.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYCirclePointActivityIndicator.h"
#define COLOR_H(Value16) [UIColor colorWithRed:((float)((Value16 & 0xFF0000) >> 16))/255.0 green:((float)((Value16 & 0xFF00) >> 8))/255.0 blue:((float)(Value16 & 0xFF))/255.0 alpha:1.0]

@implementation LYCirclePointActivityIndicator
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.backgroundColor = [UIColor whiteColor].CGColor;
        CGFloat width = 5;
        shapeLayer.bounds = CGRectMake(0, 0, width, width);
        shapeLayer.position = CGPointMake(frame.size.width/2, 0);
        shapeLayer.borderColor = [UIColor whiteColor].CGColor;
        shapeLayer.cornerRadius = width/2;
        shapeLayer.borderWidth = 1;
        shapeLayer.transform = CATransform3DMakeScale(.0, .0, .0);


        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform"];
        ani.duration = 1;
        ani.repeatCount = HUGE;
        ani.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
        ani.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.1, .1, .1)];
        [shapeLayer addAnimation:ani forKey:nil];

        CAReplicatorLayer *repLayer = [CAReplicatorLayer layer];
        repLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        CGFloat count = 8;
        [repLayer addSublayer:shapeLayer];
        repLayer.instanceCount = count;
        repLayer.instanceDelay = 1.0/count;
        repLayer.instanceTransform = CATransform3DMakeRotation(M_PI*2/count, 0, 0, 1);
        repLayer.instanceAlphaOffset = -0.05;
        [self.layer addSublayer:repLayer];
    }
    return self;
}
@end

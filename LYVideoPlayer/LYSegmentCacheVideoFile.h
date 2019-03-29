//
//  LYSegmentCacheVideoFile.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/14.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYSegmentCacheVideoFile : NSObject
@property (nonatomic, assign, readonly) NSUInteger   length;
@property (nonatomic, copy, readonly) NSString* mimeType;
@property (nonatomic, copy, readonly) NSURL* URL;

- (LYSegmentCacheVideoFile*)initWithUrl:(NSURL*)url;

- (void)setLength:(NSUInteger)length mimeType:(NSString*)mimeType;
- (BOOL)writeData:(NSData*)data offset:(NSUInteger)offset;
- (void)writeMeta;
- (NSData*)dataWithRange:(NSRange)range;
@end

NS_ASSUME_NONNULL_END

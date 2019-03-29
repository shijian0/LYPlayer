//
//  LYPlayerVidoeRequestTask.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LYVideoRequestTask;

@protocol LYVideoRequestTaskDelegate <NSObject>

- (void)LYVideoRequestTaskDelegateDidReceiveResponse:(LYVideoRequestTask *)task videoLenght:(NSUInteger)videoLength mimeType:(NSString*)mimeType;
- (void)LYVideoRequestTaskDelegateDidReceiveData:(LYVideoRequestTask *)task data:(NSData*)data offset:(NSUInteger)offset;
- (void)LYVideoRequestTaskDelegateDidFinish:(LYVideoRequestTask *)task;
- (void)LYVideoRequestTaskDelegateDidfaild:(LYVideoRequestTask *)task error:(NSError*)error;
@end

@interface LYVideoRequestTask : NSObject
@property (nonatomic,strong)NSURL                                   *url;
@property (nonatomic,assign)NSUInteger                               offset;
@property (nonatomic,assign)NSUInteger                               videoLength;
@property (nonatomic,assign)NSUInteger                               downLoadingOffset;
@property (nonatomic,strong)NSString                                *mimeType;
@property (nonatomic,assign)BOOL                                     isLoading;
@property (nonatomic,assign)NSUInteger                                  loadTime;

@property (nonatomic,assign)id<LYVideoRequestTaskDelegate>    delegate;

- (void)setUrl:(NSURL * _Nonnull)url withOffset:(NSUInteger)offset len:(NSUInteger)len;
- (void)cancel;
- (void)continueLoading;
- (void)clearData;
@end

NS_ASSUME_NONNULL_END

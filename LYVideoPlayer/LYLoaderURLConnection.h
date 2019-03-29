//
//  LYLoaderURLConnection.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYVideoRequestTask.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LYLoaderURLConncetionDelegate <NSObject>

- (void)LYLoaderURLConnectionDelegateDidFinishLoadingWithTask:(LYVideoRequestTask *)task;
- (void)LYLoaderURLConnectionDelegateDidFailLoadingWithTask:(LYVideoRequestTask *)task error:(NSError *)error;

@end

@interface LYLoaderURLConnection : NSURLConnection<AVAssetResourceLoaderDelegate>
@property (nonatomic,strong)LYVideoRequestTask                  *task;
@property (nonatomic,strong)id<LYLoaderURLConncetionDelegate>    delegate;

- (NSURL *)getSchemeVideoURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END

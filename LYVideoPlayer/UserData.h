//
//  UserData.h
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserData : NSObject
+ (NSString *)getDocumentsPath;
+ (NSString *)getCachePath;
+ (NSString *)getLibraryPath;
+ (BOOL)removeFileWithPath:(NSString*)filePath;
@end

NS_ASSUME_NONNULL_END

//
//  UserData.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/2/22.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "UserData.h"

@implementation UserData
+ (NSString *)getDocumentsPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}
+ (NSString *)getCachePath{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}
+ (NSString *)getLibraryPath{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
}
+ (BOOL)removeFileWithPath:(NSString*)filePath{
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (!success) {
        NSLog(@"%@移除文件失败:%@",[self class],error);
    }
    return success;

}
@end

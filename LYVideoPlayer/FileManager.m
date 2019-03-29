//
//  FileManager.m
//  Sophists
//
//  Created by LiYong on 2018/6/19.
//  Copyright © 2018年 勇 李. All rights reserved.
//

#import "FileManager.h"
#import "JSONKit.h"

@implementation FileManager
+ (instancetype)shareInstance{
    static dispatch_once_t once;
    static FileManager * fileManager;
    dispatch_once(&once, ^{
        fileManager = [self new];
    });
    return fileManager;
}
+ (NSString *)documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
+ (NSString *)getUserdocumentsPath
{
    NSString *cachePath = [self documentsDirectory];
    
//    NSString *userCachePath = [cachePath stringByAppendingPathComponent:[self currentUserGidString]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return cachePath;
}
+ (NSString *)cachePath:(NSString *)fileName
{
    NSString *path = [[self getUserdocumentsPath] stringByAppendingPathComponent:fileName];
    return path;
}
+ (NSMutableArray *)dictArrayFromFile:(NSString *)file mtime:(NSInteger *)mtime
{
    NSString *str = [FileManager readFile:file mtime:mtime];
    NSArray* a = [str mutableObjectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:nil];
    if(![a isKindOfClass:[NSMutableArray class]]) {
        return nil;
    }
    
    __block NSMutableArray *arry = [NSMutableArray array];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
            [arry addObject:dict];
        } else {
            *stop = YES;
            [arry removeAllObjects];
            arry = nil;
        }
    }];
    return arry;
}
// 读取本地JSON文件
+ (id)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
+ (NSString *)readFile:(NSString *)file mtime:(NSInteger *)mtime
{
    if (![file hasPrefix:@"/"]) file = [self cachePath:file];
    
    if (mtime) {
        NSDictionary *d = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
        NSDate *m = [d fileModificationDate];
        NSTimeInterval t = [m timeIntervalSinceNow];
        *mtime = -(NSInteger)t;
    }
    
    NSError *error = nil;
    NSString *cacheString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }
    return cacheString;
}
+ (BOOL)writeData:(id)data toFile:(NSString*)file
{
    if (![file hasPrefix:@"/"]) file = [self cachePath:file];
    
    NSError *error = nil;
    if ([data isKindOfClass:[NSString class]]) {
        [data writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:&error];
    } else if ([data isKindOfClass:[NSArray class]] || [data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSSet class]]) {
        return [data writeToFile:file atomically:NO];
    }
    if (error) {
        NSLog(@"%@缓存失败%@", file, error);
        return FALSE;
    }
    return TRUE;
}
@end

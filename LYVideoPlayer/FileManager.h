//
//  FileManager.h
//  Sophists
//
//  Created by LiYong on 2018/6/19.
//  Copyright © 2018年 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject
+ (instancetype)shareInstance;
+ (NSString *)readFile:(NSString *)file mtime:(NSInteger *)mtime;
+ (BOOL)writeData:(id)data toFile:(NSString*)file;
+ (NSMutableArray *)dictArrayFromFile:(NSString *)file mtime:(NSInteger *)mtime;
// 读取本地JSON文件
+ (id)readLocalFileWithName:(NSString *)name;
@end

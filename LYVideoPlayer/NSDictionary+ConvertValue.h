//
//  NSDictionary+ConvertValue.h
//  xnw
//
//  Created by LiYong on 2019/3/14.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
// NSNumber, NSString, NSArray, NSDictionary
@interface NSDictionary (ConvertValue)
- (BOOL)getBool:(NSString *)key;
- (int)getInt:(NSString *)key;
- (int)getInt:(NSString *)key withDefault:(int)d;
// 用法: key1,key2,...,nil
- (int)getInt2:(NSString *)key, ...;
- (long long)getLongLong:(NSString *)key;
- (NSInteger)getInteger:(NSString *)key;

- (NSString *)getString:(NSString *)key;
- (NSString *)getString:(NSString *)key withDefault:(NSString *)d;
- (NSString *)getStringOrNil:(NSString *)key;

// 用法: key1,key2,...,nil
- (NSString *)getString2:(NSString *)key, ...;

// abc/cde/aaa -> aaa
- (NSString *)leafPartString:(NSString *)key;

- (NSDictionary *)getDict:(NSString *)key;

- (NSArray *)getArry:(NSString *)key;

- (CGFloat)getFloat:(NSString *)key;
- (CGFloat)getFloat:(NSString *)key withDefault:(CGFloat)d;

// 用法: key1,key2,...,nil
- (id)objForKey:(NSString *)key, ...;

- (BOOL)matchValue:(NSString *)value forKeys:(NSString *)key1, ...;


- (NSInteger)incInt:(NSInteger)v forKey:(id<NSCopying>)aKey;
- (NSInteger)decInt:(NSInteger)v forKey:(id<NSCopying>)aKey;
- (void)setInt:(NSInteger)v forKey:(id<NSCopying>)aKey;
- (void)setLongLong:(long long)v forKey:(id<NSCopying>)aKey;
- (void)setObj:(id)anObject forKey:(id<NSCopying>)aKey;

- (id)objectForKeys:(NSArray <NSString *>*)keys;
@end

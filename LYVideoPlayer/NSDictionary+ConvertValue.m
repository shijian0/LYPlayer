//
//  NSDictionary+ConvertValue.h
//  xnw
//
//  Created by LiYong on 2019/3/14.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "NSDictionary+ConvertValue.h"

@implementation NSDictionary (ConvertValue)

- (BOOL)getBool:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return false;
}
- (int)getInt:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(intValue)]) {
        return [value intValue];
    }
    return 0;
}
- (int)getInt2:(NSString *)key, ...
{
    va_list args;
    va_start(args, key);

    int v = 0;
    do {
        if ([self objectForKey:key]) {
            v = [self getInt:key];
            break;
        }

        key = (NSString *)va_arg(args, NSObject *);
    } while (key && [key isKindOfClass:[NSString class]]);

    va_end(args);
    return v;
}
- (int)getInt:(NSString *)key withDefault:(int)d
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(intValue)]) {
        return [value intValue];
    }
    return d;
}
- (NSString *)getString:(NSString *)key
{
    return [self getString:key withDefault:@""];
}
- (NSString *)getString:(NSString *)key withDefault:(NSString *)d
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value respondsToSelector:@selector(stringValue)]) return [value stringValue];
    return d;
}
- (NSString *)leafPartString:(NSString *)key
{
    NSString *name = [self getString:key];
    NSRange r = [name rangeOfString:@"／" options:NSBackwardsSearch];
    if (!r.length) r = [name rangeOfString:@"/" options:NSBackwardsSearch];
    if (r.length) {
        return [name substringFromIndex:r.location + r.length];
    }
    return name;
}

- (NSString *)getStringOrNil:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value respondsToSelector:@selector(stringValue)]) return [value stringValue];
    return nil;
}
- (NSString *)getString2:(NSString *)key, ...
{
    va_list args;
    va_start(args, key);

    id v = nil;
    do {
        v = [self getStringOrNil:(NSString *)key];
        if (v) {
            v = [self getString:key];
            break;
        }

        key = (NSString *)va_arg(args, NSObject *);
    } while (key && [key isKindOfClass:[NSString class]]);

    va_end(args);
    if (!v) v = @"";
    return v;
}

- (NSDictionary *)getDict:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSArray *)getArry:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}


- (NSInteger)getInteger:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}
- (CGFloat)getFloat:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0;
}
- (CGFloat)getFloat:(NSString *)key withDefault:(CGFloat)d
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return d;
}
- (long long)getLongLong:(NSString *)key
{
    id value = [self objectForKey:key];
    if ([value respondsToSelector:@selector(longLongValue)]) {
        return [value longLongValue];
    }
    return [self getInt:key];
}
- (id)objForKey:(id)key, ...
{
    va_list args;
    va_start(args, key);

    id v = nil;
    do {
        v = [self objectForKey:(NSString *)key];
        if (v) break;

        key = va_arg(args, NSObject *);
    } while (key && [key isKindOfClass:[NSString class]]);

    va_end(args);
    return v;
}
- (BOOL)matchValue:(NSString *)value forKeys:(NSString *)key, ...
{
    if (!value.length) return FALSE;

    va_list args;
    va_start(args, key);

    BOOL b = FALSE;
    do {
        NSString *v = [self getString:(NSString *)key];

        if ([v rangeOfString:value options:NSCaseInsensitiveSearch].length) {
            b = TRUE;
            break;
        }
        key = (NSString *)va_arg(args, NSObject *);
    } while (key && [key isKindOfClass:[NSString class]]);

    va_end(args);
    return b;
}
- (void)setObj:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject == nil || aKey == nil) return;
    if (![self isKindOfClass:[NSMutableDictionary class]]) return;
    NSMutableDictionary* d=(NSMutableDictionary*)self;
    [d setObject:anObject forKey:aKey];
}

- (void)setInt:(NSInteger)v forKey:(id<NSCopying>)aKey
{
    if (![self isKindOfClass:[NSMutableDictionary class]]) return;
    NSMutableDictionary* d=(NSMutableDictionary*)self;
    [d setObject:[NSString stringWithFormat:@"%d", (int)v] forKey:aKey];
}

- (void)setLongLong:(long long)v forKey:(id<NSCopying>)aKey
{
    if (![self isKindOfClass:[NSMutableDictionary class]]) return;
    NSMutableDictionary* d=(NSMutableDictionary*)self;
    [d setObject:[NSString stringWithFormat:@"%lld",v] forKey:aKey];
}

- (NSInteger)incInt:(NSInteger)v forKey:(id<NSCopying>)aKey
{
    int n = [self getInt:(NSString *)aKey];
    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        n += v;
        [self setInt:n forKey:aKey];
    }
    return n;
}
- (NSInteger)decInt:(NSInteger)v forKey:(id<NSCopying>)aKey
{
    int n = [self getInt:(NSString *)aKey];
    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        n -= v;
        if (n < 0) n = 0;
        [self setInt:n forKey:aKey];
    }
    return n;
}
- (id)objectForKeys:(NSArray <NSString *>*)keys{
    __block id value = nil;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        value = [self objectForKey:key];
        if (value) {
            *stop = YES;
        }
    }];
    return value;
}
@end

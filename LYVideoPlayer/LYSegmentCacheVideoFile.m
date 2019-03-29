//
//  LYSegmentCacheVideoFile.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/14.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "LYSegmentCacheVideoFile.h"
#import "UserData.h"
#import "NSString+URL.h"
#import "JSONKit.h"
#import "FileManager.h"
#import "NSDictionary+ConvertValue.h"

@interface LYSegmentCacheVideoFile()
@property (nonatomic, copy) NSString *videoPath, *metaPath;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSMutableDictionary *meta;
@property (nonatomic, copy) NSURL* URL;
@property (nonatomic, copy) NSString* mimeType;
@property (nonatomic, assign) NSUInteger length;

@end


@implementation LYSegmentCacheVideoFile
- (LYSegmentCacheVideoFile *)initWithUrl:(NSURL*)url{
    if(self=[super init]) {
        NSString *fileid = [url.absoluteString fileidFromUrl];
        self.metaPath = [[UserData getCachePath] stringByAppendingPathComponent:[fileid stringByAppendingPathExtension:@"meta"]];
        self.videoPath = [[UserData getCachePath] stringByAppendingPathComponent:fileid ];
        NSLog(@"\n\nvideoPath:%@",self.videoPath);

        self.meta = [[FileManager readFile:self.metaPath mtime:nil] mutableObjectFromJSONString];
        if (!self.meta) {
            self.meta = [NSMutableDictionary dictionary];
            [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
        } else {
            self.length = [[self.meta objectForKey:@"length"] integerValue];
            self.mimeType = [self.meta objectForKey:@"mimeType"];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
            [[NSFileManager defaultManager] createFileAtPath:self.videoPath contents:nil attributes:nil];
        }
        self.URL = url;
        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.videoPath];
    }
    return self;
}
- (void)setLength:(NSUInteger)length mimeType:(NSString *)mimeType{
    self.length = length;
    self.mimeType = mimeType;
    
    [self.meta setObject:[NSNumber numberWithLongLong:length] forKey:@"length"];
    [self.meta setObject:mimeType forKey:@"mimeType"];
    NSMutableArray* segments=(NSMutableArray*)[self.meta objectForKey:@"segment"];
    if(!segments) {
        segments=[NSMutableArray array];
        [segments addObject:[self segment_new:0 len:length flag:0]];
        [self.meta setObject:segments forKey:@"segment"];
    }
    [FileManager writeData:[self.meta JSONStringXnw] toFile:self.metaPath];
//    NSLog(@"videoLength: %u, %@", (int)length, mimeType);
}
- (NSMutableDictionary*)segment_new:(NSUInteger)location len:(NSUInteger)len flag:(int)flag{
    NSMutableDictionary* segment=[NSMutableDictionary dictionary];
    [segment setObject:[NSNumber numberWithLongLong:location] forKey:@"loc"];
    [segment setObject:[NSNumber numberWithLongLong:len] forKey:@"len"];
    [segment setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
    return segment;
}
- (NSMutableDictionary*)segment_upd:(NSMutableDictionary*)segment loc:(NSUInteger)location len:(NSUInteger)len flag:(int)flag
{
    [segment setObject:[NSNumber numberWithLongLong:location] forKey:@"loc"];
    [segment setObject:[NSNumber numberWithLongLong:len] forKey:@"len"];
    [segment setObject:[NSNumber numberWithInt:flag] forKey:@"flag"];
    return segment;
}
- (BOOL)writeData:(NSData*)data offset:(NSUInteger)offset{
    @synchronized(self) {
        return [self writeData_locked:data offset:offset];
    }
}
- (BOOL)writeData_locked:(NSData *)data offset:(NSUInteger)offset{
    // write data
    [self.fileHandle seekToFileOffset:offset];
    if(offset != self.fileHandle.offsetInFile) {
        NSLog(@"error seekToFile: %lu", (unsigned long)offset);
    }
    [self.fileHandle writeData:data];
    
    // write segments
    NSMutableArray* segments=(NSMutableArray*)[self.meta getArry:@"segment"];
//    NSLog(@"segments%@",self.meta);
    unsigned long data_left=data.length;
    while(data_left>0)
    {
        BOOL found=NO;
        for(int idx=0; idx<segments.count; ++idx) {
            NSMutableDictionary* seg=[segments objectAtIndex:idx];
            NSUInteger loc=[seg getLongLong:@"loc"];
            NSUInteger len=[seg getLongLong:@"len"];
            int flag=[seg getInt:@"flag"];
            
            // offset in this range
            if(offset>=loc && offset<loc+len) {
                found=YES;
                unsigned long data_len=data_left;
                if(data_len>len-(offset-loc)) {
                    data_len=len-(offset-loc);
                }
                
                if(offset==loc) {
                    // at the head
                    if(data_len==len) {
                        [seg setInt:1 forKey:@"flag"];
                    } else {
                        NSMutableDictionary* seg_new=[self segment_new:loc len:data_len flag:1];
                        [segments insertObject:seg_new atIndex:idx];
                        [self segment_upd:seg loc:loc+=data_len len:len-=data_len flag:flag];
                    }
                } else if(offset+data_len==loc+len) {
                    // at the tail
                    NSMutableDictionary* seg_new=[self segment_new:offset len:data_len flag:1];
                    [segments insertObject:seg_new atIndex:idx+1];
                    [self segment_upd:seg loc:loc len:len-=data_len flag:flag];
                } else {
                    // in the middle
                    NSMutableDictionary* seg_new=[self segment_new:offset len:data_len flag:1];
                    NSMutableDictionary* seg_new1=[self segment_new:loc len:offset-loc flag:flag];
                    [self segment_upd:seg loc:offset+data_len len:len-data_len-(offset-loc) flag:flag];
                    [segments insertObject:seg_new atIndex:idx];
                    [segments insertObject:seg_new1 atIndex:idx];
                }
                data_left -= data_len;
                offset += data_len;
                break;
            }
        }
        if(!found) {
            NSLog(@"logic error write: %d [%d,%d)", (int)data.length, (int)offset, (int)(data.length+offset));
            return FALSE;
            break;
        }
    }
    // merge 1 segment
    for(unsigned long idx=segments.count-1; idx>0; --idx) {
        NSMutableDictionary* seg1=[segments objectAtIndex:idx-1];
        NSMutableDictionary* seg=[segments objectAtIndex:idx];
        if([seg getInt:@"flag"]==[seg1 getInt:@"flag"]) {
            NSUInteger loc=[seg1 getLongLong:@"loc"];
            NSUInteger len=[seg1 getLongLong:@"len"]+[seg getLongLong:@"len"];
            int flag=[seg1 getInt:@"flag"];
            [self segment_upd:seg1 loc:loc len:len flag:flag];
            [segments removeObjectAtIndex:idx];
        }
    }
    
    return TRUE;
}
- (void)writeMeta{
    [FileManager writeData:[self.meta JSONStringXnw] toFile:self.metaPath];
}
- (NSData *)dataWithRange:(NSRange)range{
    if(range.length>4*1024*1024) range.length = 4*1024*1024;
    
    NSMutableArray* segments=(NSMutableArray*)[self.meta getArry:@"segment"];
    for(int idx=0; idx<segments.count; ++idx) {
        NSMutableDictionary* seg=[segments objectAtIndex:idx];
        NSUInteger loc=[seg getLongLong:@"loc"];
        NSUInteger len=[seg getLongLong:@"len"];
        int flag=[seg getInt:@"flag"];
        
        // offset in this segments
        if(range.location>=loc && range.location<loc+len) {
            if(!flag) {
//                NSLog(@"NOT found [%lu,%luu)",(unsigned long)range.location,range.location+range.length);
                return nil;
            }
            len -= (range.location-loc);
            if(len < range.length) {
                range.length = len;
            }
            break;
        }
    }
    
    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_videoPath] options:NSDataReadingMappedIfSafe error:nil];
    if(range.location>=filedata.length) {
//        NSLog(@"NOT found [%lu,%lu)",(unsigned long)range.location,range.location+range.length);
        return nil;
    }
    if(range.length + range.location > filedata.length) {
        range.length = filedata.length - range.location;
    }
    return [filedata subdataWithRange:range];
}
- (void)dealloc{
    [FileManager writeData:[self.meta JSONStringXnw] toFile:self.metaPath];
    
}
@end

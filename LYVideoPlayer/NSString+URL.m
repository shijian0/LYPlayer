//
//  NSString+URL.m
//  LYVideoPlayer
//
//  Created by LiYong on 2019/3/14.
//  Copyright © 2019 勇 李. All rights reserved.
//

#import "NSString+URL.h"

@implementation NSString (URL)
- (NSString *)fileidFromUrl{
    if ([self hasPrefix:@"http://"]) {
        NSString *fileid = [self stringByReplacingOccurrencesOfString:@"%7B"
                                                           withString:@"{"
                                                              options:NSCaseInsensitiveSearch
                                                                range:NSMakeRange(0, self.length)];
        fileid = [fileid stringByReplacingOccurrencesOfString:@"%7D"
                                                   withString:@"}"
                                                      options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(0, fileid.length)];
        NSRange r1 = [fileid rangeOfString:@"{"];
        if (r1.length > 0) {
            NSRange r2 = [fileid rangeOfString:@"}"];
            if (r2.length > 0 && r1.location < r2.location) {
                r1.length = r2.location - r1.location + 1;
                fileid = [fileid substringWithRange:r1];
                return fileid;
            }
        }
    }
    return nil;
}
@end

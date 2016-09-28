//
//  CacheHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-27.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CacheUpdateBlock)(double progress);
typedef void (^CacheFinishedBlock)();

@interface AWCacheHelper : NSObject

+ (AWCacheHelper*) sharedInstance;

- (BOOL) requiresFullUpdate;
- (void) updateCacheVersion;

- (void) clearCache: (CacheUpdateBlock) updateProgressBlock;

- (void) updateCache: (BOOL) delta
         updateBlock: (CacheUpdateBlock) updateBlock
            finished: (CacheFinishedBlock) finishedBlock;

- (void) updateCache: (BOOL) delta
           withDates: (NSSet*) dates
         updateBlock: (CacheUpdateBlock) updateBlock
            finished: (CacheFinishedBlock) finishedBlock;

- (void) updateRevenueCacheInWindow: (NSWindow*) window;

@end

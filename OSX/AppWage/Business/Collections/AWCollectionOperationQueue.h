//
//  AWCollectionOperationQueue.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/23/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CollectionTypeIdle,
    CollectionTypePreparing,

    CollectionTypeReports,
    CollectionTypeReviews,
    CollectionTypeRankings,

    CollectionTypeKeywordRankings,
} CollectionType;

@interface AWCollectionOperationQueue : NSObject
{
    
}

+ (NSString*) progressNotificationName;
+ (NSString*) newReviewsNotificationName;
+ (NSString*) newRanksNotificationName;
+ (NSString*) newReportsNotificationName;
+ (NSString*) newKeywordRanksNotificationName;

+ (AWCollectionOperationQueue*) sharedInstance;

- (void) queueReportCollectionWithTimeInterval: (NSTimeInterval) timeInterval;

- (void) queueRankCollectionWithTimeInterval: (NSTimeInterval) timeInterval
                             specifiedAppIds: (NSSet*) specifiedAppIds;

- (void) queueReviewCollectionWithTimeInterval: (NSTimeInterval) timeInterval
                               specifiedAppIds: (NSSet*) specifiedAppIds;

- (void) queueKeywordRankCollectionWithTimeInterval: (NSTimeInterval) timeInterval
                                    specifiedAppIds: (NSSet*) specifiedAppIds;


- (void) cancelAllOperations: (BOOL) clearQueuedEntries;

- (BOOL) isRunning;

- (void) loadReports: (NSArray*) reportsToLoad;

- (void) disableCollectionStartup;
- (void) enableCollectionStartup;

@property(nonatomic,assign) double      currentProgress;
@property(nonatomic,copy)   NSString *  currentStateString;

@end

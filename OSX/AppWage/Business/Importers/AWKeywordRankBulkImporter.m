//
//  AWKeywordRankBulkImporter.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWKeywordRankBulkImporter.h"
#import "AWApplication.h"
#import "AWGenre.h"
#import "AWCountry.h"

@interface AWKeywordRankBulkImporter()
{
    NSMutableArray<AWKeywordRankBulkImporterEntry*>* keywordRanksToImport;
    NSTimer                 * keywordRankInsertTimer;
}
@end

@implementation AWKeywordRankBulkImporter

@synthesize autoInsertCount;

+(AWKeywordRankBulkImporter*)sharedInstance
{
    static dispatch_once_t pred;
    static AWKeywordRankBulkImporter *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWKeywordRankBulkImporter alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        autoInsertCount = 1000;
        keywordRanksToImport   = [NSMutableArray array];
    }
    
    return self;
}

- (void) addKeywordRank: (AWKeywordRankBulkImporterEntry*) keywordRankToAdd
{
    @synchronized(keywordRanksToImport)
    {
        // Add our reviewToAdd
        [keywordRanksToImport addObject: keywordRankToAdd];

        dispatch_async(dispatch_get_main_queue(), ^{
            [keywordRankInsertTimer invalidate];
            keywordRankInsertTimer = nil;
        });

        if(keywordRanksToImport.count >= autoInsertCount)
        {
            [self doInserts];
            return;
        }

        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            keywordRankInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                                      target: self
                                                                    selector: @selector(insertTimerTriggered)
                                                                    userInfo: nil
                                                                     repeats: NO];
        });
    } // End of synchronzied
}

- (void) addNull
{
    @synchronized(keywordRanksToImport)
    {
        // If we have nothing in the queue and we are adding a null, then we have nothing to do.
        if(0 == keywordRanksToImport.count)
        {
            return;
        }

        // Clear the timer
        dispatch_async(dispatch_get_main_queue(), ^{
            [keywordRankInsertTimer invalidate];
            keywordRankInsertTimer = nil;
        });

        // Add our reviewToAdd
        [keywordRanksToImport addObject: (id) [NSNull null]];

        [self doInserts];
    }
}
- (void) addKeywordRanks: (NSArray*) keywordRanksToAdd
{
    @synchronized(keywordRanksToImport)
    {
        // Add our reviewToAdd
        [keywordRanksToImport addObjectsFromArray: keywordRanksToAdd];

        dispatch_async(dispatch_get_main_queue(), ^{
            [keywordRankInsertTimer invalidate];
            keywordRankInsertTimer = nil;
        });

        if(keywordRanksToImport.count >= autoInsertCount)
        {
            [self doInserts];
            return;
        }

        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            keywordRankInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                               target: self
                                                             selector: @selector(insertTimerTriggered)
                                                             userInfo: nil
                                                              repeats: NO];
        });
    } // End of synchronzied
}

- (void) insertTimerTriggered
{
    // The timer fired in the main thread. We will do processing in the background thread.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(keywordRanksToImport)
        {
            [self doInserts];
        } // End of synchronzied
    });
} // End of insertTimerTriggered

- (void) doInserts
{
    NSLog(@"AWKeywordRankBulkImporter - Performing inserts on %ld objects on %@ thread.",
          keywordRanksToImport.count, [NSThread currentThread].isMainThread ? @"MAIN" : @"BACKGROUND");
    
    // Get our current date. Truncate the seconds
    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:
                                         NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |
                                         NSCalendarUnitHour | NSCalendarUnitMinute
                                                                        fromDate: [NSDate date]];
    
    [dateComponents setSecond: 0];

    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithName: @"UTC"];
    __block NSDate * importDate = [gregorian dateFromComponents: dateComponents];
    __block BOOL hasNull = NO;

    // Create a copy
    NSArray<AWKeywordRankBulkImporterEntry*>* tempRanks = [keywordRanksToImport copy];
    [keywordRanksToImport removeAllObjects];

    @autoreleasepool {
        // Import the ranks
        [[AWSQLiteHelper keywordsDatabaseQueue] inTransaction:
         ^(FMDatabase * database, BOOL *rollback) {
            [tempRanks enumerateObjectsUsingBlock: ^(AWKeywordRankBulkImporterEntry* rankEntry, NSUInteger rankIndex, BOOL * stop)
             {
                 // Skip a null.
                 if([NSNull null] == (id) rankEntry)
                 {
                     hasNull = YES;
                     return;
                 } // End of hasNull

                 if(nil == rankEntry.keywordRankDate)
                 {
                     rankEntry.keywordRankDate    = importDate;
                 }

                 [database executeUpdate: @"INSERT INTO applicationKeywordRank (applicationKeywordId, countryId, position, positionDate) VALUES (?, ?, ?, ?)",
                  rankEntry.applicationKeywordId,
                  rankEntry.countryId,
                  rankEntry.rank,
                  rankEntry.keywordRankDate];
             }];
         }];
    } // End of autoreleasepool
}

@end


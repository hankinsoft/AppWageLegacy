//
//  AWReviewBulkImporter.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/9/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWRankBulkImporter.h"
#import "AWApplication.h"
#import "AWGenre.h"
#import "AWCountry.h"

@interface AWRankBulkImporter()
{
    NSMutableArray          * ranksToImport;
    NSTimer                 * rankInsertTimer;
}
@end

@implementation AWRankBulkImporter

@synthesize autoInsertCount;

+(AWRankBulkImporter*)sharedInstance
{
    static dispatch_once_t pred;
    static AWRankBulkImporter *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWRankBulkImporter alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        autoInsertCount = 1000;
        ranksToImport   = [NSMutableArray array];
    }
    
    return self;
}

- (void) addRank: (AWRankBulkImporterEntry*) rankToAdd
{
    @synchronized(ranksToImport)
    {
        // Add our reviewToAdd
        [ranksToImport addObject: rankToAdd];

        dispatch_async(dispatch_get_main_queue(), ^{
            [rankInsertTimer invalidate];
            rankInsertTimer = nil;
        });

        if(ranksToImport.count >= autoInsertCount)
        {
            [self doInserts];
            return;
        }

        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            rankInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                               target: self
                                                             selector: @selector(insertTimerTriggered)
                                                             userInfo: nil
                                                              repeats: NO];
        });
    } // End of synchronzied
}

- (void) addNull
{
    @synchronized(ranksToImport)
    {
        // If we have nothing in the queue and we are adding a null, then we have nothing to do.
        if(0 == ranksToImport.count)
        {
            return;
        }

        // Clear the timer
        dispatch_async(dispatch_get_main_queue(), ^{
            [rankInsertTimer invalidate];
            rankInsertTimer = nil;
        });

        // Add our reviewToAdd
        [ranksToImport addObject: [NSNull null]];

        [self doInserts];
    }
}
- (void) addRanks: (NSArray*) ranksToAdd
{
    @synchronized(ranksToImport)
    {
        // Add our reviewToAdd
        [ranksToImport addObjectsFromArray: ranksToAdd];

        dispatch_async(dispatch_get_main_queue(), ^{
            [rankInsertTimer invalidate];
            rankInsertTimer = nil;
        });

        if(ranksToImport.count >= autoInsertCount)
        {
            [self doInserts];
            return;
        }

        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            rankInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
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
        @synchronized(ranksToImport)
        {
            [self doInserts];
        } // End of synchronzied
    });
} // End of insertTimerTriggered

- (void) doInserts
{
    NSLog(@"AWRankBulkImporter - Performing inserts on %ld objects on %@ thread.",
          ranksToImport.count, [NSThread currentThread].isMainThread ? @"MAIN" : @"BACKGROUND");
    
    // Get our current date. Truncate the seconds
    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:
                                         NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |
                                         NSCalendarUnitHour | NSCalendarUnitMinute
                                                                        fromDate: [NSDate date]];
    
    [dateComponents setSecond: 0];

    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    __block NSDate * importDate = [gregorian dateFromComponents: dateComponents];
    __block BOOL hasNull = NO;

    // Create a copy
    NSArray * tempRanks = [ranksToImport copy];
    [ranksToImport removeAllObjects];

    NSArray * allCountries                 = [AWCountry allCountries];
    NSMutableDictionary * countryLookup = [NSMutableDictionary dictionary];
    [allCountries enumerateObjectsUsingBlock:
     ^(AWCountry * country, NSUInteger index, BOOL * stop)
     {
         countryLookup[country.countryCode] = country;
     }];

    // Get our charts
    NSArray * allCharts                = [AWGenre allCharts];
    NSMutableDictionary * chartLookup  = [NSMutableDictionary dictionary];
    [allCharts enumerateObjectsUsingBlock:
     ^(AWGenreChart * chart, NSUInteger index, BOOL * stop)
     {
         chartLookup[chart.chartId] = chart;
     }];

    NSPredicate * applicationsThatWantRanksPredicate = [NSPredicate predicateWithFormat: @"shouldCollectRanks = YES"];

    NSArray * allApplications =
        [[AWApplication allApplications] filteredArrayUsingPredicate: applicationsThatWantRanksPredicate];

    @autoreleasepool {
        NSMutableDictionary * applicationLookup = [NSMutableDictionary dictionary];
        [allApplications enumerateObjectsUsingBlock:
         ^(AWApplication * application, NSUInteger index, BOOL * stop)
         {
             applicationLookup[application.applicationId] = application;
         }];

        // Import the ranks
        [[AWSQLiteHelper rankingDatabaseQueue] inTransaction:
         ^(FMDatabase * database, BOOL *rollback) {
            [tempRanks enumerateObjectsUsingBlock: ^(id rankEntryObject, NSUInteger rankIndex, BOOL * stop)
             {
                 // Skip a null.
                 if([NSNull null] == rankEntryObject)
                 {
                     hasNull = YES;
                     return;
                 } // End of hasNull

                 AWRankBulkImporterEntry * rankEntry = (AWRankBulkImporterEntry*) rankEntryObject;
                 if(nil == applicationLookup[rankEntry.applicationId])
                 {
                     return;
                 } // End of the application does not exist (we are probably not collecting ranks for it).

                 if(nil == rankEntry.rankDate)
                 {
                     rankEntry.rankDate    = importDate;
                 }

                 [database executeUpdate: @"INSERT INTO rank (applicationId, genreId, genreChartId, countryId, position, positionDate) VALUES (?, ?, ?, ?, ?, ?)",
                  rankEntry.applicationId,
                  rankEntry.genreId,
                  rankEntry.chartId,
                  rankEntry.countryId,
                  rankEntry.position,
                  rankEntry.rankDate];
             }];
         }];
    } // End of autoreleasepool
}

@end

//
//  AWReviewBulkImporter.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/10/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWReviewBulkImporter.h"
#import "AWApplication.h"
#import "AWCountry.h"

#import "AWApplicationListTreeViewController.h"
#import "AWCollectionOperationQueue.h"

@interface AWReviewBulkImporter()
{
    NSMutableArray          * reviewsToImport;
    NSTimer                 * reviewInsertTimer;
    NSTimer                 * uiUpdateTimer;
}
@end

@implementation AWReviewBulkImporter

@synthesize autoInsertCount;

+(AWReviewBulkImporter*)sharedInstance
{
    static dispatch_once_t pred;
    static AWReviewBulkImporter *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWReviewBulkImporter alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        autoInsertCount = kDefaultReviewAutoInsertCount;
        reviewsToImport = [NSMutableArray array];
    }
    
    return self;
}

- (void) addReview: (id) reviewToAdd
{
    @synchronized(reviewsToImport)
    {
        // If we have nothing in the queue and we are adding a null, then we have nothing to do.
        if(0 == reviewsToImport.count && [NSNull null] == reviewToAdd)
        {
            return;
        }

        // Add our reviewToAdd
        [reviewsToImport addObject: reviewToAdd];
        dispatch_async(dispatch_get_main_queue(), ^{
            [reviewInsertTimer invalidate];
            reviewInsertTimer = nil;
        });

        if(reviewsToImport.count >= autoInsertCount || [NSNull null] == reviewToAdd)
        {
            [self doInserts];
            return;
        }

        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            reviewInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                                 target: self
                                                               selector: @selector(insertTimerTriggered)
                                                               userInfo: nil
                                                                repeats: NO];
        });
    } // End of synchronzied
}

- (void) addReviews: (NSArray*) reviewsToAdd
{
    @synchronized(reviewsToImport)
    {
        // Add our reviewToAdd
        [reviewsToImport addObjectsFromArray: reviewsToAdd];
        [reviewInsertTimer invalidate];

        if(reviewsToImport.count >= autoInsertCount)
        {
            [self doInserts];
            return;
        }
        
        // Configure our insert timer.
        dispatch_async(dispatch_get_main_queue(), ^{
            reviewInsertTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0
                                                                 target: self
                                                               selector: @selector(insertTimerTriggered)
                                                               userInfo: nil
                                                                repeats: NO];
        });
    } // End of synchronzied
} // End of addReviews

- (void) insertTimerTriggered
{
    // The timer fired in the main thread. We will do processing in the background thread.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(reviewsToImport)
        {
            [self doInserts];
        } // End of synchronzied
    });
} // End of insertTimerTriggered

- (void) doInserts
{
    [uiUpdateTimer invalidate];
    uiUpdateTimer = nil;

    NSLog(@"AWReviewBulkImporter - Performing review inserts on %ld objects on %@ thread.",
          reviewsToImport.count,
          [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND");

    // Get our current date. Truncate the seconds
    NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:
                                         NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |
                                         NSCalendarUnitHour | NSCalendarUnitMinute
                                                                        fromDate: [NSDate date]];
    
    [dateComponents setSecond: 0];
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    __block NSDate * importDate = [gregorian dateFromComponents: dateComponents];
    __block NSUInteger newReviewCount = 0;
    
    // Create a copy
    NSArray * tempReviews = [reviewsToImport copy];
    [reviewsToImport removeAllObjects];

    NSArray * allCountries    = [AWCountry allCountries];
    NSPredicate * countryPredicateTemplate = [NSPredicate predicateWithFormat: @"countryCode = $countryCode"];

    __block BOOL hasNull = NO;

    @autoreleasepool {
        // Get the review ids that we want to insert.
        NSMutableArray * reviewIdsToInsert = [NSMutableArray arrayWithArray: [tempReviews valueForKey: @"reviewId"]];

        // There may be a null (end of list). If so, kill it.
        [reviewIdsToInsert removeObjectIdenticalTo: [NSNull null]];

        // Get our existingReviewIds
        __block NSMutableArray * existingReviewIds = @[].mutableCopy;
        [[AWSQLiteHelper reviewDatabaseQueue] inDatabase:^(FMDatabase * database) {
            NSString * existingReviewIdQuery = [NSMutableString stringWithFormat: @"SELECT DISTINCT reviewId FROM review WHERE reviewId IN (%@)",
                [reviewIdsToInsert componentsJoinedByString: @","]];

            FMResultSet * results = [database executeQuery: existingReviewIdQuery];
            while([results next])
            {
                NSNumber * resultId = [NSNumber numberWithInt: [results intForColumnIndex: 0]];

                [existingReviewIds addObject: resultId];
            }
        }];

        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL *rollback) {

        // Import the reviews
        [tempReviews enumerateObjectsUsingBlock: ^(id reviewDictionary, NSUInteger rankIndex, BOOL * stop)
         {
             // Skip a null.
             if([NSNull null] == reviewDictionary)
             {
                 hasNull = YES;
                 return;
             } // End of hasNull

             // If it already exists, then don't do jack.
             if([existingReviewIds containsObject: reviewDictionary[@"reviewId"]]) return;

             AWCountry * country =
                [[allCountries filteredArrayUsingPredicate: [countryPredicateTemplate predicateWithSubstitutionVariables: @{@"countryCode":reviewDictionary[@"countryCode"]}]] firstObject];

             if(nil == country)
             {
                 return;
             }

             [database executeUpdate:@"INSERT INTO review (reviewId, applicationId, countryId, stars, appVersion, content, reviewer, title, collectedDate, lastUpdated) VALUES (?,?,?,?,?,?,?,?,?, ?)",
              reviewDictionary[@"reviewId"],
              reviewDictionary[@"applicationId"],
              country.countryId,
              reviewDictionary[@"stars"],
              reviewDictionary[@"appVersion"],
              reviewDictionary[@"content"],
              reviewDictionary[@"reviewer"],
              reviewDictionary[@"title"],
              [NSNumber numberWithInteger: (NSInteger)[importDate timeIntervalSince1970]],
              [NSNumber numberWithInteger: (NSInteger)[reviewDictionary[@"lastUpdated"] timeIntervalSince1970]]];

             // We have new reviews.
             ++newReviewCount;
         }];
        }]; // End of review sqlite
    } // End of autoreleasepool
}

- (void) newReviews
{

    [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                        object: nil];

    [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                        object: nil];
}

@end

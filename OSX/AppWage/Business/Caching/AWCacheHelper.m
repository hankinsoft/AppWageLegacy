//
//  CacheHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-27.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWCacheHelper.h"
#import "AWProduct.h"
#import "AWCurrencyHelper.h"
#import "AWReportCollectionOperation.h"
#import "HSProgressWindowController.h"
#import "AWDateRangeSelectorViewController.h"
#import "AWiTunesConnectHelper.h"
#import "AWCountry.h"

#define kLastCacheBundleVersion         @"lastCacheBundleVersion"
@interface AWCacheHelper()
{
    HSProgressWindowController            * progressWindowController;
}

@property(nonatomic,copy)   CacheUpdateBlock        cacheUpdateBlock;
@property(nonatomic,copy)   CacheFinishedBlock      finishedUpdateBlock;
@property(nonatomic,assign) double                  maxProgress;

@end

@implementation AWCacheHelper

@synthesize cacheUpdateBlock, finishedUpdateBlock, maxProgress;

+(AWCacheHelper*) sharedInstance
{
    static dispatch_once_t pred;
    static AWCacheHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWCacheHelper alloc] init];
    });
    return sharedInstance;
}

- (BOOL) requiresFullUpdate
{
    // Do not want this to launch everytime I start the app.
    if([[AWSystemSettings sharedInstance] isDebugging])
    {
        return NO;
    }

    NSNumber * lastCacheBundleVersion = [[NSUserDefaults standardUserDefaults] objectForKey: kLastCacheBundleVersion];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSNumber * currentBundleVersion = [infoDict objectForKey: (NSString *)kCFBundleVersionKey];

    // No last version, then do nothing.
    if(nil == lastCacheBundleVersion)
    {
        return YES;
    }

    if(lastCacheBundleVersion.doubleValue < currentBundleVersion.doubleValue)
    {
        return YES;
    }

    return NO;
}

- (void) updateCacheVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSNumber * currentBundleVersion = [infoDict objectForKey: (NSString *)kCFBundleVersionKey];
    
    [[NSUserDefaults standardUserDefaults] setObject: currentBundleVersion
                                              forKey: kLastCacheBundleVersion];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearCache: (CacheUpdateBlock) updateProgressBlock
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
    {
        [salesDatabase executeUpdate: @"UPDATE salesReport SET cached = 0"];
        [salesDatabase executeUpdate: @"DELETE FROM salesReportCache"];
        [salesDatabase executeUpdate: @"DELETE FROM salesReportCachePerApp"];
    }];

    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         // Vacuum cannot be run in transaction.
         [salesDatabase executeUpdate: @"VACUUM"];
     }];

    NSLog(@"Sales cache has been cleared.");
} // End of clearCache

- (void) updateCache: (BOOL) delta
         updateBlock: (CacheUpdateBlock) updateProgressBlock
            finished: (CacheFinishedBlock) finishedBlock
{
    [self updateCache: delta
            withDates: nil
          updateBlock: updateProgressBlock
             finished: finishedBlock];
}

- (void) updateCache: (BOOL) delta
           withDates: (NSSet*) dates
         updateBlock: (CacheUpdateBlock) updateProgressBlock
            finished: (CacheFinishedBlock) finishedBlock
{
    // Set our blocks
    self.cacheUpdateBlock = updateProgressBlock;
    self.finishedUpdateBlock = finishedBlock;

    // Update our progress
    if(NULL != self.cacheUpdateBlock)
    {
        self.cacheUpdateBlock(0);
    } // End of cacheUpdateBlock

    MachTimer * machTimer = [MachTimer startTimer];
    NSLog(@"updateCache starting. Delta: %@", delta ? @"YES" : @"NO");

    NSString * currencyCase =
        [[AWCurrencyHelper sharedInstance] sqlQueryForExchangeRate: [[AWSystemSettings sharedInstance] currencyCode]];

    NSMutableString * countryCase = [NSMutableString stringWithFormat: @"CASE\r\n"];
    NSArray * countries = [AWCountry allCountries];

    [countries enumerateObjectsWithOptions: 0
                                usingBlock: ^(AWCountry * country, NSUInteger index, BOOL * stop)
     {
         [countryCase appendFormat: @"\tWHEN countryCode = '%@' THEN %lu\r\n",
          country.countryCode,
          (unsigned long)country.countryId.unsignedIntegerValue];
     }];

    [countryCase appendFormat: @"\tELSE 0"];

    // If we have a date range, then we will clear everything inbetween so that the data gets updated
    if(nil == dates)
    {
        [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
         {
             [salesDatabase executeUpdate: @"UPDATE salesReport SET cached = 0"];
             [salesDatabase executeUpdate: @"DELETE FROM salesReportCache"];
             [salesDatabase executeUpdate: @"DELETE FROM salesReportCachePerApp"];
         }];
    }
    else
    {
        [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
         {
             [dates enumerateObjectsUsingBlock: ^(NSString * dateRangeString, BOOL * stop)
              {
                  NSArray * entries = [dateRangeString componentsSeparatedByString: @"-"];
                  if(2 != entries.count)
                  {
                      return;
                  }

                  NSUInteger startDate = [entries[0] integerValue];
                  NSUInteger endDate   = [entries[1] integerValue];

                  [salesDatabase executeUpdateWithFormat: @"UPDATE salesReport SET cached = 0 WHERE beginDate >= %ld AND endDate <= %ld", startDate, endDate];
                  [salesDatabase executeUpdateWithFormat: @"DELETE FROM salesReportCache WHERE date >= %ld AND date <= %ld", startDate, endDate];
                  [salesDatabase executeUpdateWithFormat: @"DELETE FROM salesReportCachePerApp WHERE date >= %ld AND date <= %ld", startDate, endDate];
              }];
         }];
    } // End of no dates

    // Set our max progress
    self.maxProgress = DashboardChartDisplayMAXIMUM * SalesReportMAX;

    NSUInteger currentProgress = 0;

    for(NSUInteger index = 0;
        index < DashboardChartDisplayMAXIMUM;
        ++index)
    {
        // Update our progress
        if(NULL != self.cacheUpdateBlock)
        {
            self.cacheUpdateBlock((currentProgress / self.maxProgress) * 100.0);
        }

        [self updateCacheFor: (DashboardChartDisplay)index
                 updateBlock: updateProgressBlock
                     isDelta: delta
                 countryCase: countryCase
                currencyCase: currencyCase
             currentProgress: &currentProgress];
    } // End of loop

    // Update our per-product cache.
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
     {
         [salesDatabase executeUpdate: @"INSERT INTO salesReportCachePerApp SELECT cacheType, SUM(cacheValue), productId, date FROM salesReportCache WHERE salesReportCache.date NOT IN (SELECT distinct date FROM salesReportCachePerApp) GROUP BY cacheType, productId, date"];
     }];

    // Mark all entries as cached
    [self markAllAsCached];

    NSLog(@"updateFullCache finished. Took %f", [machTimer elapsedSeconds]);

    if(NULL != finishedBlock)
    {
        finishedBlock();
    } // End of finishedBlock
}

- (void) markAllAsCached
{
    MachTimer * machTimer = [MachTimer startTimer];

    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
     {
         [salesDatabase executeUpdate: @"UPDATE salesReport SET cached = 1"];
     }];

    NSLog(@"mark cached finished. Took %f", [machTimer elapsedSeconds]);
}

- (void)processSalesReports: (DashboardChartDisplay)dashboardChartDisplayMode
                    isDelta: (BOOL) isDelta
                countryCase: (NSString*) countryCase
               currencyCase: (NSString*) currencyCase
            currentProgress: (NSUInteger*) currentProgress
{
    // Profess dates from lowest range to highest, so that we get the most details in
    // the cache.
    for(SalesReportType salesReportType = 0;
        salesReportType < SalesReportMAX;
        salesReportType++)
    {
        // Increase our current progress
        ++(*currentProgress);

        if(NULL != self.cacheUpdateBlock)
        {
            self.cacheUpdateBlock(((*currentProgress) / self.maxProgress) * 100.0);
        }

        NSString * valueQuery = nil;
        if(dashboardChartDisplayMode == DashboardChartDisplayTotalRevenue)
        {
            valueQuery = [NSString stringWithFormat: @"(%@ END) * units * profitPerUnit", currencyCase];
        }
        else if(dashboardChartDisplayMode == DashboardChartDisplayRefunds)
        {
            valueQuery = @"ABS(units)";
        }
        else
        {
            valueQuery = @"units";
        }

        NSString * whereClause = [NSString stringWithFormat: @"salesReportType = %u AND %@ %@", salesReportType,
                                  [AWSalesReportHelper clauseForReportType: dashboardChartDisplayMode],
                                  isDelta ? @"AND cached = 0" : @""];

        // If we are not a single day, then we can do some custom processing
        if(SalesReportDaily == salesReportType)
        {
            NSString * selectQuery =
                [NSString stringWithFormat:
                    @"SELECT %d, SUM(%@), "
                    @"appleIdentifier, %@ END AS countryId, beginDate\r\n"
                    @"FROM salesReport WHERE %@\r\n"
                    @"GROUP BY appleIdentifier, beginDate, productTypeIdentifier, countryCode, currency",
                 (int)dashboardChartDisplayMode, valueQuery, countryCase, whereClause];

            NSString * insertQuery = [NSString stringWithFormat: @"INSERT OR IGNORE INTO salesReportCache\r\n%@", selectQuery];

            [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
            {
                [salesDatabase executeUpdate: insertQuery];
            }];
        } // End of we are a single day
        else
        {
            //            NSString * debugClause = @"AND appleIdentifier = 586001240 AND countryCode = 'us'";
            NSString * debugClause = @"";

            NSString * distinctRangeQuery =
            [NSString stringWithFormat: @"SELECT DISTINCT beginDate, endDate, appleIdentifier, %@ END AS countryId, SUM(%@) as value FROM salesReport WHERE %@ AND salesReportType = %u %@ GROUP BY appleIdentifier, countryCode, beginDate, endDate ORDER BY endDate - beginDate ASC, endDate DESC",
             countryCase, valueQuery, whereClause, salesReportType, debugClause];

            distinctRangeQuery =
            [NSString stringWithFormat:
             @"SELECT *, (SELECT MIN(distinct date) FROM salesReportCache WHERE cacheType = %u AND date >= temp.beginDate AND date <= temp.endDate AND productId = temp.appleIdentifier AND countryId = temp.countryId) AS minDate, IFNULL((SELECT SUM(cacheValue) FROM salesReportCache WHERE cacheType = %u AND date >= temp.beginDate AND date <= temp.endDate AND productId = temp.appleIdentifier AND countryId = temp.countryId),0) AS existingValue FROM (%@) AS temp", dashboardChartDisplayMode, dashboardChartDisplayMode, distinctRangeQuery];

            __block NSMutableArray * allResults = [NSMutableArray array];
            [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
             {
                 FMResultSet * results = [salesDatabase executeQuery: distinctRangeQuery];

                 if(0 != salesDatabase.lastErrorCode)
                 {
                     NSLog(@"Have an error.");
                 } // End of not an error

                 while([results next])
                 {
                     [allResults addObject: [results resultDictionary]];
                 } // End of loop
             }];

            // No results = do nothing.
            if(0 == allResults.count)
            {
                continue;
            } // End of no results

            [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
             {
                [self processRangedSalesReports: allResults
                      dashboardChartDisplayMode: dashboardChartDisplayMode
                                salesReportType: salesReportType
                                     valueQuery: valueQuery
                                    countryCase: countryCase
                                    whereClause: whereClause
                                     inDatabase: salesDatabase];
             }];
        }
    } // End of date loop
}

- (void) updateCacheFor: (DashboardChartDisplay) dashboardChartDisplayMode
            updateBlock: (CacheUpdateBlock) updateProgressBlock
                isDelta: (BOOL) isDelta
            countryCase: (NSString*) countryCase
           currencyCase: (NSString*) currencyCase
        currentProgress: (NSUInteger*) currentProgress
{
    MachTimer * machTimer = [MachTimer startTimer];

    [self processSalesReports: dashboardChartDisplayMode
                      isDelta: isDelta
                  countryCase: countryCase
                 currencyCase: currencyCase
              currentProgress: currentProgress];

    NSLog(@"updateCacheFor %u finished. Took %f",
          dashboardChartDisplayMode,
          [machTimer elapsedSeconds]);
} // End of updateCache

- (void) updateRevenueCacheInWindow: (NSWindow*) window
{
    dispatch_async(dispatch_get_main_queue(), ^{
        progressWindowController = [[HSProgressWindowController alloc] init];

        progressWindowController.labelString = @"Updating sales cache";
        [progressWindowController beginSheetModalForWindow: window
                                         completionHandler: nil];
    });

    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
    {
        NSString * updateQuery =
            [NSString stringWithFormat: @"UPDATE salesReport SET cached = 0 WHERE %@",
             [AWSalesReportHelper clauseForReportType: DashboardChartDisplayTotalRevenue]];

        // Clear the totalSales entry
        [salesDatabase executeUpdate: updateQuery];

        [salesDatabase executeUpdate: @"DELETE FROM salesReportCache WHERE cacheType = ?",
         [NSNumber numberWithInt: DashboardChartDisplayTotalRevenue]];

        [salesDatabase executeUpdate: @"DELETE FROM salesReportCachePerApp WHERE cacheType = ?",
         [NSNumber numberWithInt: DashboardChartDisplayTotalRevenue]];
    }];

    self.maxProgress = SalesReportMAX;

    [self updateCache: NO
            withDates: nil
          updateBlock: nil
             finished: ^(void) {
                 // Update the UI
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [progressWindowController endSheetWithReturnCode: 0];
                 });
             }];
} // End of updateCacheInWindow

- (void)processRangedSalesReports: (NSArray *) allResults
        dashboardChartDisplayMode: (DashboardChartDisplay)dashboardChartDisplayMode
                  salesReportType: (SalesReportType)salesReportType
                       valueQuery: (NSString*) valueQuery
                      countryCase: (NSString*) countryCase
                      whereClause: (NSString*) whereClause
                       inDatabase: (FMDatabase*) salesDatabase
{
    // Concurrent for perfomance improvements?
    [allResults enumerateObjectsWithOptions: NSEnumerationConcurrent
                                 usingBlock: ^(NSDictionary * entry, NSUInteger index, BOOL * stop)
     {
         long startDateTimestamp      = [entry[@"beginDate"] longValue];
         long endDateTimestamp        = [entry[@"endDate"] longValue];
         double actualValue           = [entry[@"value"] doubleValue];
         double existingValue         = [entry[@"existingValue"] doubleValue];
         NSNumber * appleIdentifier   = entry[@"appleIdentifier"];
         NSNumber * countryId         = entry[@"countryId"];
         NSNumber * minDate           = entry[@"minDate"];

         NSMutableArray * allDates = [NSMutableArray array];

         NSDate * startDate = [NSDate dateWithTimeIntervalSince1970: startDateTimestamp];
         NSDate * endDate   = [NSDate dateWithTimeIntervalSince1970: endDateTimestamp];

         long dayCount      =
            [AWDateRangeSelectorViewController daysBetween: startDate
                                                       and: endDate];

         long startDateStamp = [entry[@"beginDate"] longValue];
         if([NSNull null] != (id)minDate && nil != minDate)
         {
             for(int index = 0;
                 index < dayCount;
                 ++index)
             {
                 long dateStamp = startDateStamp + (index * 86400);
                 NSNumber * dateStampNumber = [NSNumber numberWithLong: dateStamp];
                 if(dateStamp >= minDate.unsignedIntegerValue)
                 {
                     [allDates addObject: dateStampNumber];
                 }
             }
         } // End of minDate

         if(SalesReportWeekly == salesReportType)
         {
             // Sanity check
             NSAssert(dayCount == 7, @"Week day count is invalid.");
         }

         NSInteger remainingDays = (dayCount - allDates.count);
         if(0 == remainingDays)
         {
             return;
         }

         if(remainingDays < 0)
         {
             return;
         }

         double newValue = (actualValue - existingValue) / remainingDays;

         NSMutableArray * allQueries = [NSMutableArray array];

         for(int index = 0;
             index < dayCount;
             ++index)
         {
             long dateStamp = startDateStamp + (index * 86400);
             NSNumber * dateStampNumber = [NSNumber numberWithLong: dateStamp];

             if([allDates containsObject: dateStampNumber])
             {
                 continue;
             } // End of allDates

             [allQueries addObject: [NSString stringWithFormat: @"%d, %f, %@, %@, %ld", (int)dashboardChartDisplayMode, newValue, appleIdentifier, countryId, dateStamp]];
         } // End of day count loop

         if(0 != allQueries.count)
         {
             @synchronized(self)
             {
                 [self insertUpdateQueries: allQueries
                                inDatabase: salesDatabase];
             } // End of @synchronized
         } // End of allQueries
     }];
}

- (void) insertUpdateQueries: (NSArray*) queries
                  inDatabase: (FMDatabase*) salesDatabase
{
    NSString * insertQuery = [NSString stringWithFormat: @"INSERT INTO salesReportCache\r\nSELECT %@\r\n", [queries componentsJoinedByString: @"\r\nUNION SELECT "]];

    // Run our inserts
    [salesDatabase executeUpdate: insertQuery];

    if(0 != salesDatabase.lastErrorCode)
    {
        NSLog(@"Error");
    }
}

@end

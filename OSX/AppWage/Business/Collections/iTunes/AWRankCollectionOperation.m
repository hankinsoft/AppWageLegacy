//
//  RankCollectionTask.m
//  AppWage
//
//  Created by Kyle Hankinson on 2013-10-23.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWRankCollectionOperation.h"
#import "AWRankBulkImporterEntry.h"

@interface AWRankCollectionOperation()
{
    NSArray         * appsWeCareAbout;
    NSDictionary    * countryDetails;
    id              chartObjectId;
    NSURL           * targetUrl;
}
@end

@implementation AWRankCollectionOperation

- (id) initWithRankUrl: (NSString*) _rankUrl
       appsWeCareAbout: (NSArray*) _appsWeCareAbout
        countryDetails: (NSDictionary*) _countryDetails
         chartObjectId: (id) _chartObjectId
{
    self = [super init];
    if(self)
    {
        appsWeCareAbout = _appsWeCareAbout;
        countryDetails = _countryDetails;
        chartObjectId = _chartObjectId;

        targetUrl = [[NSURL alloc] initWithString: _rankUrl];
    }

    return self;
} // End of self

- (void) main
{
    @autoreleasepool
    {
        NSAssert(![NSThread isMainThread], @"Rank collection cannot run on the main thread.");

        [self.delegate rankCollectionOperationStarted: self];

        if ([self isCancelled])
        {
            [self.delegate rankCollectionOperationFinished: self];
            return;
        }

        // Collect the ranks
        [self collectRank];
        [self.delegate rankCollectionOperationFinished: self];
    }
}

- (void) collectRank
{

}

+ (NSArray*) processRankDictionary: (NSDictionary*) rankEntries
                   appsWeCareAbout: (NSArray*) appsWeCareAbout
                         countryId: (NSNumber*) countryId
                           chartId: (NSNumber*) chartId
                           genreId: (NSNumber*) genreId
{
    NSAssert(![NSThread isMainThread], @"Rank processing cannot run on the main thread.");

    NSArray * resultIds = rankEntries[@"resultIds"];

    __block NSMutableArray * outRankEntries = [NSMutableArray array];

    [appsWeCareAbout enumerateObjectsUsingBlock: ^(NSNumber * applicationId, NSUInteger index, BOOL * stop)
     {
         NSUInteger foundIndex = [resultIds indexOfObject: applicationId];
         if(NSNotFound == foundIndex)
         {
             return;
         }

         // We have to use +1 as the actual index, as we do not want to show an app being in Position #0.
         NSUInteger actualPosition = foundIndex + 1;

         AWRankBulkImporterEntry * entry = [[AWRankBulkImporterEntry alloc] init];
         entry.genreId       = genreId;
         entry.position      = [NSNumber numberWithUnsignedInteger: actualPosition];
         entry.applicationId = applicationId;
         entry.countryId     = countryId;
         entry.chartId       = chartId;

         // Add our entry. It needs to be a copy, as the
         [outRankEntries addObject: entry];
     }];

    return [outRankEntries copy];
}

@end

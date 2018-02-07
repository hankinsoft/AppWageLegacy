//
//  AWKeywordRankCollectionOperation.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWKeywordRankCollectionOperation.h"
#import "AWKeywordRankBulkImporter.h"

@implementation AWKeywordRankCollectionOperation
{
    NSNumber                        * applicationId;
    NSString                        * countryCode;
    NSString                        * keyword;
    NSNumber                        * applicationType;
    AWKeywordRankBulkImporterEntry  * baseInsertEntry;
}

- (id) initWithApplicationId: (NSNumber*) _applicationId
                     keyword: (NSString*) _keyword
                 countryCode: (NSString*) _countryCode
             applicationType: (NSNumber*) _applicationType
             baseInsertEntry: (AWKeywordRankBulkImporterEntry*) _baseInsertEntry
{
    self = [super init];
    if(self)
    {
        applicationId = _applicationId;
        applicationType = _applicationType;
        countryCode = _countryCode;
        keyword = _keyword;
        baseInsertEntry = _baseInsertEntry;
    } // End of self

    return self;
} // End of init

- (void) main
{
    @autoreleasepool
    {
        [super main];
        NSString * searchURL = nil;

        // Find the osx apps
        if([ApplicationTypeOSX isEqualToNumber: applicationType])
        {
            searchURL =
                [NSString stringWithFormat: @"https://itunes.apple.com/search?media=software&entity=macSoftware&term=%@&country=%@&limit=200", [keyword stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding], countryCode.lowercaseString];
        }
        else
        {
            searchURL =
                [NSString stringWithFormat: @"https://itunes.apple.com/search?media=software&term=%@&limit=&country=%@&limit=200", [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], countryCode.lowercaseString];
        }

        NSUInteger foundRank =
            [self findRank: searchURL
       targetApplicationId: applicationId];

        if(NSNotFound == foundRank)
        {
            NSLog(@"Keyword search '%@' not found for application id %@", keyword, applicationId);
            return;
        } // End of not found

        baseInsertEntry.rank = @(foundRank);

        // Add our insert
        [[AWKeywordRankBulkImporter sharedInstance] addKeywordRank: baseInsertEntry];

        NSLog(@"Going to search URL: %@", searchURL);
    } // End of autorelease pool
}

- (NSUInteger) findRank: (NSString*) targetURL
    targetApplicationId: (NSNumber*) targetApplicationId
{
    NSLog(@"Want to search with URL: %@", targetURL);

    // Get our results
    NSError __autoreleasing * error = nil;
    NSData * resultsData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: targetURL]
                                                        options: NSDataReadingUncached
                                                          error: &error];

    // If we had an error, then raise it.
    if(nil != error)
    {
        NSLog(@"Had an error searching. %@", error.localizedDescription);
        return NSNotFound;
    } // End of we had an error

    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData: resultsData
                                                                options: kNilOptions
                                                                  error: &error];

    if(nil != error)
    {
        NSLog(@"Had an error converting JSON to dictionary. %@", error.localizedDescription);
        return NSNotFound;
    }

    NSArray * resultsArray = dictionary[@"results"];

    __block NSUInteger foundIndex = NSNotFound;
    [resultsArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL * stop)
     {
         NSNumber * currentApplicationId = [NSNumber numberWithInt: [obj[@"trackId"] intValue]];
         if([currentApplicationId isEqualToNumber: targetApplicationId])
         {
             foundIndex = index;
             *stop = YES;
             return;
         }
     }];

    return foundIndex;
}

@end

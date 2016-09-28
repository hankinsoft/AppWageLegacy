//
//  ApplicationFinder.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/24/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationFinder.h"

@implementation AWApplicationFinderEntry

@synthesize applicationId = _applicationId;
@synthesize applicationName = _applicationName;
@synthesize applicationDeveloper = _applicationDeveloper;
@synthesize genreIds = _genreIds;
@synthesize applicationType = _applicationType;

@end

@implementation AWApplicationFinder

@synthesize delegate;

- (void) beginFindApplications: (NSString*) searchTerm
                    includeIOS: (bool) includeIOS
                    includeOSX: (bool) includeOSX
                    includeIBOOK: (bool) includeIBOOK
{
    NSMutableArray * allResults = [NSMutableArray array];

    NSLog(@"Application finder is searching for apps");

    // Find the osx apps
    if(includeOSX)
    {
        NSString * searchURL = [NSString stringWithFormat: @"https://itunes.apple.com/search?media=software&entity=macSoftware&term=%@", [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        [allResults addObjectsFromArray: [self findEntries: searchURL platform: ApplicationTypeOSX]];
    }

    if(includeIOS)
    {
        NSString * searchURL = [NSString stringWithFormat: @"https://itunes.apple.com/search?media=software&term=%@", [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        // Find the iOS apps
        [allResults addObjectsFromArray: [self findEntries: searchURL platform: ApplicationTypeIOS]];
    }

    // Raise our delegate
    if(nil != delegate)
    {
        // Raise out event
        [self.delegate applicationFinder: self
                    receivedApplications: [NSArray arrayWithArray: allResults]];
    }
}

- (NSArray*) findEntries: (NSString*) targetURL platform: (NSNumber*) platform
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
        [self.delegate applicationFinder: self receivedError: error];
        return [NSArray array];
    } // End of we had an error

    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData: resultsData
                                                                options: kNilOptions
                                                                  error: &error];
    if(nil != error)
    {
        [self.delegate applicationFinder: self receivedError: error];
        return [NSArray array];
    }

    NSArray * resultsArray = dictionary[@"results"];
    __block NSMutableArray * outputResults = [[NSMutableArray alloc] init];

    [resultsArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL * stop)
     {
         NSMutableArray * genreIds = [NSMutableArray arrayWithArray: obj[@"genreIds"]];

         NSAssert(nil != genreIds, @"Genres cannot be null.");
         NSAssert(genreIds.count != 0, @"Must have Genres. This has: %ld. (%@)", genreIds.count, genreIds);

         if([platform  isEqual: ApplicationTypeIOS])
         {
             [genreIds addObject: @(36)];
         }
         else if([platform  isEqual: ApplicationTypeOSX])
         {
             [genreIds addObject: @(39)];
         }
         else
         {
             NSAssert1(false, @"Unkown platform: %@", platform);
         }

         AWApplicationFinderEntry * entry = [[AWApplicationFinderEntry alloc] init];
         entry.applicationDeveloper = obj[@"artistName"];
         entry.applicationName      = obj[@"trackName"];
         entry.applicationId        = [NSNumber numberWithInt: [obj[@"trackId"] intValue]];
         entry.applicationType      = platform;
         entry.genreIds             = [genreIds copy];

         [outputResults addObject: entry];
     }];

    return [NSArray arrayWithArray: outputResults];
}

@end

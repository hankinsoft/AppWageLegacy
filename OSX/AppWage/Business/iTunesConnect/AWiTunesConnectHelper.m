//
//  AWiTunesConnectHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWiTunesConnectHelper.h"
#import "AWApplicationFinder.h"

@implementation AWiTunesConnectHelper

- (NSNumber*) vendorIdWithUser: (NSString*) user
                      password: (NSString*) password
                    vendorName: (NSString*__autoreleasing*) vendorName
                  loginSuccess: (BOOL*) loginSuccess
                         error: (NSError*__autoreleasing*) error
{
    *error =
        [NSError errorWithDomain: AWErrorDomain
                            code: AWErrorVendorLookupFailure
                        userInfo: @{NSLocalizedDescriptionKey:@"Vendor name and ID must currently be manually entered."}];

    return nil;
} // End of vendorIdWithUser:password:vendorName:error

- (NSArray*) applicationsForVendorName: (NSString*) vendorName
                                 error: (NSError*__autoreleasing*) outError
{
    NSMutableArray * results = [NSMutableArray array];

    // Add iOS and OSX
    [results addObjectsFromArray: [self applicationsForVendorName: vendorName
                                                         platform: ApplicationTypeIOS
                                                            error: outError]];

    [results addObjectsFromArray: [self applicationsForVendorName: vendorName
                                                         platform: ApplicationTypeOSX
                                                            error: outError]];

    return [NSArray arrayWithArray: results];
}

- (NSArray*) applicationsForVendorName: (NSString*) vendorName
                              platform: (NSNumber*) platform
                                 error: (NSError*__autoreleasing*) outError
{
    NSString * lookupURLString = [NSString stringWithFormat: @"https://itunes.apple.com/search?term=%@&entity=software%@",
                                  [vendorName stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                                  [ApplicationTypeOSX isEqual: platform] ? @"&entity=macSoftware" : @""];

    NSLog(@"Want to find applications with url: %@", lookupURLString);

    NSURL * targetUrl = [NSURL URLWithString: lookupURLString];
    NSError __autoreleasing * error = nil;
    NSData * htmlData = [[NSData alloc] initWithContentsOfURL: targetUrl
                                             options: 0
                                               error: &error];

    if(NULL != error)
    {
        NSLog(@"Unable to get applications data. %@.", error.localizedDescription);
        if(nil != outError)
        {
            *outError = error;
        } // End of ourError wa snil

        return [NSArray array];
    } // End of failed

    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData: htmlData
                                                                options: kNilOptions
                                                                  error: &error];

    if(nil != error)
    {
        if(nil != outError)
        {
            *outError = error;
        } // End of outError was not nil
        return [NSArray array];
    }

    NSArray * resultsArray = dictionary[@"results"];
    __block NSMutableArray * outputResults = [[NSMutableArray alloc] init];

    [resultsArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL * stop)
     {
         NSMutableArray * genreIds = [NSMutableArray arrayWithArray: obj[@"genreIds"]];
         
         NSAssert(nil != genreIds, @"Genres cannot be null.");
         NSAssert(genreIds.count != 0, @"Must have Genres. This has: %ld. (%@)", genreIds.count, genreIds);

         // Make sure vendor matches
         NSString * targetVendor = obj[@"artistName"];
         if(NSOrderedSame != [targetVendor caseInsensitiveCompare: vendorName]) return;

         if([platform isEqual: ApplicationTypeIOS])
         {
             [genreIds addObject: @(36)];
         }
         else if([platform isEqual: ApplicationTypeOSX])
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
} // End of applicationsForVendorId

- (AWApplicationFinderEntry*) detailsForApplicationId: (NSNumber*) applicationId
                                          countryCode: (NSString*) countryCode
                                                error: (NSError*__autoreleasing*) outError
{
    NSString * lookupURLString =
        [NSString stringWithFormat: @"https://itunes.apple.com/lookup?id=%@&cc=%@", applicationId, countryCode];

    NSLog(@"Want to find applications with url: %@", lookupURLString);

    NSURL * targetUrl = [NSURL URLWithString: lookupURLString];
    NSError __autoreleasing * error = nil;
    NSData * htmlData = [[NSData alloc] initWithContentsOfURL: targetUrl
                                                      options: 0
                                                        error: &error];

    if(NULL != error)
    {
        NSLog(@"Unable to get applications data. %@.", error.localizedDescription);
        if(NULL != outError)
        {
            *outError = error;
        } // End of outError was not null

        return nil;
    } // End of failed

    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData: htmlData
                                                                options: kNilOptions
                                                                  error: &error];

    if(NULL != error)
    {
        if(NULL != outError)
        {
            *outError = error;
        } // End of outError was not null

        return nil;
    }

    NSArray * resultsArray = dictionary[@"results"];

    __block AWApplicationFinderEntry * result = nil;
    [resultsArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger index, BOOL * stop)
     {
         NSMutableArray * genreIds = [NSMutableArray arrayWithArray: obj[@"genreIds"]];

         NSAssert(nil != genreIds, @"Genres cannot be null.");
         NSAssert(genreIds.count != 0, @"Must have Genres. This has: %ld. (%@)", genreIds.count, genreIds);

         NSMutableArray * newGenreArray = [[NSMutableArray alloc] initWithCapacity: genreIds.count];
         for(NSString * numberString in genreIds)
         {
             NSNumber * trueNumber = [NSNumber numberWithInteger: [numberString integerValue]];
             [newGenreArray addObject: trueNumber];
         } // End of genreIds

         // Make sure vendor matches
         NSString * softwareKind = obj[@"kind"];

         NSNumber * platform = nil;
         if(NSOrderedSame == [softwareKind caseInsensitiveCompare: @"mac-software"])
         {
             platform = ApplicationTypeOSX;
         }
         else if(NSOrderedSame == [softwareKind caseInsensitiveCompare: @"software"])
         {
             platform = ApplicationTypeIOS;
         }
         else
         {
             NSLog(@"Unknown softwarekind: %@", softwareKind);
         }

         result = [[AWApplicationFinderEntry alloc] init];
         result.applicationDeveloper = obj[@"artistName"];
         result.applicationName      = obj[@"trackName"];
         result.applicationId        = [NSNumber numberWithInt: [obj[@"trackId"] intValue]];
         result.applicationType      = platform;
         result.genreIds             = [newGenreArray copy];

         *stop = YES;
     }];

    return result;
} // End of detailsForApplicationId

@end

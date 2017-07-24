//
//  AWiTunesConnectHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/27/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWiTunesConnectHelper.h"
#import "AWApplicationFinder.h"
#import <GDataXML-HTML/GDataXMLNode.h>

@implementation AWiTunesConnectHelper

+ (NSData*) postRequest: (NSString*) requestType
                 userId: (NSString*) userId
            accessToken: (NSString*) accessToken
                command: (NSString*) command
              arguments: (NSString*) arguments
                headers: (NSDictionary**) headers
                  error: (NSError**) error
{
    NSString * urlString =
        [NSString stringWithFormat: @"https://reportingitc-reporter.apple.com/reportservice/%@/v1",
            requestType.lowercaseString];

    NSURL * requestURL = [NSURL URLWithString: urlString];

    NSData * reportData = nil;

    NSString * queryInput = command.mutableCopy;
    if(nil != arguments && 0 != arguments.length)
    {
        queryInput = [NSString stringWithFormat: @"%@, %@", queryInput, arguments];
    } // End of we have arguments
    
    queryInput = [NSString stringWithFormat: @"[p=Reporter.properties, %@]", queryInput];
    
    NSMutableDictionary * postDictionary = @{
                                             @"userid": userId,
                                             @"accesstoken": accessToken,
                                             @"version": @"2.1",
                                             @"mode": @"Robot.xml",
                                             @"queryInput": queryInput
                                             }.mutableCopy;
    
    NSData *jsonData =
        [NSJSONSerialization dataWithJSONObject: postDictionary
                                        options: 0
                                          error: error];

    NSMutableData * postData = [[NSMutableData alloc] init];
    [postData appendData: [@"jsonRequest=" dataUsingEncoding: NSUTF8StringEncoding]];
    [postData appendData: jsonData];

    for(NSUInteger retryCount = 0; retryCount < 5; ++retryCount)
    {
        NSMutableURLRequest *reportDownloadRequest =
        [NSMutableURLRequest requestWithURL: requestURL
                                cachePolicy: NSURLRequestReloadIgnoringCacheData
                            timeoutInterval: 30.0];
        
        [reportDownloadRequest setHTTPMethod: @"POST"];
        [reportDownloadRequest setValue: @"application/x-www-form-urlencoded"
                     forHTTPHeaderField: @"Content-Type"];
        
        [reportDownloadRequest setValue: @"java/1.7.0"
                     forHTTPHeaderField: @"User-Agent"];

        NSString * testString = [[NSString alloc] initWithData: postData
                                                      encoding: NSUTF8StringEncoding];
        
        // Used for debugging
        (void) testString;

        [reportDownloadRequest setHTTPBody: postData];
        [reportDownloadRequest setValue: @"gzip"
                     forHTTPHeaderField: @"Accept-Encoding"];
        
        NSHTTPURLResponse *response = nil;
        
        reportData =
            [NSURLConnection sendSynchronousRequest: reportDownloadRequest
                                  returningResponse: &response
                                              error: &(*error)];

        if(NULL != headers)
        {
            * headers = [response allHeaderFields];
        } // End of we have headers specified
        
        if(nil == *error)
        {
            break;
        } // End of no error
        
        // Clear our error and try again after a bit.
        *error = nil;
        [NSThread sleepForTimeInterval: 0.500];
    } // End of download failed
    
    return reportData;
} // End of postRequest

- (NSNumber*) vendorIdWithUser: (NSString*) user
                   accessToken: (NSString*) accessToken
                    vendorName: (NSString*__autoreleasing*) vendorName
                  loginSuccess: (BOOL*) loginSuccess
                         error: (NSError*__autoreleasing*) error
{
    NSData * vendorIdData =
        [AWiTunesConnectHelper postRequest: @"Sales"
                                    userId: user
                               accessToken: accessToken
                                   command: @"Sales.getVendors"
                                 arguments: @""
                                   headers: nil
                                     error: error];

    if(nil != *error)
    {
        return nil;
    } // End of we have an error

    NSString * vendorString =
        [[NSString alloc] initWithData: vendorIdData
                              encoding: NSUTF8StringEncoding];

    (void) vendorString;

    GDataXMLDocument * doc =
        [[GDataXMLDocument alloc] initWithData: vendorIdData
                                         error: error];

    if(nil != *error)
    {
        return nil;
    } // End of we have an error

    // NOTE: Its possible to have more than one vendor id. I'm not sure what others will be
    // looking for, so for now
    NSArray * vendorNodes =
        [doc.rootElement nodesForXPath: @"//Vendor"
                                 error: error];

    if(nil != *error)
    {
        return nil;
    } // End of we have an error

    GDataXMLElement * lastVendorIdElement = vendorNodes.lastObject;
    NSString * vendorStringValue = [lastVendorIdElement stringValue];
    NSNumber * vendorId = [NSNumber numberWithInteger: vendorStringValue.integerValue];

    // Get the vendor name (were only doing this if we received the vendorId).
    // We ignore the error. If this fails, we still have the vendorId. Thats the
    // main thing.
    NSError * vendorError = nil;
    *vendorName = [self accountNameForUser: user
                           withAccessToken: accessToken
                                     error: &vendorError];

    return vendorId;
} // End of vendorIdWithUser:accessToken:vendorName:loginSuccess:error

- (NSString*) accountNameForUser: (NSString*) user
                 withAccessToken: (NSString*) accessToken
                           error: (NSError*__autoreleasing*) error
{
    NSData * vendorIdData =
        [AWiTunesConnectHelper postRequest: @"Sales"
                                    userId: user
                               accessToken: accessToken
                                   command: @"Sales.getAccounts"
                                 arguments: @""
                                   headers: nil
                                     error: error];
    
    if(nil != *error)
    {
        return nil;
    } // End of we have an error

    NSString * vendorString =
        [[NSString alloc] initWithData: vendorIdData
                              encoding: NSUTF8StringEncoding];
    
    (void) vendorString;
    
    GDataXMLDocument * doc =
        [[GDataXMLDocument alloc] initWithData: vendorIdData
                                         error: error];
    
    if(nil != *error)
    {
        return nil;
    } // End of we have an error
    
    // NOTE: Its possible to have more than one vendor id. I'm not sure what others will be
    // looking for, so for now
    NSArray * vendorNodes =
        [doc.rootElement nodesForXPath: @"//Account/Name"
                                 error: error];

    if(nil != *error)
    {
        return nil;
    } // End of we have an error
    
    GDataXMLElement * lastAccountElement = vendorNodes.lastObject;
    NSString * accountStringValue = [lastAccountElement stringValue];

    return accountStringValue;
} // End of accountNameForUser:withAccessToken:error:

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

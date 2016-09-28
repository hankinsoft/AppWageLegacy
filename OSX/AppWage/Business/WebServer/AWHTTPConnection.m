//
//  AppWageHTTPConnection.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-05.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWHTTPConnection.h"
#import "HTTPJsonReponse.h"

#import "AWApplication.h"

@implementation AWHTTPConnection

#pragma mark -
#pragma mark Password

- (BOOL) isSecureServer
{
    return NO;
} // End of isSecureServer

- (BOOL)isPasswordProtected:(NSString *)path
{
    return NO;
} // End of isPasswordProtected

- (BOOL)useDigestAccessAuthentication
{
	// Digest access authentication is the default setting.
	// Notice in Safari that when you're prompted for your password,
	// Safari tells you "Your login information will be sent securely."
	//
	// If you return NO in this method, the HTTP server will use
	// basic authentication. Try it and you'll see that Safari
	// will tell you "Your password will be sent unencrypted",
	// which is strongly discouraged.
	
	return YES;
} // End of useDigestAccessAuthentication

- (NSString *)passwordForUser: (NSString *)username
{
	// You can do all kinds of cool stuff here.
	// For simplicity, we're not going to check the username, only the password.
	return @"secret";
}

#pragma mark -
#pragma mark Response

- (NSObject<HTTPResponse> *)httpResponseForMethod: (NSString *)method
                                              URI: (NSString *)path
{
	// Use HTTPConnection's filePathForURI method.
	// This method takes the given path (which comes directly from the HTTP request),
	// and converts it to a full path by combining it with the configured document root.
	//
	// It also does cool things for us like support for converting "/" to "/index.html",
	// and security restrictions (ensuring we don't serve documents outside configured document root folder).
    NSString * command = [path lastPathComponent];
    if(NSNotFound != [command rangeOfString: @"?"].location)
    {
        command = [command substringToIndex: [command rangeOfString: @"?"].location];
    }

	NSString *filePath = [self filePathForURI:path];
    NSLog(@"Command: %@, filePath: %@, Get: %@",
          command,
          filePath,
          [self parseGetParams]);

    if([command isEqualToString: @"getApplications"])
    {
        return [self getApplications];
    } // End of getApplications
    else if([command isEqualToString: @"getDashboard"])
    {
        return [self getDashboardWithType: 0];
    } // End of getApplications
    else if([command isEqualToString: @"getReviews"])
    {
        return [self getReviewsForApplicationIds: nil];
    } // End of getReviews
    else if([command isEqualToString: @"getRanks"])
    {
        return [self getRanksForApplicationIds: nil];
    } // End of getReviews

    NSError *error = nil;
    NSData *jsonData =
        [NSJSONSerialization dataWithJSONObject: @{@"hello": @"world"}
                                        options: (NSJSONWritingOptions) 0
                                          error: &error];

    HTTPJsonReponse * response = [[HTTPJsonReponse alloc] initWithData: jsonData];
    return response;
}

- (NSObject<HTTPResponse> *) getApplications
{
    NSArray * applications = [AWApplication allApplications];

    NSMutableArray * resultArray = [NSMutableArray array];

    [applications enumerateObjectsUsingBlock:
     ^(AWApplication*application, NSUInteger applicationId,BOOL*stop)
     {
         [resultArray addObject: @{
                                       @"name": application.name,
                                       @"productId": application.applicationId
                                       }];
     }];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: resultArray
                                                       options: (NSJSONWritingOptions)    0
                                                         error: &error];

    HTTPJsonReponse * response = [[HTTPJsonReponse alloc] initWithData: jsonData];
    return response;
} // End of getApplications

- (NSObject<HTTPResponse> *) getDashboardWithType: (NSUInteger) type
{
    NSArray * applications = [AWApplication allApplications];
    
    NSMutableArray * resultArray = [NSMutableArray array];

    [applications enumerateObjectsUsingBlock: ^(AWApplication*application, NSUInteger applicationId, BOOL *stop)
     {
         [resultArray addObject: @{
                                   @"name": application.name,
                                   @"productId": application.applicationId,
                                   @"badgeDisplay": [NSString stringWithFormat: @"%ld", applicationId]
                                   }];
     }];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: resultArray
                                                       options: (NSJSONWritingOptions)    0
                                                         error: &error];
    
    HTTPJsonReponse * response = [[HTTPJsonReponse alloc] initWithData: jsonData];
    return response;
} // End of getDashboardWithType

- (NSObject<HTTPResponse> *) getReviewsForApplicationIds: (NSSet*) applicationIds
{
    __block HTTPJsonReponse * response = nil;
#if TODO
    // Old code, needs to be updated to SQLite rather than coredata
    NSManagedObjectContext * localContext = [NSManagedObjectContext MR_newContext];
    [localContext performBlockAndWait: ^{
        @autoreleasepool {
            NSSet * targetAppIds = applicationIds;

            if(0 == targetAppIds.count)
            {
                targetAppIds = [[Application MR_findAllInContext: localContext] valueForKey: @"applicationId"];
            }

            NSPredicate * reviewsPredicate = [NSPredicate predicateWithFormat: @"%K IN %@",
                                                                             @"application.applicationId", targetAppIds];

            NSFetchRequest * fetchRequest = [Review MR_requestAllSortedBy: @"lastUpdated"
                                                                ascending: NO
                                                            withPredicate: reviewsPredicate
                                                                inContext: DEFAULT_CONTEXT];

            [fetchRequest setFetchLimit: 200];

            ///set more request things here
            NSArray * targetReviews = [Review MR_executeFetchRequest: fetchRequest
                                                           inContext: DEFAULT_CONTEXT];

            NSMutableArray * resultArray = [NSMutableArray array];
            
            [targetReviews enumerateObjectsUsingBlock: ^(Review *review, NSUInteger reviewIndex,BOOL*stop)
             {
                 [resultArray addObject: @{
                                           @"appleIdentifier":review.application.applicationId,
                                           @"title":review.title,
                                           @"author":review.reviewer,
                                           @"content":review.content,
                                           @"countryCode":review.country.countryCode,
                                           @"stars":review.stars,
                                           @"version":review.appVersion,
                                           @"date":[NSNumber numberWithFloat: [review.lastUpdated timeIntervalSince1970]]
                                           }];
             }];

            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject: resultArray
                                                               options: (NSJSONWritingOptions)    0
                                                                 error: &error];
            
            response = [[HTTPJsonReponse alloc] initWithData: jsonData];
        }
    }];
#endif
    return response;
} // End of getReviews

- (NSObject<HTTPResponse> *) getRanksForApplicationIds: (NSSet*) applicationIds
{
    __block HTTPJsonReponse * response = nil;

    return response;
} // End of getRanksForApplicationIds

@end

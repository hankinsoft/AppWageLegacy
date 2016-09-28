//
//  CollectionListener.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-03.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "CollectionListener.h"
#import <AFNetworking/AFNetworking.h>
#import "AWRankCollectionOperation.h"
#import "AWReviewCollectorOperation.h"
#import "AWReportCollectionOperation.h"

@interface CollectionListener()<AWReviewCollectionOperationDelegate, AWReportCollectionDelegate>
{
    
}
@end

@implementation CollectionListener
{
    AFHTTPSessionManager                    * internalManager;
    NSOperationQueue                        * internalOperationQueue;

    // Operation progress
    NSUInteger                              operationsRemaining, totalOperations;
}

- (BOOL)listener:(NSXPCListener *)listener
shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    [newConnection setExportedInterface: [NSXPCInterface interfaceWithProtocol:@protocol(CollectionProtocol)]];
    [newConnection setExportedObject: self];
    self.xpcConnection = newConnection;

    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol: @protocol(CollectionProgressProtocol)];

    // connections start suspended by default, so resume and start receiving them
    [newConnection resume];

    return YES;
}

- (void) collectRanksWithBaseURL: (NSString*) baseURL
                 appsWeCareAbout: (NSArray*) appsWeCareAbout
                      targetUrls: (NSArray *) temp
                           reply: (void (^)(NSString *g))reply
{
    internalManager = [[AFHTTPSessionManager alloc] initWithBaseURL: [NSURL URLWithString: baseURL]];
    [internalManager.operationQueue setSuspended: YES];
    internalManager.operationQueue.maxConcurrentOperationCount = 5;
    internalManager.responseSerializer = [AFJSONResponseSerializer serializer];

    operationsRemaining = totalOperations = temp.count;

    [temp enumerateObjectsUsingBlock:
     ^(NSDictionary * tempDetails, NSUInteger countryDetailsIndex, BOOL * stop)
     {
         [internalManager GET: tempDetails[@"chartUrl"]
                   parameters: nil
                     progress: nil
                      success: ^(NSURLSessionDataTask *task, id responseObject)
          {
              operationsRemaining--;
              NSUInteger numberOfFinishedOperations = totalOperations - operationsRemaining;
              dispatch_async(dispatch_get_global_queue(0, 0), ^{

                  [[self.xpcConnection remoteObjectProxy] updateProgress: (double)numberOfFinishedOperations / (double)totalOperations * 100
                                                          progressString: [NSString stringWithFormat: @"Collecting ranks %ld of %ld",
                                                                           numberOfFinishedOperations, totalOperations]];

                  NSArray * ranks =
                    [AWRankCollectionOperation processRankDictionary: responseObject
                                                   appsWeCareAbout: appsWeCareAbout
                                                         countryId: tempDetails[@"countryId"]
                                                           chartId: tempDetails[@"chartId"]
                                                           genreId: tempDetails[@"genreId"]
                     ];

                  if(ranks.count > 0)
                  {
                      [[self.xpcConnection remoteObjectProxy] receivedRanks: ranks];
                  }
                  
                  if(0 == operationsRemaining)
                  {
                      [[self.xpcConnection remoteObjectProxy] completedRankCollection];
                  }
              });
          }
          failure: ^(NSURLSessionDataTask *task, NSError *error)
          {
              operationsRemaining--;
              NSUInteger numberOfFinishedOperations = totalOperations - operationsRemaining;
              dispatch_async(dispatch_get_global_queue(0, 0), ^{
                  [[self.xpcConnection remoteObjectProxy] updateProgress: (double)numberOfFinishedOperations / (double)totalOperations * 100
                                                          progressString: [NSString stringWithFormat: @"Collecting ranks %ld of %ld",
                                                                           numberOfFinishedOperations, totalOperations]];
                  if(0 == operationsRemaining)
                  {
                      [[self.xpcConnection remoteObjectProxy] completedRankCollection];
                  }
              });
          }];
     }];
    [internalManager.operationQueue setSuspended: NO];
    
    // nil is a valid return value.
    reply(@"This is a reply!");
}

- (void) collectReviewsWithDetails: (NSArray*) reviewCollectionDetails
{
    NSLog(@"Want to collect reviews");

    // Create our queue
    internalOperationQueue = [[NSOperationQueue alloc] init];
    internalOperationQueue.name = @"ReviewCollectionQueue";
    [internalOperationQueue setMaxConcurrentOperationCount: 1];
    [internalOperationQueue setSuspended: YES];

    // Setup our totals.
    operationsRemaining = totalOperations = reviewCollectionDetails.count;

    [reviewCollectionDetails enumerateObjectsUsingBlock: ^(NSDictionary * currentDetails, NSUInteger index, BOOL * stop)
     {
         AWReviewCollectorOperation * reviewCollectionOperation =
         [[AWReviewCollectorOperation alloc] initWithApplicationDetails: currentDetails[@"applicationDetails"]
                                                       countryDetails: currentDetails[@"countryDetails"]
                                                                 page: 1];
         
         reviewCollectionOperation.delegate     = self;
         
         [internalOperationQueue addOperation: reviewCollectionOperation];
     }];

    [internalOperationQueue setSuspended: NO];
}

- (void) importReportsFromURLS: (NSArray*) urls
{
    // Create our queue
    internalOperationQueue = [[NSOperationQueue alloc] init];
    internalOperationQueue.name = @"ReviewCollectionQueue";
    [internalOperationQueue setMaxConcurrentOperationCount: 1];
    [internalOperationQueue setSuspended: YES];

    // Setup our counts
    operationsRemaining = 1;

     ReportCollectionOperation * reportCollectionOperation = [[ReportCollectionOperation alloc] init];
    reportCollectionOperation.importFromURLDetailsArray = urls;
     reportCollectionOperation.delegate = self;
     [internalOperationQueue addOperation: reportCollectionOperation];

    // Start it up
    [internalOperationQueue setSuspended: NO];
}

- (void) collectReportsForAccounts: (NSData*) accountData
{
    NSArray * accounts = [NSKeyedUnarchiver unarchiveObjectWithData: accountData];

    // Create our queue
    internalOperationQueue = [[NSOperationQueue alloc] init];
    internalOperationQueue.name = @"ReviewCollectionQueue";
    [internalOperationQueue setMaxConcurrentOperationCount: 1];
    [internalOperationQueue setSuspended: YES];

    // Setup our counts
    operationsRemaining = totalOperations = accounts.count;

    [accounts enumerateObjectsUsingBlock: ^(AccountDetails * accountDetails, NSUInteger index, BOOL * stop)
     {
         ReportCollectionOperation * reportCollectionOperation = [[ReportCollectionOperation alloc] init];
         reportCollectionOperation.accountDetails = accountDetails;
         reportCollectionOperation.delegate = self;
         [internalOperationQueue addOperation: reportCollectionOperation];
     }];

    // Start it up
    [internalOperationQueue setSuspended: NO];
} // End of collectReportsForAccounts

- (void) setSuspended: (BOOL) suspended
{
    if(suspended)
    {
        [internalManager.operationQueue setSuspended: YES];
        [internalOperationQueue setSuspended: YES];
    }
    else
    {
        [internalManager.operationQueue setSuspended: NO];
        [internalOperationQueue setSuspended: NO];
    }
}

- (void) cancel
{
    [internalOperationQueue setSuspended: YES];
    [internalManager.operationQueue setSuspended: YES];

    [internalOperationQueue cancelAllOperations];
    [[internalManager operationQueue] cancelAllOperations];
} // End of cancel

#pragma mark -
#pragma mark ReviewCollectionDelegate

- (void) reviewCollectionOperationDidStart: (AWReviewCollectorOperation*) reviewCollectionOperation
                      withApplicationNamed: (NSString*) applicationName
{
    [[self.xpcConnection remoteObjectProxy] updateProgress: ((double)(totalOperations - operationsRemaining) / (double)totalOperations) * 100
                                            progressString: [NSString stringWithFormat: @"Collecting reviews for %@", applicationName]];
} // End of didStart

- (void) reviewCollectionOperationDidFinish: (AWReviewCollectorOperation *) reviewCollectionOperation
{
    NSAssert(0 != operationsRemaining, @"reviewCollectionOperationDidFinish - OperationsRemaining should not be zero yet. Is %ld.", operationsRemaining);

    // Decrease our operations.
    --operationsRemaining;

    // Finished.
    if(0 == operationsRemaining)
    {
        [[self.xpcConnection remoteObjectProxy] completedReviewCollection];
    } // End of no more operations
} // End of operationFinished

- (void) reviewCollectionOperation: (AWReviewCollectorOperation *) reviewCollectionOperation
                      hasMorePages: (NSUInteger) totalPages
{
    // Increase our operations
    totalOperations += (totalPages - 1);
    operationsRemaining += (totalPages - 1);

    // Add an operation for each of our pages
    for(NSUInteger currentPage = 2; currentPage <= totalPages; ++currentPage)
    {
        AWReviewCollectorOperation * newReviewCollectionOperation = [[AWReviewCollectorOperation alloc] initWithReviewCollectionOperation: reviewCollectionOperation page: currentPage];
        
        newReviewCollectionOperation.delegate     = self;
        
        [internalOperationQueue addOperation: newReviewCollectionOperation];
    }
}

- (void) reviewCollectionOperationReceived403: (AWReviewCollectorOperation *)reviewCollectionOperation
{
    [internalOperationQueue setSuspended: YES];
    [internalOperationQueue cancelAllOperations];

    [[self.xpcConnection remoteObjectProxy] reviewCollectionRecevied403: reviewCollectionOperation.reviewURL];
}

- (void) reviewCollectionOperation: (AWReviewCollectorOperation *)reviewCollectionOperation
                        hasReviews: (NSArray*) reviews;
{
    [[self.xpcConnection remoteObjectProxy] receivedReviews: reviews];
} // End of receivedReview

#pragma mark -
#pragma mark ReportCollectionDelegate

- (void) reportCollectionOperationStarted: (ReportCollectionOperation*) reportCollectionOperation
{
    NSLog(@"Report collection started");
}

- (void) reportCollectionOperationFinished: (ReportCollectionOperation*) reportCollectionOperation
{
    NSLog(@"Report collection finished");
    
    --operationsRemaining;

    // Figure out if we have no operations left
    if(0 != operationsRemaining)
    {
        return;
    }

    NSArray * sortedDates = [reportCollectionOperation.uniqueDates.allObjects sortedArrayUsingSelector: @selector(compare:)];

    id proxy = [self.xpcConnection remoteObjectProxy];
    [proxy completedReportCollection: sortedDates];
} // End of reportCollectionOperationFinished

- (BOOL) reportCollectionOperation: (ReportCollectionOperation*) reportCollectionOperation
        shouldCollectReportForDate: (NSDate*) importDate
                 internalAccountId: (NSString*) internalAccountId
{
    __block BOOL retunCode = NO;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[self.xpcConnection remoteObjectProxy] shouldCollectReportForDate: importDate
                                                     internalAccountId: internalAccountId
                                                                 reply: ^(BOOL shouldCollect)
     {
         retunCode = shouldCollect;
         dispatch_semaphore_signal(sema);
     }];
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return retunCode;
}

- (void) reportProgressChanged: (NSString*) title
                      progress: (double) progress
{
    // Set our progress
    double currentProgress = progress / (0 == operationsRemaining ? 1 : operationsRemaining);

    [[self.xpcConnection remoteObjectProxy] updateProgress: currentProgress
                                            progressString: title];
}

- (void) logError: (NSString*) errorToLog
{
    [[self.xpcConnection remoteObjectProxy] logError: errorToLog];
}

- (NSString*) reportCollectionNeedsInternalAccountIdForVendorId: (NSNumber*) vendorId
                                                     vendorName: (NSString*) vendorName
{
    __block NSString * result = nil;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[self.xpcConnection remoteObjectProxy] reportCollectionNeedsInternalAccountIdForVendorId: vendorId
                                                                                   vendorName: vendorName
                                                                                        reply: ^(NSString * internalAccountId)
     {
         result = internalAccountId;
         dispatch_semaphore_signal(sema);
     }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return result;
} // End of reportCollectionNeedsInternalAccountIdForVendorId:vendorName:

- (BOOL) reportCollectionOperationCreateApplicationIfNotExists: (NSNumber*) applicationId
                                                  productTitle: (NSString*) productTitle
                                                   countryCode: (NSString*) countryCode
                                                     accountId: (NSString*) accountId
{
    __block BOOL retunCode = NO;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[self.xpcConnection remoteObjectProxy] reportCollectionOperationCreateApplicationIfNotExists: applicationId
                                                                                     productTitle: productTitle
                                                                                      countryCode: countryCode
                                                                                        accountId: accountId
            reply: ^(BOOL appExists)
            {
                retunCode = appExists;
                dispatch_semaphore_signal(sema);
            }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return retunCode;
}

- (BOOL) createProductIfRequiredWithDetails: (NSDictionary*) productDetails
                              applicationId: (NSNumber*) applicationId
{
    __block BOOL retunCode = NO;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[self.xpcConnection remoteObjectProxy] createProductIfRequiredWithDetails: productDetails
                                                                 applicationId: applicationId
                                                                         reply: ^(BOOL created)
     {
         retunCode = created;
         dispatch_semaphore_signal(sema);
     }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return retunCode;
}

- (void) reportCollectionOperation: (ReportCollectionOperation*) reportCollectionOperation
                   receivedReports: (NSArray*) reports
{
    [[self.xpcConnection remoteObjectProxy] receivedReports: reports];
}

@end

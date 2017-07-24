//
//  AWCollectionOperationQueue.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/23/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWCollectionOperationQueue.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWApplicationFinder.h"

#import "AWReportCollectionOperation.h"
#import "AWReviewCollectorOperation.h"
#import "AWRankCollectionOperation.h"

#import "AWApplicationListTreeViewController.h"

#import "AWReviewBulkImporter.h"
#import "AWRankBulkImporter.h"

#import "AWAccount.h"
#import "AWAccountHelper.h"

#import "AWEmailHelper.h"

#import "CollectionListener.h"
#import "AWiTunesConnectHelper.h"

#import "AWCacheHelper.h"
#import "AWCountry.h"

@interface AWCollectionOperationQueue()<CollectionProgressProtocol>
{
    BOOL                            enabled;

    CollectionType                  currentCollectionType;

    NSMutableArray                  * collectionTaskQueue;

    NSUInteger                      reviewsWhenStartingCollection;

    NSTimer                         * rankCollectionTimer;
    NSTimer                         * reviewCollectionTimer;
    NSTimer                         * reportCollectionTimer;

    NSString                        * previousState;

    NSSet                           * reviewCollectionTargetAppIds;
    NSSet                           * rankCollectionTargetAppIds;

	NSXPCConnection                 * xpcConnection;
	id<CollectionProtocol>          iTunesCollector;
}

@end

@implementation AWCollectionOperationQueue
{
    NSSet         * previousReportDates;
}

@synthesize currentProgress, currentStateString;

- (BOOL) isRunning
{
    return currentCollectionType != CollectionTypeIdle;
}

- (NSString*) displayForCollectionType: (CollectionType) collectionType
{
    switch(collectionType)
    {
        case CollectionTypeIdle: return enabled ? NSLocalizedString(@"Idle", nil) : NSLocalizedString(@"Paused", nil);
        case CollectionTypePreparing: return NSLocalizedString(@"Preparing", nil);

        case CollectionTypeReports: return NSLocalizedString(@"Reports", nil);
        case CollectionTypeReviews: return NSLocalizedString(@"Reviews", nil);
        case CollectionTypeRankings: return NSLocalizedString(@"Rankings", nil);

        case CollectionTypeAdmob: return @"AdMob";
        case CollectionTypeGoogleAnalaytics: return @"Google Analytics";
    } // End of collectionType
}

+ (NSString*) progressNotificationName
{
    return @"ReviewsCollection-CollectionProgressChanged";
}

+ (NSString*) newReviewsNotificationName
{
    return @"ReviewsCollection-CollectionHasNewReviews";
}

+ (NSString*) newRanksNotificationName
{
    return @"AWCollectionOperationQueue-NewRanks";
}

+ (NSString*) newReportsNotificationName
{
    return @"AWCollectionOperationQueue-NewReports";
}

+(AWCollectionOperationQueue*)sharedInstance
{
    static dispatch_once_t pred;
    static AWCollectionOperationQueue *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWCollectionOperationQueue alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        currentCollectionType             = CollectionTypeIdle;
        reviewsWhenStartingCollection     = 0;
        currentProgress                   = 0;
        currentStateString                = NSLocalizedString(@"Idle", nil);

        collectionTaskQueue               = [NSMutableArray array];
    }

    return self;
}

- (void) cancelAllOperations: (BOOL) clearQueuedEntries
{
    // Set our state as cancelled.
    currentCollectionType   = CollectionTypeIdle;

    NSLog(@"Cancelling all operations. %@clearing queued entries.",
          clearQueuedEntries ? @"Not " : @"");
    self.currentStateString = NSLocalizedString(@"Cancelling", nil);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [iTunesCollector cancel];

        @synchronized(collectionTaskQueue)
        {
            // Sleep for 1/2 a second
            // Give us time to make sure any operations are no longer running.
            [NSThread sleepForTimeInterval: 0.500];
            self.currentStateString = NSLocalizedString(@"Cancelling", nil);

            // Add final entries to ensure nothing else gets added.
            [[AWRankBulkImporter sharedInstance] addNull];
            [[AWReviewBulkImporter sharedInstance] addReview: [NSNull null]];

            // Set our state
            self.currentStateString = [self displayForCollectionType: CollectionTypeIdle];

            currentCollectionType   = CollectionTypeIdle;
            currentProgress         = 0;

            if(clearQueuedEntries)
            {
                [collectionTaskQueue removeAllObjects];
            }
            else
            {
                // Is there anything new to do?
                [self processCollectionTaskQueue];
            } // End of else
        }
    });
}

- (void) disableCollectionStartup
{
    // Store our previous state
    previousState = self.currentStateString;

    NSLog(@"Collections have been disabled.");
    self.currentStateString = NSLocalizedString(@"Paused", nil);

    // Suspend until done
    [iTunesCollector setSuspended: YES];

    enabled = NO;
} // End of disableCollectionStartup

- (void) enableCollectionStartup
{
    NSLog(@"Collections have been enabled.");
    enabled = YES;
    self.currentStateString = previousState;

    // Let us no longer be suspended
    [iTunesCollector setSuspended: NO];

    @synchronized(collectionTaskQueue)
    {
        if(![self inProgress])
        {
            if(![self processCollectionTaskQueue])
            {
                self.currentStateString = NSLocalizedString(@"Idle", nil);
            }
        }
    }
} // End of enableCollectionStartup

- (void) addTask: (CollectionType) collectionType
{
    NSLog(@"addTask called with type: %ld. Current state is: %@",
          (NSUInteger)collectionType,
          [self displayForCollectionType: currentCollectionType]);

    // Make sure a task can only be added once.
    @synchronized(collectionTaskQueue)
    {
        NSNumber * wrapper = [NSNumber numberWithInt: collectionType];

        if(![collectionTaskQueue containsObject: wrapper])
        {
            [collectionTaskQueue addObject: wrapper];
        } // End of queue entry is done.

        NSLog(@"Collection queue now contains: %@", collectionTaskQueue);
    } // End of synchronized.
} // End of addTask

- (BOOL) inProgress
{
    return CollectionTypeIdle != currentCollectionType;
}

- (BOOL) processCollectionTaskQueue
{
    // If we are already in progress, then don't do anything
    if([self inProgress])
    {
        // We are in progress, so return yes
        return YES;
    } // End of we are already in process

    // Should be synchronized before entering this method.
    if(!enabled)
    {
        NSLog(@"processCollectionTaskQueue - not enabled. Not starting any tasks.");
        return NO;
    } // End of !enabled

    if(0 == collectionTaskQueue.count)
    {
        NSLog(@"processCollectionTaskQueue - No entries. Not doing anything.");
        return NO;
    }

    NSNumber * task = collectionTaskQueue[0];
    if(nil == task)
    {
        NSLog(@"processCollectionTaskQueue - No tasks. Not doing any work.");
        return NO;
    } // End of no task

    // Remove our object.
    [collectionTaskQueue removeObject: task];

    // Set our collection type to be preparing
    currentCollectionType = CollectionTypePreparing;

    dispatch_async(dispatch_get_global_queue(0, 0),  ^{
        switch(task.integerValue)
        {
            case CollectionTypeRankings: [self loadRanks]; break;
            case CollectionTypeReviews:  [self loadReviews]; break;
            case CollectionTypeReports:  [self loadReports: nil]; break;
            default:
                NSLog(@"ERROR - Unknown task type. %ld.", task.integerValue);
                break;
        } // End of task switch
    });

    return true;
} // End of processCollectionTaskQueue

- (void) queueReportCollectionWithTimeInterval: (NSTimeInterval) timeInterval
{
    [reportCollectionTimer invalidate];
    reportCollectionTimer = nil;

    if(-1 == timeInterval)
    {
        return;
    }

    NSLog(@"Queuing reports in %0.0f hours.", timeInterval / timeIntervalHour);
    dispatch_async(dispatch_get_main_queue(), ^{
        self->reportCollectionTimer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                               target: self
                                                             selector: @selector(doQueueReportCollection)
                                                             userInfo: nil
                                                              repeats: NO];
    });

}

- (void) doQueueReportCollection
{
    NSLog(@"doQueueReportCollection called");

    @synchronized(collectionTaskQueue)
    {
        [self addTask: CollectionTypeReports];

        // If we are not in progress, then process the queue
        if(![self inProgress])
        {
            [self processCollectionTaskQueue];
        }
    } // End of synchronzied
}

- (void) queueRankCollectionWithTimeInterval: (NSTimeInterval) timeInterval
                             specifiedAppIds: (NSSet*) specifiedAppIds
{
    [rankCollectionTimer invalidate];
    rankCollectionTimer = nil;

    if(-1 == timeInterval)
    {
        rankCollectionTargetAppIds = nil;
        return;
    }

    NSLog(@"Queuing rank in %0.0f hours.", timeInterval / timeIntervalHour);
    rankCollectionTargetAppIds = specifiedAppIds;
    if([[[NSProcessInfo processInfo] arguments] containsObject: @"-testRanks"] && timeInterval > 5)
    {
        NSLog(@"TestRanks launch argument specified. Ranks will be queued in five seconds.");
        timeInterval = 5;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        rankCollectionTimer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                               target: self
                                                             selector: @selector(doQueueRankCollection)
                                                             userInfo: nil
                                                              repeats: NO];
    });
}

- (void) doQueueRankCollection
{
    NSLog(@"doQueueRankCollection called");

    @synchronized(collectionTaskQueue)
    {
        [self addTask: CollectionTypeRankings];

        // If we are not in progress, then process the queue
        if(![self inProgress])
        {
            [self processCollectionTaskQueue];
        }
    } // End of synchronzied
}

- (void) loadRanks
{
    NSLog(@"loadRanks entered on %@ thread.", [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND");
    NSAssert(![NSThread isMainThread], @"Load Ranks should not be called on the main thread.");

    currentCollectionType = CollectionTypeRankings;
    self.currentStateString = NSLocalizedString(@"Preparing Ranks", nil);

    // Clear the timers
    [rankCollectionTimer invalidate];
    rankCollectionTimer = nil;

    // Get all of our apps.
    NSPredicate * applicationPredicate = nil;
    if(0 == rankCollectionTargetAppIds.count)
    {
        applicationPredicate = [NSPredicate predicateWithValue: YES];
    }
    else
    {
        applicationPredicate = [NSPredicate predicateWithFormat: @"applicationId IN %@", rankCollectionTargetAppIds];
    }

    __block NSArray * applications = [[AWApplication allApplications] filteredArrayUsingPredicate: applicationPredicate];

    @autoreleasepool {
        NSPredicate * predicate = [NSPredicate predicateWithFormat: @"shouldCollectRanks = TRUE"];
        NSArray * shouldCollectRankCountries = [[AWCountry allCountries] filteredArrayUsingPredicate: predicate];
        NSArray * countryDetailsArray = [shouldCollectRankCountries valueForKeyPath: @"countryCode"];

        NSArray * applicationIds = [applications valueForKey: @"applicationId"];
        applications = nil;

        NSArray * temp = [AWGenreHelper chartsForApplicationIds: applicationIds
                                                      countries: countryDetailsArray];
        
        if(temp.count > 0)
        {
            NSLog(@"loadRanks - read to load %ld ranks.", temp.count);
            
            NSURL * baseURL = [NSURL URLWithString: @"https://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/"];
            
            // Create our connection
            [self updateCollectionInterface];
            
            [iTunesCollector collectRanksWithBaseURL: baseURL.path
                                     appsWeCareAbout: applicationIds
                                          targetUrls: temp
                                               reply: ^(NSString * g)
             {
                 NSLog(@"Started loading ranks.");
             }];
        }
        else
        {
            currentCollectionType = CollectionTypeIdle;
            NSLog(@"No operations to process. Doing nothing.");
            
            // We are now idle
            self.currentStateString = [self displayForCollectionType: CollectionTypeIdle];
        }
    } // End of @autoreleasepool
} // End of loadRanks

- (void) rankCollectionCompleted
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"rankCollectionOperationFinished - No operations left.");

        // Forces an insert.
        [[AWRankBulkImporter sharedInstance] addNull];

        dispatch_async(dispatch_get_main_queue(), ^{
            // We have new ranks. Fire the notification.
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newRanksNotificationName]
                                                                object: nil];

            NSTimeInterval timeInterval = -1;
            if(0 != [[AWSystemSettings sharedInstance] collectRankingsEveryXHours])
            {
                timeInterval = ([[AWSystemSettings sharedInstance] collectRankingsEveryXHours] * 60 * 60);
            }

            // Queue it up.
            [self queueRankCollectionWithTimeInterval: timeInterval specifiedAppIds: nil];
            [self collectionTaskFinished];
        });
    });
}

- (void) reviewCollectionCompleted
{
    // Forces an insert.
    [[AWReviewBulkImporter sharedInstance] addReview: [NSNull null]];

    __block NSUInteger totalReviews = 0;
    @autoreleasepool {
        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete all
            NSString * countQuery = @"SELECT COUNT(*) FROM review";

            FMResultSet * results = [database executeQuery: countQuery];
            while([results next])
            {
                totalReviews = [results intForColumnIndex: 0];
            } // End of loop
        }];
    } // End of @autoreleasepool

    NSUInteger newReviews = totalReviews - reviewsWhenStartingCollection;

    NSLog(@"We have %ld new reviews.", newReviews);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // If we have new reviews, then we need to fire a code notification
        // and also an actual user notification.
        if(newReviews > 0)
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = NSLocalizedString(@"New reviews!", nil);
            notification.informativeText = [NSString stringWithFormat: @"You have %lu new review%@",
                                            newReviews, 1 == newReviews ? @"" : @"s"];

            notification.soundName = NSUserNotificationDefaultSoundName;

            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        } // End of we had new reviews

        // We have new reviews. Fire the notification.
        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                            object: nil];

        NSTimeInterval collectionTimeInterval = -1;
        
        if(0 != [[AWSystemSettings sharedInstance] collectReviewsEveryXHours])
        {
            collectionTimeInterval = ([[AWSystemSettings sharedInstance] collectReviewsEveryXHours] * 60 * 60);
        }

        // Queue it up.
        [self queueReviewCollectionWithTimeInterval: collectionTimeInterval specifiedAppIds: nil];
        [self collectionTaskFinished];
    }); // End of dispatch_async
}

- (void) queueReviewCollectionWithTimeInterval: (NSTimeInterval) timeInterval
                               specifiedAppIds: (NSSet*) specifiedAppIds
{
    NSLog(@"queueReviewCollectionWithTimeInterval called");

    [reviewCollectionTimer invalidate];
    reviewCollectionTimer = nil;

    if(-1 == timeInterval)
    {
        NSLog(@"AWReviewCollection timeinterval set to -1 (manual). Not queuing.");
        reviewCollectionTargetAppIds = nil;
        return;
    } // End of timeInterval

    NSLog(@"AWReviewCollection queuing in %0.0f hours.", timeInterval / timeIntervalHour);
    reviewCollectionTargetAppIds = [specifiedAppIds copy];

    dispatch_async(dispatch_get_main_queue(), ^{
        reviewCollectionTimer = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                                 target: self
                                                               selector: @selector(doQueueReviewCollection)
                                                               userInfo: nil
                                                                repeats: NO];
    });
}

- (void) doQueueReviewCollection
{
    NSLog(@"doQueueReviewCollection");

    @synchronized(collectionTaskQueue)
    {
        [self addTask: CollectionTypeReviews];

        // If we are not in progress, then process the queue
        if(![self inProgress])
        {
            [self processCollectionTaskQueue];
        }
    } // End of synchronzied
}

- (void) loadReviews
{
    NSLog(@"loadReviews entered on %@ thread.", [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND");

    currentCollectionType = CollectionTypeReviews;
    self.currentStateString = NSLocalizedString(@"Preparing Reviews", nil);

    // Clear the collection timer
    [reviewCollectionTimer invalidate];
    reviewCollectionTimer = nil;

    NSArray * countries    = [AWCountry allCountries];

    @autoreleasepool {
        // Figure out how many reviews we have when starting.
        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete all
            NSString * countQuery = @"SELECT COUNT(*) FROM review";
            
            FMResultSet * results = [database executeQuery: countQuery];
            while([results next])
            {
                reviewsWhenStartingCollection = [results intForColumnIndex: 0];
            } // End of loop
        }];

        NSLog(@"loadReviews had %ld reviews when started loading.", reviewsWhenStartingCollection);

        NSPredicate * reviewDownloadPredicate = nil;

        // If we have no applications specified, then we will load any apps that have shouldCollectReviews set to be true.
        if(0 == reviewCollectionTargetAppIds.count)
        {
            reviewDownloadPredicate = [NSPredicate predicateWithFormat: @"shouldCollectReviews = YES"];
        }
        else
        {
            reviewDownloadPredicate = [NSPredicate predicateWithFormat: @"applicationId IN %@",
                                       reviewCollectionTargetAppIds];
        }

        NSArray * applications;
        applications = [[AWApplication allApplications] filteredArrayUsingPredicate: reviewDownloadPredicate];

        if(applications.count * countries.count > 0)
        {
            NSLog(@"loadReviews - There are %ld entries.", applications.count * countries.count);

            NSMutableArray * detailsForOperations = [NSMutableArray array];

            [applications enumerateObjectsUsingBlock:
             ^(AWApplication * application, NSUInteger index, BOOL * stop)
             {
                 NSString * appName = application.name;

                 NSDictionary * applicationDetails =
                 @{
                   @"name":appName,
                   @"applicationId": application.applicationId
                 };

                 [countries enumerateObjectsUsingBlock: ^(AWCountry* country, NSUInteger index, BOOL * stop)
                  {
                      NSDictionary * countryDetails =
                      @{
                        @"countryCode": country.countryCode,
                        @"name": country.name
                      };

                      [detailsForOperations addObject: @{
                                                         @"applicationDetails":applicationDetails,
                                                         @"countryDetails":countryDetails
                                                         }];
                  }]; // End of country loop
             }]; // End of application loop

            // Update our collectionInterface
            [self updateCollectionInterface];

            // Start the review collection
            [iTunesCollector collectReviewsWithDetails: [detailsForOperations copy]];
        } // End of we have ranks to collect
        else
        {
            NSLog(@"loadReviews - No applications to load. Reviews collection will not run.");
            currentCollectionType = CollectionTypeIdle;

            // We are now idle
            self.currentStateString = [self displayForCollectionType: CollectionTypeIdle];
        } // End of nothing to load
    } // End of autoreleasepool
}

- (void) loadReports: (NSArray*) withExistingReports
{
    currentCollectionType = CollectionTypeReports;

    NSLog(@"loadReports entered on %@ thread.", [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND");

    self.currentStateString = NSLocalizedString(@"Preparing Reports", nil);

    // Clear the collection timer
    [reportCollectionTimer invalidate];
    reportCollectionTimer = nil;

    if(nil == withExistingReports)
    {
        previousReportDates = [self getPreviousReportDates];

        @autoreleasepool {
            NSArray * accounts = [AWAccount allAccounts];
            NSMutableSet * collectingAccountDetails = [NSMutableSet set];

            [accounts enumerateObjectsUsingBlock:
             ^(AWAccount * account, NSUInteger accountIndex, BOOL * stop)
             {
                 AccountDetails * accountDetails = [[AWAccountHelper sharedInstance] accountDetailsForInternalAccountId: account.internalAccountId];

                 // If we have an account with a username and access token specified, then we can collect it.
                 if(nil != accountDetails &&
                    0 != [accountDetails.accountUserName length] &&
                    0 != [accountDetails.accountAccessToken length])
                 {
                     [collectingAccountDetails addObject: accountDetails];
                 } // End of we had a username and access token specified.
             }];

            if(collectingAccountDetails.count > 0)
            {
                [self updateCollectionInterface];

                NSArray * accounts = [collectingAccountDetails allObjects];

                // Have to encode our data. Previously I attempted to add
                // AccountDetails to the proxy object, but couldnt figure it out.
                NSData * data = [NSKeyedArchiver archivedDataWithRootObject: accounts];

                if(nil != data)
                {
                    // Start the reports collection
                    [iTunesCollector collectReportsForAccounts: data];
                } // End of we have jsonData
            } // End of we have reports to collect
            else
            {
                NSLog(@"No accounts. Report collection will not run.");
                currentCollectionType = CollectionTypeIdle;

                // Set our state
                self.currentStateString = [self displayForCollectionType: CollectionTypeIdle];
            } // End of nothing to load
        } // End of autorelease pool
    } // End of we had no specified reports
    else
    {
        previousReportDates = [self getPreviousReportDates];
        [self updateCollectionInterface];

        // Start the reports collection
        [iTunesCollector importReportsFromURLS: withExistingReports];
    } // End of make us idle
}

- (NSSet*) getPreviousReportDates
{
     NSMutableSet * _reportDates = [NSMutableSet set];

    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         FMResultSet * results = [salesDatabase executeQuery: @"SELECT DISTINCT (beginDate || '-' || endDate) AS dateRange FROM salesReport"];

         while([results next])
         {
             [_reportDates addObject: [results objectForColumnName: @"dateRange"]];
         } // End of while loop
     }];

    return _reportDates.copy;
} // End of setPreviousDates

- (void) updateCollectionInterface
{
    NSSet * classes = [NSSet setWithObjects:
                       [AWRankBulkImporterEntry class],
                       [NSArray class],
                       nil];

    NSXPCInterface * xpcInterface =
        [NSXPCInterface interfaceWithProtocol: @protocol(CollectionProtocol)];

    xpcConnection = [[NSXPCConnection alloc] initWithServiceName: kServiceName];
    [xpcConnection setRemoteObjectInterface: xpcInterface];
    [xpcInterface setClasses: classes
                 forSelector: @selector(collectReportsForAccounts:)
               argumentIndex: 0
                     ofReply: NO];

    NSXPCInterface * progressInterface =
        [NSXPCInterface interfaceWithProtocol: @protocol(CollectionProgressProtocol)];

    xpcConnection.exportedInterface = progressInterface;

    [progressInterface setClasses: classes
                      forSelector: @selector(receivedRanks:)
                    argumentIndex: 0
                          ofReply: NO];

    xpcConnection.exportedObject = self;

    [xpcConnection resume];

    iTunesCollector = [xpcConnection remoteObjectProxyWithErrorHandler:^(NSError * error)
    {
       NSAlert *alert = [[NSAlert alloc] init];
       [alert addButtonWithTitle: @"OK"];
       [alert setMessageText: error.localizedDescription];
       [alert setAlertStyle: NSWarningAlertStyle];

       [alert performSelectorOnMainThread: @selector(runModal)
                               withObject: nil
                            waitUntilDone: YES];
    }];

} // End of updateCollectionInterface

- (void) collectionTaskFinished
{
    @synchronized(collectionTaskQueue)
    {
        // Wait a short time
        [NSThread sleepForTimeInterval: 0.500];

        // Clear our queue
        currentCollectionType   = CollectionTypeIdle;
        currentProgress         = 0;

        // Is there anything new to do?
        if(![self processCollectionTaskQueue])
        {
            // Set our state
            self.currentStateString = [self displayForCollectionType: CollectionTypeIdle];
        } // End of processCollectionOperationTask had nothing to do.
    } // End of collectionTaskQueue
}

#pragma mark -
#pragma mark AWReportCollectionDelegate

- (void) shouldCollectReportForDate: (NSDate*) importDate
                  internalAccountId: (NSString*) internalAccountId
                              reply: (void (^)(BOOL appExists))reply;
{
    BOOL result = YES;

    NSLog(@"shouldCollectReportForDate %@ result: %@.", importDate, result == YES ? @"YES" : @"NO");
    reply(result);
} // End of shouldCollectReportForDate:accountId:reply;

- (void) createProductIfRequiredWithDetails: (NSDictionary*) productDetails
                              applicationId: (NSNumber*) applicationId
                                 reply: (void (^)(BOOL appExists))reply
{
    BOOL result = [self createProductIfRequiredWithDetails: productDetails
                                             applicationId: applicationId];
    
    reply(result);
}

- (BOOL) createProductIfRequiredWithDetails: (NSDictionary*) productDetails
                              applicationId: (NSNumber*) applicationId
{
    NSLog(@"entered createProductIfRequiredWithDetails (app id: %@)",
          applicationId);

    __block BOOL result = YES;

    // Get our product (if it exists).
    NSNumber * appleIdentifier = productDetails[@"appleIdentifier"];
    AWProduct * product = [AWProduct productByAppleIdentifier: appleIdentifier];

    if(nil == product)
    {
        product = [[AWProduct alloc] init];
        product.appleIdentifier = productDetails[@"appleIdentifier"];
        product.title           = productDetails[@"productTitle"];
        product.productType     = productDetails[@"productType"];
        product.applicationId   = applicationId;

        // Add our product
        [AWProduct addProduct: product];
    } // End of we did not have a product

    return result;
} // End of createProductWithDetails:applicationId;

- (AWApplicationFinderEntry*) reportConnectionOperationRequiresDetailsForApplicationId: (NSNumber*) appleIdentifier
                                                                         countryCode: (NSString*) countryCode
                                                                               error: (NSError*__autoreleasing*) error
{
    AWiTunesConnectHelper * helper = [[AWiTunesConnectHelper alloc] init];
    return [helper detailsForApplicationId: appleIdentifier
                               countryCode: countryCode
                                     error: error];
}

- (void) logError: (NSString*) errorToLog
{
    NSLog(@"ITCE: %@", errorToLog);
}

- (NSString*) reportCollectionNeedsInternalAccountIdForVendorId: (NSNumber*) vendorId
                                                     vendorName: (NSString*) vendorName
{
    __block NSString * accountId = nil;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [self reportCollectionNeedsInternalAccountIdForVendorId: vendorId
                                                 vendorName: vendorName
                                                      reply: ^(NSString * internalAccountId)
     {
         accountId = internalAccountId;
         dispatch_semaphore_signal(sema);
     }];

    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    return accountId;
}

- (BOOL) reportCollectionOperationCreateApplicationIfNotExists: (NSNumber*) applicationId
                                                  productTitle: (NSString *)productTitle
                                                   countryCode: (NSString*) countryCode
                                                     accountId: (NSString*) accountId
{
    __block BOOL retunCode = NO;

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [self reportCollectionOperationCreateApplicationIfNotExists: applicationId
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
} // End of reportCollectionOperationCreateApplicationIfNotExists

- (void) reportCollectionNeedsInternalAccountIdForVendorId: (NSNumber*) vendorId
                                                vendorName: (NSString*) vendorName
                                                     reply: (void (^)(NSString * internalAccountId))reply
{
    AccountDetails * accountDetails =
        [[AWAccountHelper sharedInstance] accountDetailsForVendorId: vendorId];

    if(nil == accountDetails)
    {
        NSString * internalAccountId = [[NSProcessInfo processInfo] globallyUniqueString];
        accountDetails = [[AccountDetails alloc] init];
        accountDetails.accountUserName      = nil;
        accountDetails.accountAccessToken   = nil;
        accountDetails.vendorId             = vendorId;
        accountDetails.vendorName           = vendorName;
        accountDetails.accountInternalId    = internalAccountId;
        accountDetails.removed              = NO;
        accountDetails.modified             = NO;

        [[AWAccountHelper sharedInstance] addAccountDetails: accountDetails];

        @autoreleasepool {
            AWAccount * account = [[AWAccount alloc] init];
            account.internalAccountId = internalAccountId;
            account.accountType       = @(AccountType_iTunes);

            [AWAccount addAccount: account];
        }
    } // End of we have no accountDetails

    reply(accountDetails.accountInternalId);
}

- (void) reportCollectionOperationCreateApplicationIfNotExists: (NSNumber*) applicationId
                                                  productTitle: (NSString *)productTitle
                                                   countryCode: (NSString*) countryCode
                                                     accountId: (NSString*) internalAccountId
                                                         reply: (void (^)(BOOL appExists))reply
{
    NSLog(@"entered reportCollectionOperationCreateApplicationIfNotExists (application id: %@, countryCode: %@, productTitle: %@, accountId: %@)", applicationId, countryCode, productTitle, internalAccountId);

    AWApplication * application = [AWApplication applicationByApplicationId: applicationId];

    // If we alreay have an application, then we are good.
    if(nil != application)
    {
        NSString * oldInternalAccountId = application.internalAccountId;
        if(nil == oldInternalAccountId || [NSNull null] == (id)oldInternalAccountId)
        {
            oldInternalAccountId = @"";
        } // End of no oldInternalAccountId

        if(NSOrderedSame != [oldInternalAccountId localizedCaseInsensitiveCompare: internalAccountId])
        {
            application.internalAccountId = internalAccountId;

            [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database)
             {
                 static NSString * updateQuery =
                    @"UPDATE application SET internalAccountId = ? WHERE applicationId = ?";

                 NSArray * arguments = @[
                     internalAccountId,
                     applicationId
                 ];

                 [database executeUpdate: updateQuery
                    withArgumentsInArray: arguments];
             }];

            // Post an applications list requires update notification
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                object: nil];
        } // End of entries do not match

        NSLog(@"Application with id %@ already exists.", applicationId);
        reply(YES);
        return;
    } // End of no application

    NSError * error = nil;

    AWApplicationFinderEntry * entry =
        [self reportConnectionOperationRequiresDetailsForApplicationId: applicationId
                                                           countryCode: countryCode
                                                                 error: &error];

    @autoreleasepool {
        if(nil != entry)
        {
            AWApplication * application = [AWApplication createFromApplicationEntry: entry];
            application.internalAccountId = internalAccountId;

            [AWApplication addApplication: application];

            // Post an applications list requires update notification
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                        object: nil];

            reply(YES);
            return;
        } // End of we had an entry
        else
        {
            // At this point, we were unable to find an application in the app store. We will instead
            // create a placeholder app to store the data.
            AWApplicationFinderEntry * tempEntry = [[AWApplicationFinderEntry alloc] init];
            tempEntry.applicationId        = applicationId;
            tempEntry.applicationName      = productTitle;
            tempEntry.applicationDeveloper = @"Unknown Developer";
            tempEntry.applicationType      = @0;
            tempEntry.genreIds             = @[];

            AWApplication * application = [AWApplication createFromApplicationEntry: tempEntry];
            application.internalAccountId = internalAccountId;

            [AWApplication addApplication: application];

            // Post an applications list requires update notification
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                object: nil];

            reply(YES);
            return;
        }
    } // End of autorelease pool
} // End of reportCollectionOperationCreateApplicationIfNotExists

- (void) reportCollectionCompleted: (NSArray*) uniqueDates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Temporary state for updating reports
        self.currentStateString = NSLocalizedString(@"Updating sales cache", nil);

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t cacheSemaphore = dispatch_semaphore_create(0);

            // Get our new reportDates
            NSMutableSet * newReportDates = [NSMutableSet setWithSet: [self getPreviousReportDates]];

            [previousReportDates enumerateObjectsUsingBlock: ^(NSString * entry, BOOL * stop)
             {
                 if([newReportDates containsObject: entry])
                 {
                     [newReportDates removeObject: entry];
                 } // End of it exists
             }];

            // Update its cache. Perform a delta.
            [[AWCacheHelper sharedInstance] updateCache: YES
                                            withDates: newReportDates.copy
                                          updateBlock:
             ^(double progress) {
                 if(progress > 100)
                 {
                     NSLog(@"Progress greater than 100%%");
                 }

                  self.currentProgress = progress;
              }
                                             finished:
             ^(void) {
                 dispatch_semaphore_signal(cacheSemaphore);
             }];

            // Wait for completion
            dispatch_semaphore_wait(cacheSemaphore, DISPATCH_TIME_FOREVER);

            dispatch_async(dispatch_get_main_queue(), ^{ 
                // We have new ranks. Fire the notification.
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName]
                                                                    object: nil];

                // Reload the apps list, it may have changed
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                    object: nil];

                // Get yesterdayDate
                NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                                                    fromDate: [[NSDate date] dateByAddingTimeInterval: timeIntervalDay * -1]];

                NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

                NSDate * yesterday = [gregorian dateFromComponents: dateComponents];
                NSArray * accounts = [AWAccount allAccounts];
                NSArray * accountIds = [accounts valueForKeyPath: @"@distinctUnionOfObjects.internalAccountId"];

                __block BOOL allReportsForYesterday = NO;

                if(0 != accountIds.count)
                {
                    NSUInteger yesterdayTimestamp = [yesterday timeIntervalSince1970];
                    
                    NSString * query = [NSString stringWithFormat: @"SELECT COUNT(DISTINCT internalAccountId) FROM salesReport WHERE beginDate = %ld AND endDate = %ld AND internalAccountId IN ('%@')", yesterdayTimestamp, yesterdayTimestamp, [accountIds componentsJoinedByString: @"',"]];

                    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * database)
                     {
                         int existingAccountsYesterday = [database intForQuery: query];
                         if(existingAccountsYesterday == accountIds.count)
                         {
                             allReportsForYesterday = YES;
                         } // End of we have reports for yesterday
                     }];
                } // End of we have accounts to check

                // If we don't have all of the reports for yesterday, then we will queue up the report collection to run again in 10 minutes.
                if(!allReportsForYesterday)
                {
                    // Queue in ten minutes.
                    [self queueReportCollectionWithTimeInterval: 60 * 10];
                } // End of we do not have all reports for yesterday
                else
                {
                    // We do have all of yesterdays reports. Check if we should send an email
                    // and do so if required.
                    if([[AWSystemSettings sharedInstance] emailsEnabled] && [[AWSystemSettings sharedInstance] emailsWaitForReports])
                    {
                        [[AWEmailHelper sharedInstance] sendDailyEmailAuto];
                    } // End of emails are enabled and we are waiting.
                } // End of we do have the reports.

                [self collectionTaskFinished];
            }); // End of main thread
        }); // End of background thread
    });
}

#pragma mark -
#pragma mark CollectionProgress

- (void) updateProgress: (double) _currentProgress
         progressString: (NSString *) progressString
{
    if(enabled && currentCollectionType != CollectionTypeIdle)
    {
        // Update our progress
        self.currentProgress    = _currentProgress;
        self.currentStateString = progressString;
    }
}

- (void) reportCollectionOperation: (ReportCollectionOperation*) reportCollectionOperation
                   receivedReports: (NSArray*) reports
{
    [self receivedReports: reports];
}

- (void) receivedReports: (NSArray*) reports
{
    NSLog(@"entered receivedReports");

    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
    {
        for(NSDictionary * reportEntry in reports)
        {
             [salesDatabase executeUpdate:@"INSERT OR IGNORE INTO salesReport (internalAccountId, salesReportType, appleIdentifier, currency, productTypeIdentifier, profitPerUnit, promoCode, units, countryCode, beginDate, endDate, cached) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)",
                  reportEntry[@"internalAccountId"],
                  reportEntry[@"salesReportType"],
                  reportEntry[@"appleIdentifier"],
                  reportEntry[@"currency"],
                  reportEntry[@"productTypeIdentifier"],
                  reportEntry[@"profitPerUnit"],
                  reportEntry[@"promoCode"],
                  reportEntry[@"units"],
                  reportEntry[@"countryCode"],
                  reportEntry[@"beginDate"],
                  reportEntry[@"endDate"]
              ];
         } // End of reports enumeration
    }];
} // End of receivedReports

- (void) receivedRanks: (NSArray*) ranks
{
    [[AWRankBulkImporter sharedInstance] addRanks: ranks];
}

- (void) completedRankCollection
{
    [self rankCollectionCompleted];
}

- (void) completedReportCollection: (NSArray*) uniqueDates
{
    [self reportCollectionCompleted: uniqueDates];
}

- (void) receivedReviews: (NSArray*) reviews
{
    [[AWReviewBulkImporter sharedInstance] addReviews: reviews];
}

- (void) completedReviewCollection
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self reviewCollectionCompleted];
    });
}

- (void) reviewCollectionRecevied403: (NSString*) reviewURL
{
    NSLog(@"reviewCollectionOperationReceived403 - Forbidden. We are hitting it to much (attempted url was: %@).", reviewURL);

    // Mark as finished.
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self reviewCollectionCompleted];
    });
} // End of reviewCollectionRecevied403

@end

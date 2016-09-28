//
//  ReportCollectionOperation.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/28/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWAccountHelper.h"

@class ReportCollectionOperation;
@class ApplicationFinderEntry;

@protocol AWReportCollectionDelegate <NSObject>

- (void) reportProgressChanged: (NSString*) title
                      progress: (double) progress;

- (void) reportCollectionOperationStarted: (ReportCollectionOperation*) reportCollectionOperation;
- (void) reportCollectionOperationFinished: (ReportCollectionOperation*) reportCollectionOperation;

- (void) reportCollectionOperation: (ReportCollectionOperation*) reportCollectionOperation
                   receivedReports: (NSArray*) reports;

- (BOOL) reportCollectionOperationCreateApplicationIfNotExists: (NSNumber*) applicationId
                                                  productTitle: (NSString*) productTitle
                                                   countryCode: (NSString*) countryCode
                                                     accountId: (NSString*) accountId;

- (NSString*) reportCollectionNeedsInternalAccountIdForVendorId: (NSNumber*) vendorId
                                                     vendorName: (NSString*) vendorName;

- (BOOL) reportCollectionOperation: (ReportCollectionOperation*) reportCollectionOperation
        shouldCollectReportForDate: (NSDate*) date
                 internalAccountId: (NSString*) internalAccountId;

- (BOOL) createProductIfRequiredWithDetails: (NSDictionary*) productDetails
                              applicationId: (NSNumber*) applicationId;

- (void) logError: (NSString*) errorToLog;

@end

@interface ReportCollectionOperation : NSOperation
{
    
}

@property(nonatomic,retain) NSArray * importFromURLDetailsArray;

@property(nonatomic,copy)   AccountDetails * accountDetails;
@property(nonatomic,weak) id<AWReportCollectionDelegate> delegate;

- (NSSet*) uniqueDates;

@end

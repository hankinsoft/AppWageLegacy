//
//  CollectionListener.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-03.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kServiceName            @"com.hankinsoft.osx.appwage.iTunesCollectionService"

@class ReportCollectionOperation;

@protocol CollectionProtocol

- (void) collectRanksWithBaseURL: (NSString*) baseURL
                 appsWeCareAbout: (NSArray*) appsWeCareAbout
                      targetUrls: (NSArray*) temp
                           reply: (void (^)(NSString *g))reply;

- (void) collectReviewsWithDetails: (NSArray*) reviewCollectionDetails;

- (void) collectReportsForAccounts: (NSData*) accountData;
- (void) importReportsFromURLS: (NSArray*) urls;

- (void) setSuspended: (BOOL) suspended;
- (void) cancel;

@end

@protocol CollectionProgressProtocol

- (void) updateProgress: (double) currentProgress
         progressString: (NSString *) progressString;

- (void) receivedRanks: (NSArray*) ranks;
- (void) completedRankCollection;

- (void) receivedReviews: (NSArray*) ranks;
- (void) completedReviewCollection;

- (void) reviewCollectionRecevied403: (NSString*) collectionUrl;




- (void) reportCollectionOperationCreateApplicationIfNotExists: (NSNumber*) applicationId
                                                  productTitle: (NSString*) productTitle
                                                   countryCode: (NSString*) countryCode
                                                     accountId: (NSString*) accountId
                                                         reply: (void (^)(BOOL appExists))reply;

- (void) reportCollectionNeedsInternalAccountIdForVendorId: (NSNumber*) vendorId
                                                vendorName: (NSString*) vendorName
                                                     reply: (void (^)(NSString * internalAccountId))reply;

- (void) createProductIfRequiredWithDetails: (NSDictionary*) productDetails
                              applicationId: (NSNumber*) applicationId
                                      reply: (void (^)(BOOL appExists))reply;

- (void) receivedReports: (NSArray*) reports;

- (void) logError: (NSString*) errorToLog;




- (void) shouldCollectReportForDate: (NSDate*) importDate
                  internalAccountId: (NSString*) accountId
                              reply: (void (^)(BOOL appExists))reply;

- (void) completedReportCollection: (NSArray*) uniqueDates;

@end

@interface CollectionListener : NSObject<NSXPCListenerDelegate, CollectionProtocol>

@property (weak) NSXPCConnection *xpcConnection;

@end
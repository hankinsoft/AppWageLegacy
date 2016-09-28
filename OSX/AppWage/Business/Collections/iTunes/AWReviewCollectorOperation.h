//
//  AWReviewCollectorOperation.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWReviewCollectorOperation;

@protocol AWReviewCollectionOperationDelegate <NSObject>

- (void) reviewCollectionOperationDidStart: (AWReviewCollectorOperation*) reviewCollectionOperation withApplicationNamed: (NSString*) applicationName;
- (void) reviewCollectionOperationDidFinish: (AWReviewCollectorOperation*) reviewCollectionOperation;

- (void) reviewCollectionOperationReceived403: (AWReviewCollectorOperation*) reviewCollectionOperation;
- (void) reviewCollectionOperation:(AWReviewCollectorOperation *) reviewCollectionOperation hasMorePages: (NSUInteger) totalPages;
- (void) reviewCollectionOperation:(AWReviewCollectorOperation *)reviewCollectionOperation hasReviews: (NSArray*) reviews;

@end

@interface AWReviewCollectorOperation : NSOperation

- (id) initWithApplicationDetails: (NSDictionary*) applicationDetails
                   countryDetails: (NSDictionary*) countryDetails
                             page: (NSUInteger) page;

- (id) initWithReviewCollectionOperation: (AWReviewCollectorOperation*) existingReviewCollectionOperation
                                    page: (NSUInteger) page;

- (NSString*) reviewURL;

@property(nonatomic,weak) id<AWReviewCollectionOperationDelegate>   delegate;

@end

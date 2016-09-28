//
//  AWReviewBulkImporter.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/10/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultReviewAutoInsertCount         (1000)

@interface AWReviewBulkImporter : NSObject

+ (AWReviewBulkImporter*) sharedInstance;

@property(nonatomic,assign) NSUInteger autoInsertCount;

- (void) addReview: (id) reviewToAdd;
- (void) addReviews: (NSArray*) reviewsToAdd;

@end

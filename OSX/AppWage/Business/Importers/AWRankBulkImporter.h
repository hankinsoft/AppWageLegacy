//
//  AWReviewBulkImporter.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/9/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWRankBulkImporterEntry.h"

#define kDefaultRankAutoInsertCount         (1000)

@interface AWRankBulkImporter : NSObject

+ (AWRankBulkImporter*) sharedInstance;

@property(nonatomic,assign) NSUInteger autoInsertCount;

- (void) addRank: (AWRankBulkImporterEntry*) rankToAdd;
- (void) addRanks: (NSArray*) ranksToAdd;

- (void) addNull;

@end

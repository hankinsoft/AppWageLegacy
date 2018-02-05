//
//  AWReviewBulkImporter.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/9/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWRankBulkImporterEntry.h"

@interface AWRankBulkImporter : NSObject

+ (AWRankBulkImporter*) sharedInstance;

@property(nonatomic,assign) NSUInteger autoInsertCount;

- (void) addRank: (AWRankBulkImporterEntry*) rankToAdd;
- (void) addRanks: (NSArray<AWRankBulkImporterEntry*>*) ranksToAdd;

- (void) addNull;

@end

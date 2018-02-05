//
//  AWKeywordRankBulkImporter.h
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWKeywordRankBulkImporterEntry.h"

@interface AWKeywordRankBulkImporter : NSObject

+ (AWKeywordRankBulkImporter*) sharedInstance;

@property(nonatomic,assign) NSUInteger autoInsertCount;

- (void) addKeywordRank: (AWKeywordRankBulkImporterEntry*) rankToAdd;
- (void) addKeywordRanks: (NSArray*) ranksToAdd;

- (void) addNull;

@end


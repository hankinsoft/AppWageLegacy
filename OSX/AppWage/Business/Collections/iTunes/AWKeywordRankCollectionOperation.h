//
//  AWKeywordRankCollectionOperation.h
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWKeywordRankBulkImporterEntry.h"

@interface AWKeywordRankCollectionOperation : NSOperation

- (id) initWithApplicationId: (NSNumber*) applicationId
                     keyword: (NSString*) keyword
                 countryCode: (NSString*) countryCode
             applicationType: (NSNumber*) applicationType
             baseInsertEntry: (AWKeywordRankBulkImporterEntry*) _baseInsertEntry;

@end

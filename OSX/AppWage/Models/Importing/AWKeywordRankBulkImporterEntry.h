//
//  AWKeywordRankBulkImporterEntry.h
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWKeywordRankBulkImporterEntry : NSObject

- (id) initWithApplicationKeywordId: (NSNumber *) applicationKeywordId
                          countryId: (NSNumber *) countryId;

@property(nonatomic,copy,readonly) NSNumber * applicationKeywordId;
@property(nonatomic,copy,readonly) NSNumber * countryId;

@property(nonatomic,copy) NSNumber * rank;
@property(nonatomic,copy) NSDate   * keywordRankDate;

@end

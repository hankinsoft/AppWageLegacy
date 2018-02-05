//
//  AWKeywordRankBulkImporterEntry.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWKeywordRankBulkImporterEntry.h"

@interface AWKeywordRankBulkImporterEntry()

@property(nonatomic,copy) NSNumber * applicationKeywordId;
@property(nonatomic,copy) NSNumber * countryId;

@end

@implementation AWKeywordRankBulkImporterEntry

- (id) initWithApplicationKeywordId: (NSNumber *) _applicationKeywordId
                          countryId: (NSNumber *) _countryId;
{
    self = [super init];
    if(self)
    {
        self.applicationKeywordId = _applicationKeywordId;
        self.countryId = _countryId;
    }
    
    return self;
} // End of initWithApplicationKeywordId:countryId:

@end

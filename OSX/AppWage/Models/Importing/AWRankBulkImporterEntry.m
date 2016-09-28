//
//  AWRankBulkImporterEntry.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-04-22.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWRankBulkImporterEntry.h"

@implementation AWRankBulkImporterEntry

@synthesize countryId, genreId, chartId, applicationId, position, rankDate;

-(id) initWithCoder: (NSCoder*) coder
{
    if (self = [super init])
    {
        self.countryId      = [coder decodeObjectOfClass: [NSNumber class] forKey: @"countryId"];
        self.genreId        = [coder decodeObjectOfClass: [NSNumber class] forKey: @"genreId"];
        self.chartId        = [coder decodeObjectOfClass: [NSNumber class] forKey: @"chartId"];
        self.applicationId  = [coder decodeObjectOfClass: [NSNumber class] forKey: @"applicationId"];
        self.position       = [coder decodeObjectOfClass: [NSNumber class] forKey: @"position"];
        self.rankDate       = [coder decodeObjectOfClass: [NSDate class]   forKey:@"rankDate"];
    }

    return self;
}

-(void) encodeWithCoder: (NSCoder*) coder
{
    [coder encodeObject: self.countryId     forKey: @"countryId"];
    [coder encodeObject: self.genreId       forKey: @"genreId"];
    [coder encodeObject: self.chartId       forKey: @"chartId"];
    [coder encodeObject: self.applicationId forKey: @"applicationId"];
    [coder encodeObject: self.position      forKey: @"position"];
    [coder encodeObject: self.rankDate      forKey: @"rankDate"];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end

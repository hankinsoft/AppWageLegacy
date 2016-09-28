//
//  AWRankBulkImporterEntry.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-04-22.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWRankBulkImporterEntry : NSObject <NSSecureCoding>

@property(nonatomic,copy) NSNumber * countryId;
@property(nonatomic,copy) NSNumber * genreId;
@property(nonatomic,copy) NSNumber * chartId;
@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,copy) NSNumber * position;

@property(nonatomic,copy) NSDate   * rankDate;

+ (BOOL)supportsSecureCoding;

@end

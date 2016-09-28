//
//  DateRangeSelectorViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/22/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kDashboardDateRangeType         @"DashboardDateRangeType"
#define kRankGraphDateRangeType         @"RankGraphDateRangeType"

typedef enum {
    DateRangeToday = 0,
    DateRangeTwoDays,
    DateRangePreviousWeek,
    DateRangePreviousTwoWeeks,
    DateRangePreviousMonth,
    DateRangePreviousQuarter,
    DateRangePreviousYear,
    DateRangeCustom
} DateRangeType;

@protocol AWDateRangeSelectorDelegate <NSObject>

- (void) dateRangeDidChange;

@end

@interface AWDateRangeSelectorViewController : NSViewController

+ (long) daysBetween: (NSDate *)dt1
                 and: (NSDate *)dt2;

+ (long) monthsBetween: (NSDate *)dt1
                   and: (NSDate *)dt2;

+ (void) determineDateRangeForType: (NSString*) type
                         startDate: (NSDate**) startDate
                           endDate: (NSDate**) endDate;

+ (void) determineDateRangeForType: (NSString*) type
                         startDate: (NSDate*__autoreleasing*) startDate
                           endDate: (NSDate*__autoreleasing*) endDate
                      includeToday: (BOOL) includeToday;

+ (NSString *) dateRangeStringForType: (NSString*) type;
+ (DateRangeType) dateRangeForType: (NSString*) type;

- (IBAction) onDateRangeButton: (id) sender;
- (IBAction) onDateRangeChanged: (id) sender;

- (IBAction) onDateRangeFromChanged: (id) sender;
- (IBAction) onDateRangeToChanged:   (id) sender;

@property(nonatomic, weak) id<AWDateRangeSelectorDelegate> delegate;
@property(nonatomic, copy)   NSString * dateRangeUserDefault;

@end

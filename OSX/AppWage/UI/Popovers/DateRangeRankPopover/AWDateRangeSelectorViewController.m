//
//  DateRangeSelectorViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/22/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWDateRangeSelectorViewController.h"
#import "AWApplicationRankViewController.h"

#define kCustomDateLow                  @"CustomDateLow"
#define kCustomDateHigh                 @"CustomDateHigh"

@interface AWDateRangeSelectorViewController ()
{
    IBOutlet NSMenuItem                 * todayMenuItem;
    IBOutlet NSMenuItem                 * previousTwoDaysMenuItem;
    IBOutlet NSMenuItem                 * previousYearMenuItem;

    IBOutlet NSPopUpButton              * rangePopupButton;
    IBOutlet NSDatePicker               * rangeDatePicker1;
    
    IBOutlet NSDatePicker               * datePickerFrom;
    IBOutlet NSDatePicker               * datePickerTo;
}
@end

@implementation AWDateRangeSelectorViewController

@synthesize delegate, dateRangeUserDefault;

+ (long) daysBetween:(NSDate *)dt1
                 and:(NSDate *)dt2
{
    NSUInteger unitFlags = NSCalendarUnitDay;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components: unitFlags
                                               fromDate: dt1
                                                 toDate: dt2
                                                options: 0];
    
    return [components day] + 1;
}

+ (long) monthsBetween: (NSDate *)dt1
                   and: (NSDate *)dt2
{
    NSUInteger unitFlags = NSCalendarUnitMonth;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components: unitFlags
                                               fromDate: dt1
                                                 toDate: dt2
                                                options: 0];

    return [components month] + 1;
}

+ (void) determineDateRangeForType: (NSString*) type
                         startDate: (NSDate*__autoreleasing*) startDate
                           endDate: (NSDate*__autoreleasing*) endDate
{
    return [self determineDateRangeForType: type
                                 startDate: startDate
                                   endDate: endDate
                              includeToday: YES];
}

+ (void) determineDateRangeForType: (NSString*) type
                         startDate: (NSDate*__autoreleasing*) startDate
                           endDate: (NSDate*__autoreleasing*) endDate
                      includeToday: (BOOL) includeToday
{
    DateRangeType targetDateRangeType = [AWDateRangeSelectorViewController dateRangeForType: type];

    NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone        = [NSTimeZone timeZoneWithName: @"UTC"];

    NSDate * fromDate = [NSDate date];
    if(includeToday)
    {
        fromDate = [[NSDate date] dateByAddingTimeInterval: timeIntervalDay * 1];
    } // End of includeToday

    switch(targetDateRangeType)
    {
        case DateRangeToday:
        {
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];
            
            
            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];
            
            *endDate   = tempDate;
            *startDate = [(*endDate) dateByAddingTimeInterval: -(timeIntervalDay)];
            
            break;
        }
        case DateRangeTwoDays:
        {
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];
            
            
            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];
            
            *endDate   = tempDate;
            *startDate = [(*endDate) dateByAddingTimeInterval: -(timeIntervalDay * 2)];
            
            break;
        }
        case DateRangePreviousWeek:
        {
            
            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];
            
            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];
            
            * endDate    = tempDate;
            * startDate   = [(* endDate) dateByAddingTimeInterval: -(timeIntervalDay * 7)];
            
            break;
        }
        case DateRangePreviousTwoWeeks:
        {
            
            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];
            
            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];
            
            * endDate    = tempDate;
            * startDate   = [(* endDate) dateByAddingTimeInterval: -(timeIntervalDay * 14)];
            
            break;
        }
        case DateRangePreviousMonth:
        {
            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];

            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];
            
            * endDate    = tempDate;
            * startDate   = [(* endDate) dateByAddingTimeInterval: -(timeIntervalDay * 32)];

            break;
        }
        case DateRangePreviousQuarter:
        {
            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];

            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];

            * endDate    = tempDate;

            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setMonth: -3];
            * startDate = [gregorian dateByAddingComponents: offsetComponents
                                                     toDate: * endDate
                                                    options: 0];

            break;
        }
        case DateRangePreviousYear:
        {
            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: fromDate];
            
            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];
            
            NSDate * tempDate         = [gregorian dateFromComponents: dateComponents];

            * endDate    = tempDate;
            * startDate   = [(* endDate) dateByAddingTimeInterval: -(timeIntervalDay * 365)];
            
            break;
        }

        case DateRangeCustom:
        {
            NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

            * startDate = [userDefaults objectForKey: [NSString stringWithFormat: @"%@/%@",type,kCustomDateLow]];

            * endDate   = [userDefaults objectForKey: [NSString stringWithFormat: @"%@/%@",type, kCustomDateHigh]];

            // We are going to round off our reference date.
            NSDateComponents * dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: *startDate];

            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];

            *startDate = [gregorian dateFromComponents: dateComponents];

            // We are going to round off our reference date.
            dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitDay
                                                                                fromDate: *endDate];

            [dateComponents setHour:   0];
            [dateComponents setMinute: 0];
            [dateComponents setSecond: 0];
            * endDate   = [gregorian dateFromComponents: dateComponents];

            // If its the dashboard, then we need an extra day.
            if([type isEqualToString: kDashboardDateRangeType])
            {
                // Need to add one day
                NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                dayComponent.day = 1;

                * endDate = [gregorian dateByAddingComponents: dayComponent toDate: *endDate options: 0];
            }
            break;
        } // End of custom date range
        default:
            NSAssert(true, @"Unhandled date range type: %ld", (long)targetDateRangeType);
    }

    return;
} // End of determineDateRangeType

+ (NSString *) dateRangeStringForType: (NSString*) type
{
    NSDateFormatter * formatter = [AWDateHelper dateFormatter];

    NSDate * startDate, * endDate;

    // Figure out our date ranges
    [AWDateRangeSelectorViewController determineDateRangeForType: type
                                                     startDate: &startDate
                                                       endDate: &endDate];


    if([type isEqualToString: kDashboardDateRangeType] || [type isEqualToString: kRankGraphDateRangeType])
    {
        NSCalendar *gregorian     = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

        // Need to add one day
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = 1;

        startDate = [gregorian dateByAddingComponents: dayComponent
                                               toDate: startDate
                                              options: 0];
    } // End of type is dateRangeType

    NSString * startDateString = [formatter stringFromDate: startDate];
    NSString * endDateString   = [formatter stringFromDate: endDate];

    // If the dates are the same, then just return one instance. No range.
    if([startDateString isEqualToString: endDateString])
    {
        return startDateString;
    }

    return [NSString stringWithFormat: @"%@ - %@",
            startDateString,
            endDateString];
} // End of dateRangeStringForType

+ (DateRangeType) dateRangeForType: (NSString*) type
{
    return (DateRangeType)[[[NSUserDefaults standardUserDefaults] objectForKey: type] integerValue];
} // End of dateRangeForType

- (id) init
{
    self = [super initWithNibName: @"AWDateRangeSelectorViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
} // End of init

- (void) awakeFromNib
{
    [super awakeFromNib];

    if([dateRangeUserDefault isEqualToString: kDashboardDateRangeType])
    {
        // Hide the today menu item
        [todayMenuItem setHidden: YES];
        [previousTwoDaysMenuItem setHidden: YES];
        [previousYearMenuItem setHidden: NO];
    } // End of today.
    else
    {
        // Hide the today menu item
        [todayMenuItem setHidden: NO];
        [previousTwoDaysMenuItem setHidden: NO];
        [previousYearMenuItem setHidden: YES];
    }

    // Use AppStore launch day as minimum
    NSDateComponents * components = [[NSDateComponents alloc] init];
    [components setDay:10];
    [components setMonth:7];
    [components setYear:2010];
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDate * minimum = [gregorian dateFromComponents:components];
    [rangeDatePicker1 setMinDate:minimum];
    [datePickerFrom setMinDate:minimum];
    [datePickerTo setMinDate:minimum];
    
    // Cannot pick past today
    [rangeDatePicker1 setMaxDate: [NSDate date]];
    [datePickerFrom setMaxDate: [NSDate date]];
    [datePickerTo setMaxDate: [NSDate date]];

    
    DateRangeType dateRangeMode = (DateRangeType)[[[NSUserDefaults standardUserDefaults] objectForKey: dateRangeUserDefault] integerValue];

    [self updateUIWithRange: dateRangeMode];
}

- (void) updateUIWithRange: (DateRangeType) dateRange
{
    NSDate * now = [NSDate date];

    [datePickerFrom setEnabled: NO];
    [datePickerTo setEnabled:   NO];

    switch(dateRange)
    {
        case DateRangeToday:
            [rangePopupButton selectItemAtIndex: 0];

            [rangeDatePicker1 setDateValue: now];
            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSSingleDateMode];

            [datePickerFrom setDateValue: now];
            [datePickerFrom setEnabled: NO];

            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];

            break;
        case DateRangeTwoDays:
        {
            [rangePopupButton selectItemAtIndex: 1];
            NSTimeInterval timeInterval = timeIntervalDay * 1;

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];

            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];

            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];
            break;
        }
        case DateRangePreviousWeek:
        {
            [rangePopupButton selectItemAtIndex: 2];
            NSTimeInterval timeInterval = timeIntervalDay * 6;

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];

            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];

            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];

            break;
        }
        case DateRangePreviousTwoWeeks:
        {
            [rangePopupButton selectItemAtIndex: 3];
            NSTimeInterval timeInterval = timeIntervalDay * 13;

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];

            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];

            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];

            break;
        }
        case DateRangePreviousMonth:
        {
            [rangePopupButton selectItemAtIndex: 4];

            NSTimeInterval timeInterval = timeIntervalDay * 31; // Estimate 31 days for a month.

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];

            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];

            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];

            break;
        }
        case DateRangePreviousQuarter:
        {
            [rangePopupButton selectItemAtIndex: 5];
            
            NSTimeInterval timeInterval = timeIntervalDay * (31 * 3); // Estimate 31 days for a month.

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];
            
            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];
            
            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];
            
            break;
        }
        case DateRangePreviousYear:
        {
            [rangePopupButton selectItemAtIndex: 6];
            
            NSTimeInterval timeInterval = timeIntervalDay * 365; // Estimate 365 days for a month.

            [rangeDatePicker1 setEnabled: NO];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [rangeDatePicker1 setTimeInterval: timeInterval];
            
            [datePickerFrom setDateValue: [now dateByAddingTimeInterval: - timeInterval]];
            [datePickerFrom setEnabled: NO];
            
            [datePickerTo setDateValue: now];
            [datePickerTo setEnabled: NO];
            
            break;
        }
        case DateRangeCustom:
        {
            [rangePopupButton selectItemAtIndex: 7];

            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSDate * startDate = [userDefaults objectForKey: [NSString stringWithFormat: @"%@/%@", dateRangeUserDefault, kCustomDateLow]];
            NSDate * endDate   = [userDefaults objectForKey: [NSString stringWithFormat: @"%@/%@",                                                              dateRangeUserDefault, kCustomDateHigh]];

            // If either of our custom date ranges are nil, then we will set it to be the last month.
            if(nil == startDate || nil == endDate)
            {
                // Default to two weeks.
                NSTimeInterval timeInterval = timeIntervalDay * 13;

                startDate = [now dateByAddingTimeInterval: - timeInterval];
                endDate   = now;

                [userDefaults setObject: startDate forKey: [NSString stringWithFormat: @"%@/%@",dateRangeUserDefault, kCustomDateLow]];
                [userDefaults setObject: endDate forKey: [NSString stringWithFormat: @"%@/%@",dateRangeUserDefault, kCustomDateHigh]];
            }

            [rangeDatePicker1 setEnabled: YES];
            [rangeDatePicker1 setDatePickerMode: NSRangeDateMode];
            [rangeDatePicker1 setDateValue: startDate];
            [rangeDatePicker1 setTimeInterval: fabs([startDate timeIntervalSinceDate: endDate])];

            [datePickerFrom setEnabled: YES];
            [datePickerTo setEnabled:   YES];

            [datePickerFrom setDateValue: startDate];
            [datePickerTo setDateValue: endDate];

            break;
        }
    }
}

- (IBAction) onDateRangeButton: (id) sender
{
    DateRangeType newRange = (DateRangeType)rangePopupButton.indexOfSelectedItem;

    // If we have switch to custom date range, then we want to reset it.
    if(newRange == DateRangeCustom)
    {
        NSLog(@"Custom. Want to reset.");
    } // End of custom

    [self updateUIWithRange: newRange];

    // Set our range
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: newRange]
                                              forKey: dateRangeUserDefault];

    [self.delegate dateRangeDidChange];
} // End of onDateRangeButton

- (IBAction) onDateRangeChanged: (id) sender
{
    NSDate * startDate = [rangeDatePicker1 dateValue];
    NSDate * endDate   = [startDate dateByAddingTimeInterval: rangeDatePicker1.timeInterval];

    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: startDate forKey: [NSString stringWithFormat: @"%@/%@",dateRangeUserDefault, kCustomDateLow]];
    [userDefaults setObject: endDate forKey: [NSString stringWithFormat: @"%@/%@",dateRangeUserDefault, kCustomDateHigh]];

    [self.delegate dateRangeDidChange];

    // Update our start and end date
    [datePickerFrom setDateValue: startDate];
    [datePickerTo setDateValue: endDate];

    // Set a minimum date for the to value
    [datePickerTo setMinDate: datePickerFrom.dateValue];
    [datePickerFrom setMaxDate: datePickerTo.dateValue];
} // End of onDateRangeChanged

- (IBAction) onDateRangeFromChanged: (id) sender
{
    NSLog(@"From date range changed");

    NSTimeInterval timeInterval = fabs([datePickerTo.dateValue timeIntervalSinceDate: datePickerFrom.dateValue]);

    [rangeDatePicker1 setDateValue: [datePickerFrom dateValue]];
    [rangeDatePicker1 setTimeInterval: timeInterval];

    [self onDateRangeChanged: self];
}

- (IBAction) onDateRangeToChanged:   (id) sender
{
    NSLog(@"From date range changed");
    
    NSTimeInterval timeInterval = fabs([datePickerTo.dateValue timeIntervalSinceDate: datePickerFrom.dateValue]);
    
    [rangeDatePicker1 setDateValue: [datePickerFrom dateValue]];
    [rangeDatePicker1 setTimeInterval: timeInterval];

    [self onDateRangeChanged: self];
}

@end

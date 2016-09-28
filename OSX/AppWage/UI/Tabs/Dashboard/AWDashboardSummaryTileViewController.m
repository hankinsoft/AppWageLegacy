//
//  DashboardSummaryTileViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-24.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWDashboardSummaryTileViewController.h"
#import "AWDateRangeSelectorViewController.h"
#import "AWCurrencyHelper.h"

@interface AWDashboardSummaryTileViewController ()
{
    IBOutlet NSTextField * titleTextField;

    IBOutlet NSTextField * revenueTextField;
    IBOutlet NSTextField * downloadsTextField;
    IBOutlet NSTextField * upgradesTextField;
    IBOutlet NSTextField * refundsTextField;
}
@end

@implementation AWDashboardSummaryTileViewController
{
    NSNumberFormatter * wholeNumberFormatter;
    NSNumberFormatter * twoDigitNumberFormatter;
    NSNumberFormatter * currencyFormatter;
}

@synthesize mode, selectedProductIdentifiers;

- (id) init
{
    self = [super initWithNibName: @"AWDashboardSummaryTileViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
    [wholeNumberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    wholeNumberFormatter.maximumFractionDigits       = 0;
    wholeNumberFormatter.minimumSignificantDigits    = 1;
    wholeNumberFormatter.minimumIntegerDigits        = 1;

    twoDigitNumberFormatter = [[NSNumberFormatter alloc] init];
    [twoDigitNumberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [twoDigitNumberFormatter setMinimumFractionDigits: 2];
    [twoDigitNumberFormatter setMaximumFractionDigits: 2];

    // Currency formatter
    currencyFormatter = [[NSNumberFormatter alloc] init];

    // set options.
    [currencyFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];

    switch(mode)
    {
        case 0:
            titleTextField.stringValue = @"All time";
            break;
        case 1:
            titleTextField.stringValue = @"All time daily average";
            break;
        case 2:
            titleTextField.stringValue = @"Selection totals";
            break;
        case 3:
            titleTextField.stringValue = @"Selection daily average";
            break;
    }
} // End of awakeFromNib

- (void) update: (BOOL) updateTotal
upgradeSelectionRange: (BOOL) upgradeSelectionRange
{
    // Mode is global and we do not want to update the total
    if((0 == mode || 1 == mode) && !updateTotal)
    {
        return;
    }

    if((2 == mode || 3 == mode) && !upgradeSelectionRange)
    {
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadsTextField.stringValue = @"";
            refundsTextField.stringValue   = @"";
            upgradesTextField.stringValue  = @"";
            revenueTextField.stringValue   = @"";
        });

        [self updateTiles];
    });
}

- (void) updateTiles
{
    MachTimer * machTimer = [MachTimer startTimer];

    __block NSString * downloads = @"0";
    __block NSString * refunds   = @"0";
    __block NSString * upgrades  = @"0";
    __block NSString * revenue   = @"$0.00";

    NSMutableString * clause = [NSMutableString stringWithFormat: @"cacheType IN (%d, %d, %d, %d) ", DashboardChartDisplayTotalSales, DashboardChartDisplayRefunds, DashboardChartDisplayUpgrades, DashboardChartDisplayTotalRevenue];

    if(selectedProductIdentifiers)
    {
        [clause appendFormat: @" AND productId IN (%@)",
         [selectedProductIdentifiers.allObjects componentsJoinedByString: @","]];
    }

    if(2 == mode || 3 == mode)
    {
        // Two and three are by date. If we are those cases, we will
        NSDate * startDate;
        NSDate * endDate;
        
        // Figure out our date ranges
        [AWDateRangeSelectorViewController determineDateRangeForType: kDashboardDateRangeType
                                                           startDate: &startDate
                                                             endDate: &endDate];

        // The tile clause has to be less than, not greater or less than.
        [clause appendFormat: @" AND (date >= %ld AND date < %ld)",
         (long)startDate.timeIntervalSince1970, (long)endDate.timeIntervalSince1970];
    } // End of dateRange predicate

    NSString * dateCountQuery = [NSString stringWithFormat: @"/ (SELECT COUNT(DISTINCT date) FROM salesReportCachePerApp WHERE %@)", clause];

    NSString * query =
    [NSString stringWithFormat: @"SELECT SUM(cacheValue)%@, cacheType FROM salesReportCachePerApp WHERE %@ GROUP BY cacheType", 1 == mode || 3 == mode ? dateCountQuery : @"", clause];

    NSLog(@"Query is: %@", query);

    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback)
     {
         FMResultSet * results = [salesDatabase executeQuery: query];
         while([results next])
         {
             DashboardChartDisplay outMode = (DashboardChartDisplay)[results intForColumnIndex: 1];
             NSNumber * value = nil;

             value = [NSNumber numberWithDouble: [results doubleForColumnIndex: 0]];

             NSNumberFormatter * formatter = wholeNumberFormatter;
             if(1 == mode || 3 == mode)
             {
                 formatter = twoDigitNumberFormatter;
             }

             switch(outMode)
             {
                 case DashboardChartDisplayTotalSales:
                     downloads = [formatter stringFromNumber: value];
                     break;
                 case DashboardChartDisplayRefunds:
                     refunds = [formatter stringFromNumber: value];
                     break;
                 case DashboardChartDisplayUpgrades:
                     upgrades = [formatter stringFromNumber: value];
                     break;
                 case DashboardChartDisplayTotalRevenue:
                     revenue = [currencyFormatter stringFromNumber: value];
                     break;
                 default:
                     break;
             }
         } // End of next
     }];

    dispatch_async(dispatch_get_main_queue(), ^{
        downloadsTextField.stringValue = downloads;
        refundsTextField.stringValue   = refunds;
        upgradesTextField.stringValue  = upgrades;
        revenueTextField.stringValue  = revenue;

        NSLog(@"calculateSums finished. Took %f.", [machTimer elapsedSeconds]);
    });
}

@end

//
//  SalesChart.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/30/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSalesChart.h"
#import "CorePlot.h"

#import "AWApplicationRankViewController.h"

#import "AWApplication.h"

#import "AWChartColorHelper.h"
#import "AWCurrencyHelper.h"

#import "AWDateRangeSelectorViewController.h"
#import "AWChartPopoverDetails.h"

@interface SalesReportEntry : NSObject

@property(nonatomic,copy) NSNumber * productId;
@property(nonatomic,copy) NSNumber * sumOfUnits;
@property(nonatomic,copy) NSDate * date;

@end

@implementation SalesReportEntry

@end

// Access to private methods
@interface CPTBarPlot()
-(CGFloat)lengthInView:(NSDecimal)decimalLength;
-(BOOL)barAtRecordIndex:(NSUInteger)idx basePoint:(CGPoint *)basePoint tipPoint:(CGPoint *)tipPoint;
@end

@interface AWSalesChart()<AWTrackedGraphHostingViewProtocol, CPTPlotDataSource, CPTPlotSpaceDelegate, CALayerDelegate>
{
    dispatch_semaphore_t                salesChartLoadSemaphore;
    NSSet                               * selectedApplicationIds;

    // Graph
    CPTGraph                            * graph;
    CPTPlotSpaceAnnotation              * symbolTextAnnotation;

    NSDictionary                        * data;
    NSDictionary                        * sets;
    NSArray                             * dateDisplayArray;
    NSArray                             * dates;
    NSArray                             * dailySums;

    // Popover
    AWChartPopoverDetails               * popoverDetails;

    NSDateFormatter                     * shortDateFormatter;
    NSDateFormatter                     * monthDateFormatter;
    NSDateFormatter                     * longDateFormatter;
}
@end

@implementation AWSalesChart
{
    SalesChartDateDisplayMode salesChartDisplayMode;
    double                              maxGraphY;
    double                              minGraphY;
}

@synthesize delegate;

static NSNumberFormatter * wholeNumberFormatter;

// Currency formatter
static NSNumberFormatter * currencyFormatter;

+ (void) initialize
{
    // Setup our formatters
    wholeNumberFormatter = [[NSNumberFormatter alloc] init];
    [wholeNumberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [wholeNumberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    wholeNumberFormatter.maximumFractionDigits  = 0;
    
    currencyFormatter = [[NSNumberFormatter alloc] init];

    // set options.
    [currencyFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
} // End of initialize

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.mouseDelegate = self;
        salesChartLoadSemaphore = dispatch_semaphore_create(1);

        // Setup our short date formatter
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        shortDateFormatter.dateStyle         = kCFDateFormatterShortStyle;

        // Setup our month date formatter
        monthDateFormatter = [[NSDateFormatter alloc] init];
        [monthDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [monthDateFormatter setDateFormat: @"MMMM yyyy"];

        // Setup our long date formatter
        longDateFormatter = [[NSDateFormatter alloc] init];
        [longDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        longDateFormatter.dateStyle         = kCFDateFormatterFullStyle;
    }

    return self;
}

- (void) setSelectedApplicationIds: (NSSet*) _applicationIds
{
    if(nil == _applicationIds)
    {
        return;
    } // End of applicationIds was nil

    selectedApplicationIds = _applicationIds;
    [self updateChart];
}

- (void) setSalesChartDisplayMode: (SalesChartDateDisplayMode) newSalesChartDisplayMode
{
    salesChartDisplayMode = newSalesChartDisplayMode;
}

- (void) updateChart
{
    if(0 != dispatch_semaphore_wait(salesChartLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.delegate salesChartStartedLoading: self];

        NSLog(@"SalesChart data stated loading");

        NSDate * startDate;
        NSDate * endDate;

        // Figure out our date ranges
        [AWDateRangeSelectorViewController determineDateRangeForType: kDashboardDateRangeType
                                                           startDate: &startDate
                                                             endDate: &endDate
                                                        includeToday: NO];

        NSLog(@"SalesChart data load started. Range %@ - %@",
              startDate, endDate);

        MachTimer * machTimer = [MachTimer startTimer];

        NSSet * targetProductIds = selectedApplicationIds;
        NSMutableString * clause = [NSMutableString string];

        // If we have something selected, then we will append the predicate.
        if(0 != targetProductIds.count)
        {
            [clause appendFormat: @" WHERE productId IN (%@)", [targetProductIds.allObjects componentsJoinedByString: @","]];
        } // End of targetProductIds
        
        __block NSUInteger minTimestamp = 0;
        [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * database)
         {
             NSString * minQuery = [NSString stringWithFormat: @"SELECT MIN(date) FROM salesReportCachePerApp%@", clause];
             minTimestamp = [database intForQuery: minQuery];
         }];

        salesChartDisplayMode = SalesChartDateDisplayDaily;
        if(SalesChartDateDisplayYearly == salesChartDisplayMode)
        {
            // Set our dates
            startDate = [NSDate dateWithTimeIntervalSince1970: minTimestamp];
            endDate   = [NSDate date];
        }
        else if(SalesChartDateDisplayMonthly == salesChartDisplayMode)
        {
            NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat: @"yyyy/MM"];
            [dateFormat setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

            startDate = [dateFormat dateFromString: @"2014/01"];
            endDate   = [dateFormat dateFromString: @"2014/12"];
        }

        NSUInteger chartSections = [self generateData: startDate
                                              endDate: endDate];

        NSLog(@"SalesChart data finished loading. Took %f", [machTimer elapsedSeconds]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self generateLayout: startDate
                         endDate: endDate
                   chartSections: chartSections];

            [self.delegate salesChartFinishedLoading: self];
            dispatch_semaphore_signal(salesChartLoadSemaphore);
        });
    });
}

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return dateDisplayArray.count;
}

- (double) doubleForPlot: (CPTPlot *)plot
                   field: (NSUInteger)fieldEnum
             recordIndex: (NSUInteger)index
{
    double num = NAN;
    
    //X Value
    if (fieldEnum == 0)
    {
        num = index;
    }
    else
    {
        double offset = 0;

        NSString * dateKey = [dateDisplayArray objectAtIndex:index];
        NSDictionary * valuesForDate = [data objectForKey: dateKey];
        double currentValue = [[valuesForDate objectForKey: plot.identifier] doubleValue];

        if (((CPTBarPlot *)plot).barBasesVary)
        {
            for (NSString *set in [[sets allKeys] sortedArrayUsingSelector:@selector(compare:)])
            {
                if ([plot.identifier isEqual:set])
                {
                    break;
                }

                offset += [[valuesForDate objectForKey:set] doubleValue];
            }
        }

        //Y Value
        if (fieldEnum == 1)
        {
            if(currentValue < 0)
            {
                num = offset;
            }
            else
            {

            }
                num = currentValue + offset;
        }
        //Offset for stacked bar
        else
        {
            num = offset;
        }
    }

    //NSLog(@"%@ - %d - %d - %f", plot.identifier, index, fieldEnum, num);

    return num;
}

- (NSUInteger) generateData: (NSDate*) startDate
                    endDate: (NSDate*) endDate
{
    NSUInteger chartSections = 0;

    NSLog(@"\r\n\r\nSalesChart generateData");

    DashboardChartDisplay chartDisplayMode = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

    NSMutableArray * _dates = [NSMutableArray array];
    NSMutableArray * dateTitles = [NSMutableArray array];

    NSTimeInterval startIndex   = [startDate timeIntervalSince1970];
    NSTimeInterval end          = [endDate timeIntervalSince1970];

    if(SalesChartDateDisplayMonthly == salesChartDisplayMode)
    {
        // Setup our month date formatter
        NSDateFormatter * tempDateFormatter = [[NSDateFormatter alloc] init];
        [tempDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [tempDateFormatter setDateFormat: @"yyyy/MM"];

        for(long monthIndex = 0;
            monthIndex < 12;
            ++monthIndex)
        {
            NSString * dateString = [NSString stringWithFormat: @"2014/%02ld", monthIndex + 1];
            
            NSDate * date = [tempDateFormatter dateFromString: dateString];
            [dateTitles addObject: dateString];
            
            [_dates addObject: date];
        } // End of loops

        chartSections = 13;
    }
    else if(SalesChartDateDisplayYearly == salesChartDisplayMode)
    {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        gregorian.timeZone    = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

        NSDateComponents * dateComponents = nil;
        dateComponents = [gregorian components: (NSCalendarUnitYear)
                                      fromDate: startDate];

        long startYear = dateComponents.year;

        dateComponents = [gregorian components: (NSCalendarUnitYear)
                                      fromDate: endDate];

        long endYear = dateComponents.year;

        NSAssert(endYear > startYear, @"End year must be later than the start year.");

        // Setup our month date formatter
        NSDateFormatter * tempDateFormatter = [[NSDateFormatter alloc] init];
        [tempDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [tempDateFormatter setDateFormat: @"yyyy"];

        for(long yearIndex = startYear;
            yearIndex <= endYear;
            ++yearIndex)
        {
            NSString * dateString = [NSString stringWithFormat: @"%ld", yearIndex];

            NSDate * date = [tempDateFormatter dateFromString: dateString];
            [dateTitles addObject: dateString];
            [_dates addObject: date];
        } // End of loops

        chartSections = endYear - startYear + 2;
    }
    else if(SalesChartDateDisplayDaily == salesChartDisplayMode)
    {
        NSTimeInterval index = startIndex;
        while(index < end)
        {
            NSDate * date = [NSDate dateWithTimeIntervalSince1970: index];
            [dateTitles addObject: [shortDateFormatter stringFromDate: date]];
            [_dates addObject: date];
            index += timeIntervalDay;
        } // End of loops

        // Figure out our dateSpan
        chartSections =
            (int)[AWDateRangeSelectorViewController daysBetween: startDate
                                                            and: endDate];
    } // End of daily
    else
    {
        NSLog(@"Unknown chart display type.");
    }

    // Array containing all the dates that will be displayed on the X axis
    dateDisplayArray = [NSArray arrayWithArray: dateTitles];
    dates = [NSArray arrayWithArray: _dates];

    NSLog(@"SalesChart - Dates loaded");
    NSLog(@"SalesChart - Getting daily sales reports");
    
    NSMutableString * salesCacheClause = [NSMutableString stringWithFormat: @"cacheType = %d", chartDisplayMode];

    [salesCacheClause appendFormat: @" AND date >= %ld AND date <= %ld",
     (long)startDate.timeIntervalSince1970, (long)endDate.timeIntervalSince1970];

    NSSet * targetProductIds = selectedApplicationIds;
    // If we have something selected, then we will append the predicate.
    if(0 != targetProductIds.count)
    {
        [salesCacheClause appendFormat: @" AND productId IN (%@)",
         [targetProductIds.allObjects componentsJoinedByString: @","]];
    } // End of targetProductIds

    NSString * salesCacheQuery = nil;
    if(SalesChartDateDisplayMonthly == salesChartDisplayMode)
    {
        salesCacheQuery =
        [NSString stringWithFormat: @"SELECT sum(cacheValue), productId, ((julianday(strftime('%%Y-%%m-01', datetime(date, 'unixepoch'))) - 2440587.5)*86400.0) AS date FROM salesReportCachePerApp WHERE %@ GROUP BY productId, strftime('%%Y/%%m', datetime(date, 'unixepoch')) ORDER BY date ASC", salesCacheClause];
    }
    else if(SalesChartDateDisplayYearly == salesChartDisplayMode)
    {
        salesCacheQuery =
        [NSString stringWithFormat: @"SELECT sum(cacheValue), productId, ((julianday(strftime('%%Y-01-01', datetime(date, 'unixepoch'))) - 2440587.5)*86400.0) AS date FROM salesReportCachePerApp WHERE %@ GROUP BY productId, strftime('%%Y', datetime(date, 'unixepoch')) ORDER BY date ASC", salesCacheClause];
    }
    else
    {
        salesCacheQuery =
        [NSString stringWithFormat: @"SELECT sum(cacheValue), productId, date FROM salesReportCachePerApp WHERE %@ GROUP BY productId, date", salesCacheClause];
    }

    NSMutableArray<SalesReportEntry*> * salesReportDaily = [NSMutableArray array];
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase) {

        // Execute our query
        FMResultSet * results = [salesDatabase executeQuery: salesCacheQuery];
        while([results next])
        {
            NSNumber * sum = nil;

            sum = [NSNumber numberWithDouble: [results doubleForColumnIndex: 0]];

            SalesReportEntry * salesReportEntry = [[SalesReportEntry alloc] init];
            salesReportEntry.productId = [NSNumber numberWithInt: [results intForColumnIndex: 1]];
            salesReportEntry.sumOfUnits = sum;
            salesReportEntry.date = [NSDate dateWithTimeIntervalSince1970: [results intForColumnIndex: 2]];

            [salesReportDaily addObject: salesReportEntry];
        }
    }];

    NSLog(@"SalesChart - There are %ld sales reports",
          salesReportDaily.count);
    
    if(0 == salesReportDaily.count)
    {
        //Dictionary containing the name of the two sets and their associated color
        //used for the demo
        sets = [NSDictionary dictionary];
        data = [NSDictionary dictionary];
        return 0;
    }

    NSLog(@"SalesChart - Running distinctUnionOfObjects.product.appleIdentifier.");
    NSMutableSet * _uniqueAppleIdentifiers = [NSMutableSet set];
    [_uniqueAppleIdentifiers addObjectsFromArray: [salesReportDaily valueForKeyPath: @"@distinctUnionOfObjects.productId"]];

    NSArray * uniqueAppleIdentifiers = [_uniqueAppleIdentifiers allObjects];
    
    NSLog(@"SalesChart - Got distinct list of apple identifiers.");
    
    NSMutableDictionary * _sets  = [NSMutableDictionary dictionary];
    NSMutableDictionary * setSum = [NSMutableDictionary dictionary];
    
    [uniqueAppleIdentifiers enumerateObjectsUsingBlock:
     ^(NSString * set, NSUInteger setIndex, BOOL * stop)
     {
         NSColor * setColor = [AWChartColorHelper colorForIndex: setIndex];
         [_sets setObject: setColor
                   forKey: set];
         
         [setSum setObject: @0
                    forKey: set];
     }];
    
    // Set our sets!
    sets      = [NSDictionary dictionaryWithDictionary: _sets];
    maxGraphY = 0;
    minGraphY = 0;
    
    // Create our dateLookup
    NSLog(@"SalesChart - Creating date lookup");

    NSMutableDictionary * dateLookup = [NSMutableDictionary dictionary];
    NSMutableDictionary * resultData = [NSMutableDictionary dictionary];
    
    [dateDisplayArray enumerateObjectsUsingBlock: ^(NSString * date, NSUInteger dateIndex, BOOL * stop)
     {
         NSNumber * dateNumberIndex = [NSNumber numberWithLong: [dates[dateIndex] timeIntervalSince1970]];

         [dateLookup setObject: date
                        forKey: dateNumberIndex];

         // Create our set values entries
         NSMutableDictionary * setValues = [NSMutableDictionary dictionary];
         [sets enumerateKeysAndObjectsUsingBlock: ^(NSString * set, id obj, BOOL * setStop)
          {
              [setValues setObject: @0
                            forKey: set];
          }];

         [resultData setObject: setValues
                        forKey: dateNumberIndex];
     }];
    
    NSLog(@"SalesChart - Calculating data.");

    // Figure out our predicate
    NSPredicate * basePredicate = [NSPredicate predicateWithFormat: @"productId = $appleIdentifier"];

    [sets enumerateKeysAndObjectsUsingBlock: ^(NSString * set, id obj, BOOL * setStop)
     {
         @autoreleasepool {
             __block double setSumTotal = 0;
             
             NSPredicate * setPredicate = [basePredicate predicateWithSubstitutionVariables:
                                           @{
                                             @"appleIdentifier": set
                                             }];

             NSAssert(nil != setPredicate, @"setPredicate cannot be nil.");
             NSArray<SalesReportEntry*> * setForDayResults = [salesReportDaily filteredArrayUsingPredicate: setPredicate];
             
             [setForDayResults enumerateObjectsUsingBlock:
              ^(SalesReportEntry * salesReportDaily, NSUInteger index, BOOL * stop)
              {
                  NSNumber * dateIndex = [NSNumber numberWithDouble: [salesReportDaily.date timeIntervalSince1970]];

                  double value = [salesReportDaily.sumOfUnits doubleValue];

                  NSNumber * current = [[resultData objectForKey: dateIndex] objectForKey: set];

                  current = [NSNumber numberWithDouble: current.doubleValue + value];

                  [[resultData objectForKey: dateIndex] setObject: current
                                                           forKey: set];

                  setSumTotal += value;
              }];

             // Set our set sum
             [setSum setObject: [NSNumber numberWithDouble: setSumTotal]
                        forKey: set];
         } // End of autoreleasepool
     }]; // End of set enumeration

    NSLog(@"SalesChart - Updating dateDisplayArray");
    
    [dateDisplayArray enumerateObjectsUsingBlock: ^(NSString * date, NSUInteger dateIndex, BOOL * stop)
     {
         NSNumber * dateNumberIndex = [NSNumber numberWithLong: [dates[dateIndex] timeIntervalSince1970]];

         id resultEntry = [resultData objectForKey: dateNumberIndex];
         id dateKey     = date;

         // Set our results back to ints.
         [resultData setObject: resultEntry
                        forKey: dateKey];
         
         [resultData removeObjectForKey: dateNumberIndex];
     }];
    
    data = [resultData copy];
    
    NSLog(@"SalesChart - Sorting keys");
    
    NSArray * sortedKeys = [setSum keysSortedByValueUsingSelector: @selector(compare:)];
    
    [sortedKeys enumerateObjectsWithOptions: NSEnumerationReverse
                                 usingBlock: ^(NSNumber * setName, NSUInteger setIndex, BOOL * stop)
     {
         [_sets setObject: [AWChartColorHelper colorForIndex: sortedKeys.count - setIndex - 1]
                   forKey: setName];
     }];

    NSLog(@"SalesChart - finding sums");
    __block NSMutableDictionary * _dailySums = [NSMutableDictionary dictionary];
    [data enumerateKeysAndObjectsUsingBlock: ^(id key, NSDictionary* obj, BOOL * stop)
     {
         __block double currentDayTotal = 0;
         __block double currentDayMinTotal = 0;

         [obj enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL * stop)
          {
              double currentValue = [value doubleValue];

              // Have to add to our current total no matter what.
              currentDayTotal += currentValue;

              if(currentValue < 0)
              {
                  // Have to add because it is a negative.
                  currentDayMinTotal += currentValue;
              }
          }];

         if(currentDayTotal > maxGraphY)
         {
             maxGraphY = currentDayTotal;
         }
         
         if(currentDayMinTotal < minGraphY)
         {
             minGraphY = currentDayMinTotal;
         }

         // Set our daily sum.
         [_dailySums setObject: [NSNumber numberWithFloat: currentDayTotal]
                        forKey: key];
     }];

    dailySums = [_dailySums copy];
    sets = [NSDictionary dictionaryWithDictionary: _sets];

    return chartSections;
} // End of generateDataForDays

- (void)generateLayout: (NSDate*) startDate
               endDate: (NSDate*) endDate
         chartSections: (NSUInteger) chartSections
{
    DashboardChartDisplay chartDisplayMode = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

    //Create graph from theme
	graph                               = [[CPTXYGraph alloc] initWithFrame: CGRectZero];

	self.hostedGraph           = graph;
    graph.backgroundColor               = [[NSColor whiteColor] CGColor];

    graph.paddingBottom                     = 2;
    graph.paddingLeft                       = 4;
	graph.plotAreaFrame.paddingRight        = 10.0;
	graph.plotAreaFrame.paddingBottom       = 25.0;
	graph.plotAreaFrame.paddingLeft         = 45.0;

    // Setup our title
    graph.titleDisplacement = NSMakePoint(0, 18);

	//Add plot space
	CPTXYPlotSpace *plotSpace       = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.delegate              = self;

    // Leave some spacing at the top of the chart.
    double max = maxGraphY + (maxGraphY * 0.09);

    minGraphY = 0;
    if(minGraphY < 0)
    {
        max -= minGraphY;
    }

	plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation: @(minGraphY)
                                                                   length: @(max)];

	plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation: @(-1)
                                                                   length: @(chartSections)];

    //Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPTColor colorWithComponentRed: 215.0f / 255.0f
                                                             green: 215.0f / 255.0f
                                                              blue: 215.0f / 255.0f
                                                             alpha: 1.0f];

    //Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    {
        //X axis
        CPTXYAxis * x                   = axisSet.xAxis;
//        x.orthogonalCoordinateDecimal   = CPTDecimalFromInt(0);
        x.majorIntervalLength           = @(1);
        x.minorTicksPerInterval         = 0;
        x.labelingPolicy                = CPTAxisLabelingPolicyNone;
        x.majorGridLineStyle            = majorGridLineStyle;
        x.alternatingBandFills          = @[
                                          [[CPTColor grayColor] colorWithAlphaComponent: 0.1],
                                          [[CPTColor whiteColor] colorWithAlphaComponent: 0.1]
                                          ];

        //        x.labelingPolicy                = CPTAxisLabelingPolicyFixedInterval;
        //        x.axisConstraints               = [CPTConstraints constraintWithLowerOffset:0.0];

        NSInteger tickCount = 1;

        if(SalesChartDateDisplayDaily == salesChartDisplayMode)
        {
            if(chartSections > 10)
            {
                tickCount             = (NSInteger)ceil(chartSections / 10.0f);
                x.majorIntervalLength = @(tickCount);
            }
        } // End of our chart is daily

        //X labels
        NSMutableArray *customXLabels = [NSMutableArray array];

        NSMutableSet * majorTickLocations = [NSMutableSet set];
        [dateDisplayArray enumerateObjectsUsingBlock: ^(NSString * date, NSUInteger dateIndex, BOOL * stop)
        {
            if(0 != (dateIndex % tickCount))
            {
                return;
            }

            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: date
                                                              textStyle: x.labelTextStyle];

            newLabel.tickLocation   = [NSNumber numberWithUnsignedInteger: dateIndex];
            newLabel.offset         = x.labelOffset + x.majorTickLength;

            [majorTickLocations addObject: [NSNumber numberWithUnsignedInteger: dateIndex]];
            [customXLabels addObject:newLabel];
        }];

        x.axisLabels                    = [NSSet setWithArray:customXLabels];
    }

    //Y axis
	CPTXYAxis *y                    = axisSet.yAxis;
    if(maxGraphY > 5)
    {
        y.majorIntervalLength           = @(maxGraphY / 5);
    }
    else
    {
        y.majorIntervalLength           = @(maxGraphY);
    }

    y.minorTicksPerInterval         = 0;
    y.majorGridLineStyle            = majorGridLineStyle;

    y.axisConstraints               = [CPTConstraints constraintWithLowerOffset: 0.0];
    if(maxGraphY > 100000)
    {
        y.axisConstraints               = [CPTConstraints constraintWithLowerOffset: 15.0];
    }
    else if(maxGraphY > 10000)
    {
        y.axisConstraints               = [CPTConstraints constraintWithLowerOffset: 10.0];
    }
    else if(maxGraphY > 1000)
    {
        y.axisConstraints               = [CPTConstraints constraintWithLowerOffset: 5.0];
    }

    switch(chartDisplayMode)
    {
        case DashboardChartDisplayTotalSales:
        case DashboardChartDisplayUpgrades:
        case DashboardChartDisplayTotalPaidSales:
        case DashboardChartDisplayTotalInAppPurchases:
        case DashboardChartDisplayTotalFreeSales:
        case DashboardChartDisplayPromoCodes:
        case DashboardChartDisplayRefunds:
        case DashboardChartDisplayGiftRedemption:
        case DashboardChartDisplayGiftPurchases:
         	graph.plotAreaFrame.paddingLeft         = 45.0;
            y.labelFormatter        = wholeNumberFormatter;
            break;
        case DashboardChartDisplayTotalRevenue:
            graph.plotAreaFrame.paddingLeft         = 60.0;
            y.labelFormatter        = currencyFormatter;
            break;
        case DashboardChartDisplayMAXIMUM:
            break;
    } // End of chartDisplayMode

    //Create a bar line style
    CPTMutableLineStyle *barLineStyle   = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth              = 0.5;
    barLineStyle.lineColor              = [CPTColor grayColor];

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
	whiteTextStyle.color                = [CPTColor blackColor];

    CPTColor * blueColor = [CPTColor blueColor];

    double rotation = 0;
    if(chartSections > 15)
    {
        rotation = M_PI / 2;
    } // End of more than 14 days

    NSArray * sortedKeys = [[sets allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [sortedKeys enumerateObjectsUsingBlock:^(NSString * set, NSUInteger setIndex, BOOL * stop)
     {
         CPTBarPlot *plot        = [CPTBarPlot tubularBarPlotWithColor: blueColor
                                                        horizontalBars: NO];

         plot.delegate           = self;
         plot.lineStyle          = barLineStyle;

         CGColorRef color        = ((NSColor *)[sets objectForKey: set]).CGColor;
         plot.fill               = [CPTFill fillWithColor: [CPTColor colorWithCGColor:color]];

         plot.barBasesVary       = 0 == setIndex ? NO : YES;

         plot.barWidth           = @(0.8f);
         plot.barsAreHorizontal  = NO;
         plot.dataSource         = self;
         plot.identifier         = set;

         NSUInteger sum = 1; // TODO: Get sum

         // If we have less than 30 days
         if(chartSections < 60)
         {
             // Add a label on our last plot.
             if(setIndex == sets.count - 1 && sum > 0)
             {
                 CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
                 whiteTextStyle.color                = [CPTColor blackColor];

                 switch(chartDisplayMode)
                 {
                     case DashboardChartDisplayTotalSales:
                     case DashboardChartDisplayUpgrades:
                     case DashboardChartDisplayTotalPaidSales:
                     case DashboardChartDisplayTotalInAppPurchases:
                     case DashboardChartDisplayTotalFreeSales:
                     case DashboardChartDisplayPromoCodes:
                     case DashboardChartDisplayRefunds:
                     case DashboardChartDisplayGiftRedemption:
                     case DashboardChartDisplayGiftPurchases:
                         plot.labelFormatter = wholeNumberFormatter;
                         break;
                     case DashboardChartDisplayTotalRevenue:
                         plot.labelFormatter = currencyFormatter;
                         break;
                     case DashboardChartDisplayMAXIMUM:
                         break;
                 } // End of chartDisplayMode

                 plot.labelTextStyle = whiteTextStyle;
                 plot.labelOffset    = 0;
                 plot.labelRotation  = rotation;
             } // End of setIndex loop
         } // End of we have less than 60 chart sections

         [graph addPlot: plot
            toPlotSpace: plotSpace];
     }];

    // If we have no data, then lets add a label
    if(0 == maxGraphY)
    {
        CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
        hitAnnotationTextStyle.color    = [CPTColor blackColor];
        hitAnnotationTextStyle.fontSize = 16.0f;
        hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

        NSArray * anchorPoint = [NSArray arrayWithObjects:
                                 @0,
                                 @0,
                                 nil];

        // Now add the annotation to the plot area
        CPTTextLayer * textLayer           = [[CPTTextLayer alloc] initWithText: NSLocalizedString(@"No Data", nil)
                                                                          style: hitAnnotationTextStyle];
        
        symbolTextAnnotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace: self.hostedGraph.defaultPlotSpace
                                                                              anchorPlotPoint: anchorPoint];

        symbolTextAnnotation.contentLayer = textLayer;
        symbolTextAnnotation.displacement = CGPointMake(self.frame.size.width / 2 - 55, self.frame.size.height / 2 - 20);
        
        [self.hostedGraph addAnnotation: symbolTextAnnotation];
    } // End of no data
}

#pragma mark -
#pragma mark AWTrackedGraphHostingViewProtocol

- (void) trackedGraphHostingView: (AWTrackedGraphHostingView*) trackedGraphHostingView
                    mouseMovedTo: (NSPoint) oldMousePoint
{
    __block AWChartPopoverDetails * _popoverDetails = nil;

    // Enumerate our graphs. Find entries that we are close to.
    [[graph allPlots] enumerateObjectsUsingBlock: ^(CPTBarPlot * barPlot, NSUInteger plotIndex, BOOL * stop)
     {
         // Need to get the mousePoint within the plot.
         //         NSPoint mousePoint = [scatterPlot convertPoint: oldMousePoint fromLayer: nil];
         NSPoint mousePoint = [graph convertPoint: oldMousePoint
                                          toLayer: barPlot];

         NSInteger index = [barPlot dataIndexFromInteractionPoint: mousePoint];

         if(NSNotFound == index)
         {
            return;
         } // End of not found

         NSPoint basePoint, tipPoint;

         if(![barPlot barAtRecordIndex: index
                             basePoint: &basePoint
                              tipPoint: &tipPoint]) return;

         float width = [barPlot lengthInView: barPlot.barWidth.decimalValue] / 2;
         float x = basePoint.x;
         
         int edge = NSMaxXEdge;

         width = -width;
         edge = NSMinXEdge;
         x += width;

         NSPoint point1 = NSMakePoint(x,
                                      basePoint.y + ((tipPoint.y - basePoint.y) / 2));

         NSPoint mouseLocation = [graph convertPoint: point1
                                           fromLayer: barPlot];
         
         double ammount = [self doubleForPlot: barPlot
                                        field: 1
                                  recordIndex: index];

         ammount -= [self doubleForPlot: barPlot
                                  field: 2
                            recordIndex: index];

         NSNumber * ammountNumber = @(ammount);
         NSString * ammountString = @"";

         DashboardChartDisplay chartDisplayMode = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

         switch(chartDisplayMode)
         {
             case DashboardChartDisplayTotalSales:
                 ammountString = [NSString stringWithFormat: @"%@ downloads",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayTotalFreeSales:
                 ammountString = [NSString stringWithFormat: @"%@ free downloads",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayTotalInAppPurchases:
                 ammountString = [NSString stringWithFormat: @"%@ in-app purchases",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayTotalPaidSales:
                 ammountString = [NSString stringWithFormat: @"%@ paid downloads",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayTotalRevenue:
                 ammountString = [NSString stringWithFormat: @"%@ in revenue",
                                  [currencyFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayUpgrades:
                 ammountString = [NSString stringWithFormat: @"%@ upgrades",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;

             case DashboardChartDisplayRefunds:
                 ammountString = [NSString stringWithFormat: @"%@ refund%@",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber],
                                  1 == (NSInteger)ammount ? @"" : @"s"];
                 break;
             case DashboardChartDisplayPromoCodes:
                 ammountString = [NSString stringWithFormat: @"%@ promo codes",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayGiftRedemption:
                 ammountString = [NSString stringWithFormat: @"%@ gift redemptions",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayGiftPurchases:
                 ammountString = [NSString stringWithFormat: @"%@ gift purchases",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
             case DashboardChartDisplayMAXIMUM:
                 ammountString = [NSString stringWithFormat: @"%@ invalid",
                                  [wholeNumberFormatter stringFromNumber: ammountNumber]];
                 break;
         } // End of displayMode switch

         _popoverDetails = [[AWChartPopoverDetails alloc] init];

         _popoverDetails.date = [longDateFormatter stringFromDate: dates[index]];
         _popoverDetails.index = [NSNumber numberWithInteger: index];
         _popoverDetails.identifier = barPlot.identifier;
         _popoverDetails.mouseLocation = NSStringFromPoint(mouseLocation);
         _popoverDetails.edge = [NSNumber numberWithInt: edge];
         _popoverDetails.ammount = ammountString;
    }];

    if(nil != _popoverDetails)
    {
        if(nil == popoverDetails ||
           !([_popoverDetails.index isEqualToNumber: popoverDetails.index] &&
             [_popoverDetails.identifier isEqualToNumber: popoverDetails.identifier]))
        {
            popoverDetails = _popoverDetails;

            [LVDebounce fireAfter: 0.10
                           target: self
                         selector: @selector(displayChartPopover:)
                         userInfo: [popoverDetails copy]];
        } // End of mouseOver
    }
    else
    {
        [LVDebounce fireAfter: 0.10
                       target: self
                     selector: @selector(killChartPopover)
                     userInfo: nil];
    }
}

- (void) displayChartPopover: (id) sender
{
    AWChartPopoverDetails * chartPopoverDetails = (id)[sender userInfo];

    // We should show the popover.
    [self.delegate salesChart: self
shouldDisplayPopoverWithDetails: chartPopoverDetails];
}

- (void) killChartPopover
{
    popoverDetails = nil;
    [self.delegate salesChartShouldHidePopover: self];
}

@end

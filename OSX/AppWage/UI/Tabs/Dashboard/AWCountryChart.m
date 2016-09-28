//
//  CountryChart.m
//  AppWage
//
//  Created by Kyle Hankinson on 2/5/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWCountryChart.h"
#import "AWChartColorHelper.h"
#import "CorePlot.h"
#import "NSNumberExtensions.h"

#import "AWCurrencyHelper.h"

#import "AWApplication.h"
#import "AWProduct.h"
#import "AWCountry.h"

#import "AWDateRangeSelectorViewController.h"

#import "AWSalesChart.h"
#import "AWChartPopoverDetails.h"

@interface CPTPieChart()
-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue;
@end

@interface AWCountryChart() <AWTrackedGraphHostingViewProtocol, CPTPlotDataSource>
{
    dispatch_semaphore_t                countryLoadSemaphore;

    NSSet                               * selectedApplicationIds;

    NSArray                             * sliceData;
    NSArray                             * sliceTitles;

    double                              dataTotal;

    // Popover
    NSTimer                             * popoverTimer;
    AWChartPopoverDetails               * popoverDetails;

    NSNumberFormatter                   * currencyFormatter;
    NSNumberFormatter                   * wholeNumberFormatter;
}
@end

@implementation AWCountryChart

@synthesize pieChartGroupByMode, delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        selectedApplicationIds  = nil;

        countryLoadSemaphore = dispatch_semaphore_create(1);

        wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
        [wholeNumberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [wholeNumberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        wholeNumberFormatter.maximumFractionDigits  = 0;
        
        // Currency formatter
        currencyFormatter = [[NSNumberFormatter alloc] init];

        // set options.
        [currencyFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [currencyFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];

        self.mouseDelegate = self;
    }
    return self;
}

- (void) updateChart
{
    if(0 != dispatch_semaphore_wait(countryLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MachTimer * machTimer = [MachTimer startTimer];

        [self actualUpdateData];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateChartUI];
            // Clear our reset token
            dispatch_semaphore_signal(countryLoadSemaphore);

            NSLog(@"PieChart data finished loading. Took %f", [machTimer elapsedSeconds]);
        });
    });
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

- (void) actualUpdateData
{
    DashboardChartDisplay dashboardType = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

    NSDate * startDate;
    NSDate * endDate;
    
    // Figure out our date ranges
    [AWDateRangeSelectorViewController determineDateRangeForType: kDashboardDateRangeType
                                                       startDate: &startDate
                                                         endDate: &endDate];

    __block NSMutableDictionary * lookup = [NSMutableDictionary dictionary];
    @autoreleasepool {
        switch(pieChartGroupByMode)
        {
            case PieChartByCountry:
            {
                NSArray * countries = [AWCountry allCountries];
                [countries enumerateObjectsUsingBlock:
                 ^(AWCountry * country, NSUInteger index, BOOL * stop) {
                    lookup[country.countryId] = country.name;
                }];

                break;
            }
            case PieChartByApplication:
            {
                NSArray * products = [AWProduct allProducts];
                [products enumerateObjectsUsingBlock:
                 ^(AWProduct * product, NSUInteger index, BOOL * stop) {
                    lookup[product.appleIdentifier] = product.title;
                }];
                break;
            }
        } // End of chartDisplayMode switch
    }

    NSSet * targetApplicationIds = selectedApplicationIds;

    NSMutableString * salesClause = [NSMutableString stringWithFormat: @"cacheType = %d AND date >= %ld AND date <= %ld",
                                     (int)dashboardType,
                                     (long)startDate.timeIntervalSince1970,
                                     (long)endDate.timeIntervalSince1970];

    // If we have specific app ids, then we will use them.
    if(0 != targetApplicationIds.count)
    {
        [salesClause appendFormat: @" AND productId IN (%@)",
         [targetApplicationIds.allObjects componentsJoinedByString: @","]];
    }

    NSString * groupBy = nil;
    NSString * targetTable = nil;

    switch(pieChartGroupByMode)
    {
        case PieChartByCountry:
            groupBy = @"countryId";
            targetTable = @"salesReportCache";
            break;
        case PieChartByApplication:
            groupBy = @"productId";
            targetTable = @"salesReportCachePerApp";
            break;
    } // End of chartDisplayMode switch

    __block NSMutableDictionary * groupValues = [NSMutableDictionary dictionary];
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase* salesDatabase) {
        NSString * salesQuery = [NSString stringWithFormat:
                                 @"SELECT SUM(cacheValue), %@ FROM %@ WHERE %@ GROUP BY %@",
                                 groupBy,
                                 targetTable,
                                 salesClause,
                                 groupBy];

        FMResultSet * results = [salesDatabase executeQuery: salesQuery];
        while([results next])
        {
            NSString * identifier = lookup[[NSNumber numberWithInt: [results intForColumnIndex: 1]]];
            if(nil == identifier) continue;

            NSNumber * currentValue = nil;

            // Get our current value
            currentValue = [NSNumber numberWithDouble: [results doubleForColumnIndex: 0]];

            groupValues[identifier] = currentValue;
        }
    }];

    NSArray * sortedKeys = [groupValues keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        // Switching the order of the operands reverses the sort direction
        return [obj2 compare:obj1];
    }];

    NSString * localizedOther = [NSString stringWithFormat: @"%@ (%ld)",
                                 NSLocalizedString(@"Others", nil),
                                 sortedKeys.count - 5];

    NSMutableDictionary * dataValues = [NSMutableDictionary dictionary];
    [sortedKeys enumerateObjectsUsingBlock: ^(NSString * key, NSUInteger index, BOOL * stop)
     {
         if(index < 5)
         {
             dataValues[key] = groupValues[key];
         }
         else
         {
             NSNumber * otherValue = dataValues[localizedOther];
             dataValues[localizedOther] = [NSNumber numberWithDouble: otherValue.doubleValue + [groupValues[key] doubleValue]];
         }
     }];

    NSMutableArray * _sliceData   = [NSMutableArray array];
    NSMutableArray * _sliceTitles = [NSMutableArray array];

    sortedKeys = [dataValues keysSortedByValueUsingComparator:^(id obj1, id obj2) {
        // Switching the order of the operands reverses the sort direction
        return [obj2 compare:obj1];
    }];

    [sortedKeys enumerateObjectsUsingBlock: ^(NSString * key, NSUInteger index, BOOL * stop)
     {
         [_sliceData addObject: dataValues[key]];
         [_sliceTitles addObject: key];
     }];

    // Set our data and titles
    sliceData   = [_sliceData copy];
    dataTotal   = [[sliceData valueForKeyPath: @"@sum.self"] doubleValue];
    sliceTitles = [_sliceTitles copy];
} // End of actualUpdateData

- (void) updateChartUI
{
    CPTXYGraph * graph = [[CPTXYGraph alloc] initWithFrame: CGRectZero];
    self.hostedGraph = graph;

    graph.paddingTop    = 25;
    graph.paddingBottom = graph.paddingLeft = graph.paddingRight = 0;
    graph.paddingBottom = 55;

    DashboardChartDisplay dashboardType = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

    switch(pieChartGroupByMode)
    {
        case PieChartByApplication:
            switch(dashboardType)
            {
                case DashboardChartDisplayGiftRedemption:
                    graph.title = NSLocalizedString(@"Gift redemptions by application", nil);
                    break;
                case DashboardChartDisplayGiftPurchases:
                    graph.title = NSLocalizedString(@"Gift purchases by application", nil);
                    break;
                case DashboardChartDisplayPromoCodes:
                    graph.title = NSLocalizedString(@"Promo codes by application", nil);
                    break;
                case DashboardChartDisplayRefunds:
                    graph.title = NSLocalizedString(@"Refunds by application", nil);
                    break;
                case DashboardChartDisplayTotalSales:
                    graph.title = NSLocalizedString(@"Total sales by application", nil);
                    break;
                case DashboardChartDisplayTotalFreeSales:
                    graph.title = NSLocalizedString(@"Free sales by application", nil);
                    break;
                case DashboardChartDisplayTotalInAppPurchases:
                    graph.title = NSLocalizedString(@"In-App purchases by application", nil);
                    break;
                case DashboardChartDisplayTotalPaidSales:
                    graph.title = NSLocalizedString(@"Paid sales by application", nil);
                    break;
                case DashboardChartDisplayTotalRevenue:
                    graph.title = NSLocalizedString(@"Total revenue by application", nil);
                    break;
                case DashboardChartDisplayUpgrades:
                    graph.title = NSLocalizedString(@"Upgrades by application", nil);
                    break;
                case DashboardChartDisplayMAXIMUM:
                    graph.title = NSLocalizedString(@"Invalid", nil);
                    break;
            }
            break;
        case PieChartByCountry:
        {
            switch(dashboardType)
            {
                case DashboardChartDisplayGiftPurchases:
                    graph.title = NSLocalizedString(@"Gift purchase by country", nil);
                    break;
                case DashboardChartDisplayGiftRedemption:
                    graph.title = NSLocalizedString(@"Gift redemption by country", nil);
                    break;
                case DashboardChartDisplayPromoCodes:
                    graph.title = NSLocalizedString(@"Promo codes by country", nil);
                    break;
                case DashboardChartDisplayRefunds:
                    graph.title = NSLocalizedString(@"Refunds by country", nil);
                    break;
                case DashboardChartDisplayTotalSales:
                    graph.title = NSLocalizedString(@"Total sales by country", nil);
                    break;
                case DashboardChartDisplayTotalFreeSales:
                    graph.title = NSLocalizedString(@"Free sales by country", nil);
                    break;
                case DashboardChartDisplayTotalInAppPurchases:
                    graph.title = NSLocalizedString(@"In-App purchases by country", nil);
                    break;
                case DashboardChartDisplayTotalPaidSales:
                    graph.title = NSLocalizedString(@"Paid sales by country", nil);
                    break;
                case DashboardChartDisplayTotalRevenue:
                    graph.title = NSLocalizedString(@"Total revenue by country", nil);
                    break;
                case DashboardChartDisplayUpgrades:
                    graph.title = NSLocalizedString(@"Upgrades by country", nil);
                    break;
                case DashboardChartDisplayMAXIMUM:
                    graph.title = NSLocalizedString(@"Invalid", nil);
                    break;
            }
            break;
        }
    } // End of chart switch

    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor whiteColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = 13;
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.8) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

    CPTPieChart *pieChart                   = [[CPTPieChart alloc] init];
    pieChart.backgroundColor                = [NSColor grayColor].CGColor;
    pieChart.dataSource                     = self;
    pieChart.pieRadius                      = 85.0;
    pieChart.pieInnerRadius                 = 40.0;
    pieChart.identifier                     = @"PieChart1";
    pieChart.startAngle                     = M_PI_4;
    pieChart.sliceDirection                 = CPTPieDirectionClockwise;
    pieChart.labelRotationRelativeToRadius  = YES;
    pieChart.labelRotation                  = -M_PI_2;
    pieChart.labelOffset                    = -20.0;
    
    CPTMutableLineStyle * lineStyle         = [pieChart.plotArea.borderLineStyle mutableCopy];
    lineStyle.lineWidth = 10;
    lineStyle.lineColor = [CPTColor whiteColor];
    pieChart.plotArea.borderLineStyle       = lineStyle;

    BOOL animated                           = [[AWSystemSettings sharedInstance] graphAnimationsEnabled];
    animated = NO;

    pieChart.startAngle                     = animated ? M_PI_2     : M_PI_2;
    pieChart.endAngle                       = animated ? M_PI_2 * 5 : M_PI_2;

    if ( animated )
    {
        [CPTAnimation animate: pieChart
                     property: @"endAngle"
                         from: M_PI_2 * 5
                           to: M_PI_2
                     duration: 0.50];
    }

    CPTColor * color1 = [CPTColor colorWithComponentRed:CPTFloat(0.20) green:CPTFloat(0.20) blue:CPTFloat(0.20) alpha:CPTFloat(1.0)];
    CPTColor * color2 = [CPTColor colorWithComponentRed:CPTFloat(0.25) green:CPTFloat(0.25) blue:CPTFloat(0.25) alpha:CPTFloat(1.0)];

    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor: color1
                                                        endingColor: color2];

    gradient.angle = CPTFloat(90.0);
    
    graph.fill = [CPTFill fillWithGradient: gradient];

    [graph addPlot:pieChart];

    // If we have data
    if(sliceTitles.count > 0)
    {
        CPTLegend * legend = [CPTLegend legendWithGraph: graph];
        CPTMutableTextStyle *textStyle = [legend.textStyle mutableCopy];
        textStyle.color = [CPTColor whiteColor];
        legend.textStyle = textStyle;

        legend.rowMargin = 6;
        legend.columnMargin = 25;

        [graph setLegend: legend];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSString *)legendTitleForPieChart: (CPTPieChart *)pieChart
                        recordIndex: (NSUInteger)index
{
    if(index >= sliceTitles.count) return @"";

    NSString * legendTitle = sliceTitles[index];

    if(legendTitle.length > 15)
    {
        return [NSString stringWithFormat: @"%@...", [legendTitle substringToIndex: 15]];
    }

    return legendTitle;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [sliceData count];
}

-(NSNumber *)numberForPlot: (CPTPlot *)plot
                     field: (NSUInteger)fieldEnum
               recordIndex: (NSUInteger)index
{
	return [sliceData objectAtIndex:index];
}



-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    NSColor * plotColor = [AWChartColorHelper colorForIndex: index];
	CPTFill * fill = [CPTFill fillWithColor: [CPTColor colorWithCGColor: plotColor.CGColor]];
	return fill;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    double limitPercent = fabs(dataTotal * 0.05);
    double currentValue = fabs([[self numberForPlot: plot
                                         field: 0
                                   recordIndex: index] doubleValue]);

    if(currentValue > limitPercent)
    {
        CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
        textStyle.color = [CPTColor colorWithCGColor: [NSColor blackColor].CGColor];
        textStyle.fontSize = 11;

        NSString * displayString = [NSString stringWithFormat: @"%0.0f", currentValue];

        CPTTextLayer *label = [[CPTTextLayer alloc] initWithText: displayString
                                                           style: textStyle];

        return label;
    }

    return nil;
}

#pragma mark -
#pragma mark AWTrackedGraphHostingViewProtocol

- (void) trackedGraphHostingView: (AWTrackedGraphHostingView*) trackedGraphHostingView
                    mouseMovedTo: (NSPoint) oldMousePoint
{
    __block AWChartPopoverDetails * _popoverDetails = nil;

    // Enumerate our graphs. Find entries that we are close to.
    [[self.hostedGraph allPlots] enumerateObjectsUsingBlock:
     ^(CPTPieChart * pieChart, NSUInteger chartIndex, BOOL * stop)
     {
         // Need to get the mousePoint within the plot.
         //         NSPoint mousePoint = [scatterPlot convertPoint: oldMousePoint fromLayer: nil];
         NSPoint mousePoint = [self.hostedGraph convertPoint: oldMousePoint
                                                     toLayer: pieChart];

         NSInteger index = [pieChart dataIndexFromInteractionPoint: mousePoint];
         if(NSNotFound == index) return;

         double value = [[self numberForPlot: pieChart
                                       field: 0
                                 recordIndex: index] doubleValue];

         double percentage = (value / dataTotal) * 100;

        DashboardChartDisplay dashboardType = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

         NSNumberFormatter * targetFormatter;

         switch(dashboardType)
         {
             case DashboardChartDisplayTotalRevenue:
                 targetFormatter = currencyFormatter;
                 break;
             default:
                 targetFormatter = wholeNumberFormatter;
                 break;
         } // End of dashboardType

         // Set our details
         NSString * details =
            [NSString stringWithFormat: @"%@ (%0.0f%%)",
                [targetFormatter stringFromNumber: [NSNumber numberWithDouble: fabs(value)]], percentage];

         CGPoint popoverLocation = CGPointZero;
         NSInteger edge = NSMinXEdge;
         {
             CPTPlotArea *thePlotArea = pieChart.plotArea;

             if ( thePlotArea )
             {
                 CGRect plotAreaBounds = thePlotArea.bounds;
                 CGPoint anchor        = pieChart.centerAnchor;
                 CGPoint centerPoint   = CPTPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
                                                      plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);

                 NSDecimal plotPoint[2];
                 [pieChart.plotSpace plotPoint:plotPoint numberOfCoordinates:2 forPlotAreaViewPoint:centerPoint];
                 NSDecimalNumber *xValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateX]];
                 NSDecimalNumber *yValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateY]];

                 CGFloat currentWidth = (CGFloat)[pieChart cachedDoubleForField : CPTPieChartFieldSliceWidthNormalized recordIndex : index];

                 // Set our popoverLocation
                 popoverLocation = CGPointMake(xValue.floatValue, yValue.floatValue);

                 if ( !isnan(currentWidth) )
                 {
                     CGFloat radialOffset = [(NSNumber *)[pieChart cachedValueForKey:CPTPieChartBindingPieSliceRadialOffsets recordIndex: index] cgFloatValue];
                     CGFloat labelRadius  = pieChart.pieRadius + radialOffset;

                     CGFloat startingWidth = CPTFloat(0.0);
                     if ( index > 0 )
                     {
                         startingWidth = (CGFloat)[pieChart cachedDoubleForField : CPTPieChartFieldSliceWidthSum recordIndex : index - 1];
                     }

                     CGFloat labelAngle = [pieChart radiansForPieSliceValue: startingWidth + currentWidth / CPTFloat(2.0)];

                     NSPoint displacement = CPTPointMake( labelRadius * cos(labelAngle), labelRadius * sin(labelAngle));

                     float height = (pieChart.frame.size.height / 2);
                     float width  = (pieChart.frame.size.width / 2);
                     displacement = NSMakePoint(width + displacement.x,
                                                height + displacement.y
                                                );

                     if(displacement.x > width)
                     {
                         edge = NSMaxXEdge;
                     }

                     popoverLocation = [self.hostedGraph convertPoint: displacement
                                                            fromLayer: pieChart];
                 }
             }
         }

         if(popoverLocation.x == CGPointZero.x && popoverLocation.y == CGPointZero.y)
         {
             popoverLocation = oldMousePoint;
         }

         // Get our details
         _popoverDetails = [[AWChartPopoverDetails alloc] init];
         _popoverDetails.index = [NSNumber numberWithInteger: index];
         _popoverDetails.percentage = [NSNumber numberWithDouble: percentage];
         _popoverDetails.value = [NSNumber numberWithDouble: value];
         _popoverDetails.details = details;
         _popoverDetails.country = sliceTitles[index];
         _popoverDetails.mouseLocation = NSStringFromPoint(popoverLocation);
         _popoverDetails.edge =[ NSNumber numberWithInteger: edge];
     }];

    if(nil != _popoverDetails)
    {
        if(nil == popoverDetails ||
           ![_popoverDetails.index isEqualToNumber: popoverDetails.index])
        {
            popoverDetails = _popoverDetails;

            [popoverTimer invalidate];
            popoverTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                            target: self
                                                          selector: @selector(displayChartPopover:)
                                                          userInfo: [popoverDetails copy]
                                                           repeats: NO];
            
            [[NSRunLoop mainRunLoop] addTimer: popoverTimer
                                      forMode: NSDefaultRunLoopMode];
        } // End of mouseOver
    }
    else
    {
        [popoverTimer invalidate];
        popoverTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                        target: self
                                                      selector: @selector(killChartPopover)
                                                      userInfo: nil
                                                       repeats: NO];
        [[NSRunLoop mainRunLoop] addTimer: popoverTimer
                                  forMode: NSDefaultRunLoopMode];
    }
}

- (void) displayChartPopover: (id) sender
{
    AWChartPopoverDetails * chartPopoverDetails = (id) [sender userInfo];

    // We should show the popover.
    [self.delegate countryChart: self
shouldDisplayPopoverWithDetails: chartPopoverDetails];
}

- (void) killChartPopover
{
    popoverDetails = nil;
    [self.delegate countryChartShouldHidePopover: self];
}

@end

//
//  KeywordsViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWKeywordsViewController.h"
#import "AWApplication.h"
#import "AWCountry.h"
#import "AWRankTableCell.h"
#import "AWChartColorHelper.h"
#import "BackgroundView.h"
#import "AWCollectionOperationQueue.h"
#import "AWDateRangeSelectorViewController.h"
#import "AWFilterTableHeaderView.h"
#import "AWTrackedGraphHostingView.h"
#import "ImageAndTextCell.h"
#import "InvertedNumberFormatter.h"
#import <CorePlot.h>

@interface KeywordRankEntry : NSObject

@property(nonatomic,copy) NSNumber * applicationKeywordId;
@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,copy) NSString * keyword;
@property(nonatomic,copy) NSNumber * countryId;
@property(nonatomic,copy) NSNumber * position;
@property(nonatomic,copy) NSDate   * positionDate;

@end

@implementation KeywordRankEntry

@end

@interface LatestKeywordRankEntry : NSObject

@property(nonatomic,copy) NSNumber * rank;
@property(nonatomic,copy) NSNumber * change;
@property(nonatomic,copy) NSString * countryCode;
@property(nonatomic,retain) id country;
@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,retain) id application;
@property(nonatomic,copy) NSString * keyword;
@property(nonatomic,copy) NSNumber * lastSeen;
@property(nonatomic,copy) NSString * identifier;
@property(nonatomic,copy) NSColor * chartColor;

@end

@implementation LatestKeywordRankEntry

@end

@interface KeywordChartEntry : NSObject

@property(nonatomic,copy) NSNumber * applicationKeywordId;
@property(nonatomic,weak) NSString * identifier;
@property(nonatomic,retain) id data;
@property(nonatomic,copy) id application;
@property(nonatomic,copy) id country;
@property(nonatomic,copy) id countryCode;
@property(nonatomic,copy) id keyword;
@property(nonatomic,copy) id applicationId;
@property(nonatomic,copy) id countryId;

@end

@implementation KeywordChartEntry

@end

@interface KeywordTooltipEntry : NSObject

@property(nonatomic,copy) NSString * identifier;
@property(nonatomic,copy) NSNumber * index;
@property(nonatomic,copy) NSString * mouseLocation;
@property(nonatomic,copy) NSColor  * color;

@end

@implementation KeywordTooltipEntry


@end

@interface AWKeywordsViewController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSProgressIndicator          * keywordLoadingProgressIndicator;
    IBOutlet BackgroundView               * topToolbarView;
    IBOutlet NSTableView                  * keywordTableView;
    IBOutlet NSButton                     * dateRangeButton;

    IBOutlet NSPopover                    * rankPopover;
    NSPopover                             * countryPopover;

    IBOutlet    AWTrackedGraphHostingView * graphHostView;
    CPTGraph                              * graph;

    // Date range filter
    AWDateRangeSelectorViewController     * dateRangeSelectorViewController;
    NSPopover                             * dateRangeSelectorPopover;
}
@end

@implementation AWKeywordsViewController
{
    NSSet<NSNumber*>                * currentApplications;
    BOOL                            requiresReload;
    
    NSArray                               * rankArray;
    NSArray                               * latestRanks;
    NSDictionary                          * plotData;

    NSArray<KeywordTooltipEntry*>         * rankPopoverDetails;
    NSTimer                               * popoverTimer;
    
    dispatch_semaphore_t                  rankLoadSemaphore;
}

static const NSNumber * xCord;
static const NSNumber * yCord;

static NSDateFormatter * rankTableDateFormatter;

+ (void) initialize
{
    xCord = [NSNumber numberWithUnsignedInteger: CPTScatterPlotFieldX];
    yCord = [NSNumber numberWithUnsignedInteger: CPTScatterPlotFieldY];
    
    rankTableDateFormatter = [AWDateHelper dateTimeFormatter];
}

- (id) init
{
    self = [super init];
    if(self)
    {
        rankLoadSemaphore        = dispatch_semaphore_create(1);
        
        currentApplications = [NSSet set];
        requiresReload      = YES;
    }

    return self;
} // End of init

- (void) awakeFromNib
{
    topToolbarView.image = [NSImage imageNamed: @"Toolbar-Background"];

    // Set our date range
    [dateRangeButton setTitle: [AWDateRangeSelectorViewController dateRangeStringForType: kKeywordRankGraphDateRangeType]];
    [dateRangeButton sizeToFit];
    [dateRangeButton setFrame: NSMakeRect(topToolbarView.frame.size.width - dateRangeButton.frame.size.width - 5,
                                          dateRangeButton.frame.origin.y,
                                          dateRangeButton.frame.size.width,
                                          dateRangeButton.frame.size.height)];

    // apply our custom ImageAndTextCell for rendering the first column's cells
    NSTableColumn *tableColumn = [keywordTableView tableColumnWithIdentifier: @"Country"];
    ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setEditable: NO];
    [tableColumn setDataCell: imageAndTextCell];

    // Get our rank
    NSTableColumn * changeTableColumn = [keywordTableView tableColumnWithIdentifier: @"Change"];
    AWRankTableCell * changeTableCell = [[AWRankTableCell alloc] init];
    changeTableCell.editable = NO;
    [changeTableColumn setDataCell: changeTableCell];

    // Watch for rank data change.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onNewKeywordRanks:)
                                                 name: [AWCollectionOperationQueue newKeywordRanksNotificationName]
                                               object: nil];
}

- (void) onNewKeywordRanks: (NSNotification*) aNotification
{
    if(_isFocusedTab)
    {
        NSLog(@"Has new keyword ranks and is focused. Want to reload.");
        [self reloadRanks];
        requiresReload = NO;
    }
    else
    {
        NSLog(@"Has new keyword ranks but is not focused. Not reloading.");
        requiresReload = YES;
    }
} // End of newRanks

- (void) setIsFocusedTab: (BOOL) isFocusedTab
{
    // If we were not focused, we are now and we require a reload.
    if(!_isFocusedTab && isFocusedTab && requiresReload)
    {
        // Start reloading the applications
//        [self updateFilters];
        [self reloadRanks];

        requiresReload = NO;
    } // End of we need to reload the applications.

    _isFocusedTab = isFocusedTab;
} // End of setIsFocusedTab:

- (void) setSelectedApplications: (NSSet*) newApplications
{
    if(nil != newApplications)
    {
        // If our apps have changed then we will deselect the table.
        if(![currentApplications isEqualToSet: newApplications])
        {
            [keywordTableView deselectAll: self];
        }

        currentApplications = newApplications;
    } // End of applications was not nil

    // If we are not focused, then just set a require reload.
    // We will load it once the user focuses.
    if(!_isFocusedTab)
    {
        requiresReload = YES;
        return;
    } // End of we were not focused

    // Otherwise, we are the selected tab. Need to reload.
//    [self updateFilters];
    [self reloadRanks];
} // End of setSelectedApplications

- (IBAction) onDownloadKeywordRanks: (id) sender
{
    // Queue our keywordRanks
    [AWCollectionOperationQueue.sharedInstance queueKeywordRankCollectionWithTimeInterval: 0
                                                                          specifiedAppIds: nil];
}

- (IBAction) onDateRange: (id)sender
{
    if(nil != dateRangeSelectorPopover)
    {
        if([dateRangeSelectorPopover isShown])
        {
            [dateRangeSelectorPopover close];
            return;
        }
    }

    // Setup our view controller
    dateRangeSelectorViewController = [[AWDateRangeSelectorViewController alloc] init];
    dateRangeSelectorViewController.delegate = self;
    dateRangeSelectorViewController.dateRangeUserDefault = kRankGraphDateRangeType;

    dateRangeSelectorPopover = [[NSPopover alloc] init];
    dateRangeSelectorPopover.delegate = self;
    [dateRangeSelectorPopover setBehavior: NSPopoverBehaviorSemitransient];
    [dateRangeSelectorPopover setContentViewController: dateRangeSelectorViewController];
    [dateRangeSelectorPopover showRelativeToRect: [sender bounds]
                                          ofView: sender
                                   preferredEdge: NSMaxYEdge];

} // End of onDateRange

- (void) initializeGraph: (NSDate*) firstDayInRange
                 endDate: (NSDate*) lastDayInRange
{
    NSLog(@"Initialize graph called with range: %@ - %@",
          firstDayInRange, lastDayInRange);

    // Figure out how many days are selected
    long dayCount =
        [AWDateRangeSelectorViewController daysBetween: firstDayInRange
                                                   and: lastDayInRange];

    NSTimeInterval test1 = [firstDayInRange timeIntervalSince1970];
    NSTimeInterval test2 = [lastDayInRange timeIntervalSince1970] - test1;

    NSLog(@"Daycount is: %ld.", dayCount);

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(graphHostView.bounds);
#endif

    graph = [[CPTXYGraph alloc] initWithFrame:bounds];

    graphHostView.hostedGraph = graph;
    
    //    [graph applyTheme:[CPTTheme themeNamed: kCPTDarkGradientTheme]];
    //    [graph applyTheme:[CPTTheme themeNamed: kCPTSlateTheme]];
    //    [graph applyTheme:[CPTTheme themeNamed: kCPTPlainWhiteTheme]];
    
    
    //    graph.plotAreaFrame.paddingTop    = 15.0;
    graph.plotAreaFrame.paddingBottom = 15.0;
    graph.plotAreaFrame.paddingLeft   = 20.0;
    graph.plotAreaFrame.masksToBorder = NO;
    graph.backgroundColor             = [[NSColor whiteColor] CGColor];
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation: @(test1)
                                                    length: @(test2)];

    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation: @(1.0)
                                                    length: @([self graphYMax])];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [CPTColor colorWithComponentRed: 215.0f / 255.0f
                                                             green: 215.0f / 255.0f
                                                              blue: 215.0f / 255.0f
                                                             alpha: 1.0f];

    CPTXYAxis    * x               = axisSet.xAxis;

    DateRangeType dateRangeType =
        [AWDateRangeSelectorViewController dateRangeForType: kRankGraphDateRangeType];

    // Setup our title
    graph.titleDisplacement = NSMakePoint(0, 18);

    // Setup our date formatter
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
//    dateFormatter.timeZone         = [NSTimeZone timeZoneWithName:@"UTC"];

    // One day
    if(DateRangeToday == dateRangeType)
    {
        // Set our title
//        graph.title = [dateFormatter stringFromDate: firstDayInRange];

        x.majorIntervalLength          = @(timeIntervalHour);
        x.majorGridLineStyle           = majorGridLineStyle;
//        x.orthogonalCoordinateDecimal  = CPTDecimalFromDouble(0.0);
        x.minorTicksPerInterval        = 1;
        x.alternatingBandFills         = [NSArray arrayWithObjects:
                                          [[CPTColor grayColor] colorWithAlphaComponent: 0.1],
                                          [[CPTColor whiteColor] colorWithAlphaComponent: 0.1],
                                          nil];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone         = [NSTimeZone timeZoneWithName:@"UTC"];

        //dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
        dateFormatter.timeStyle         = kCFDateFormatterShortStyle;
        CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter: dateFormatter];
        timeFormatter.referenceDate     = [NSDate dateWithTimeIntervalSince1970: 0];
        x.labelFormatter                = timeFormatter;
        x.labelRotation                 = M_PI_4;

        graph.plotAreaFrame.paddingBottom   = 35.0;
        graph.plotAreaFrame.paddingRight    = 0.0;
    }
    // Spanning a few days (we will display in hours instead of days)
    else
    {
/*
        // Set our title
        graph.title = [NSString stringWithFormat: @"%@ - %@",
                       [dateFormatter stringFromDate: firstDayInRange],
                       [dateFormatter stringFromDate: lastDayInRange]];
*/
        x.majorIntervalLength          = @(timeIntervalDay);
        x.majorGridLineStyle           = majorGridLineStyle;
        x.minorTicksPerInterval        = 1;
        x.alternatingBandFills         = [NSArray arrayWithObjects:
                                          [[CPTColor grayColor] colorWithAlphaComponent: 0.1],
                                          [[CPTColor whiteColor] colorWithAlphaComponent: 0.1],
                                          nil];

        NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
        CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter: dateFormatter];
        timeFormatter.referenceDate     = [NSDate dateWithTimeIntervalSince1970: 0];
        x.labelFormatter                = timeFormatter;

        graph.plotAreaFrame.paddingRight  = 15.0;

        if(dayCount > 10)
        {
            NSInteger tickCount = dayCount / 10;
            x.majorIntervalLength          = @((timeIntervalDay * tickCount));
        }
    }

    CPTXYAxis *y                    = axisSet.yAxis;
    y.majorIntervalLength           = @([self graphYMax] / 5);
    y.minorTicksPerInterval         = 0;
    y.majorGridLineStyle            = majorGridLineStyle;
//    y.orthogonalCoordinateDecimal   = @(test1);
    
    if([AWSystemSettings sharedInstance].RankGraphInvertChart)
    {
        InvertedNumberFormatter * invertedNumberFormatter =
            [[InvertedNumberFormatter alloc] initWithMax:  [self graphYMax] + 1];

        y.labelFormatter = invertedNumberFormatter;
    }
    else
    {
        NSNumberFormatter * wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
        wholeNumberFormatter.maximumFractionDigits  = 0;

        y.labelFormatter                = wholeNumberFormatter;
    }
} // End of initializeGraph

- (NSUInteger) graphYMax
{
    // [AWSystemSettings sharedInstance].rankGraphMax
    return 100;
}

- (void) addPlotEntryWithIdentifier: (NSString*) identifier color: (CPTColor*) lineColor
{
    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = identifier;
    dataSourceLinePlot.plotSymbolMarginForHitDetection = 0.1f;

    if(0 == [[AWSystemSettings sharedInstance] rankGraphChartLineStyle])
    {
        dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    }
    else
    {
        dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationLinear;
    }

    CPTMutableLineStyle *lineStyle   = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = lineColor;
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;

    [graph addPlot: dataSourceLinePlot];

    CPTPlotSymbol *plotSymbol            = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill                      = [CPTFill fillWithColor: lineColor];
    plotSymbol.lineStyle                 = lineStyle;
    plotSymbol.size                      = CGSizeMake(3.0, 3.0);
    dataSourceLinePlot.plotSymbol        = plotSymbol;
}

- (void) reloadRanks
{
    // Set our date range
    [dateRangeButton setTitle: [AWDateRangeSelectorViewController dateRangeStringForType: kRankGraphDateRangeType]];
    [dateRangeButton sizeToFit];
    [dateRangeButton setFrame: NSMakeRect(topToolbarView.frame.size.width - dateRangeButton.frame.size.width - 5,
                                          dateRangeButton.frame.origin.y,
                                          dateRangeButton.frame.size.width,
                                          dateRangeButton.frame.size.height)];

    if(nil == currentApplications)
    {
        return;
    }

    NSLog(@"reloadRanks entered (before singleton)");

    if(0 != dispatch_semaphore_wait(rankLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    [keywordLoadingProgressIndicator startAnimation: self];

    NSLog(@"reloadRanks entered singleton.");

    NSArray<NSSortDescriptor*>* sortDescriptors = keywordTableView.sortDescriptors.copy;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            NSDate * endDate     = nil;
            NSDate * startDate   = nil;

            // Figure out our date ranges
            [AWDateRangeSelectorViewController determineDateRangeForType: kKeywordRankGraphDateRangeType
                                                               startDate: &startDate
                                                                 endDate: &endDate];

            NSLog(@"reloadRanks - Going to reloadData.");

            // Graph has been updated. Load our data.
            [self reloadDataInContext: startDate
                              endDate: endDate
                      sortDescriptors: sortDescriptors];

            dispatch_sync(dispatch_get_main_queue(), ^{
                // Initialize our graph
                [self initializeGraph: startDate
                              endDate: endDate];

                [self redrawChart];

                [keywordTableView reloadData];

                // Clear our lock
                dispatch_semaphore_signal(rankLoadSemaphore);
                
                [keywordLoadingProgressIndicator stopAnimation: self];
            });
        } // End of autorelease pool
    }); // End of dispatch_async
} // End of reloadRanks

- (void) reloadDataInContext: (NSDate*) startDate
                     endDate: (NSDate*) endDate
             sortDescriptors: (NSArray<NSSortDescriptor*>*) sortDescriptors
{
    NSLog(@"Want to reload ranks with applications: %@", currentApplications);

    NSPredicate * filteredCountryPredicate =
        [NSPredicate predicateWithFormat: @"countryCode IN %@",
            [[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphCountryFilterUserDefault]];

    NSLog(@"Country code predicate: %@", filteredCountryPredicate.predicateFormat);
    
    NSArray<AWCountry*> * countriesWeCareAbout = [[AWCountry allCountries] filteredArrayUsingPredicate: filteredCountryPredicate];
    NSArray<NSNumber*>* countryIds = [countriesWeCareAbout valueForKey: @"countryId"];

    __block NSMutableArray<KeywordRankEntry*> * sqliteRankArray = [NSMutableArray array];
    [[AWSQLiteHelper keywordsDatabaseQueue] inDatabase: ^(FMDatabase * database) {

        NSString * positionDateClause =
            [NSString stringWithFormat: @" positionDate >= %ld AND positionDate <= %ld",
                 (unsigned long)startDate.timeIntervalSince1970,
                 (unsigned long)endDate.timeIntervalSince1970];

        NSString * queryString = [NSString stringWithFormat:
            @"SELECT applicationKeyword.applicationKeywordId,applicationId,countryId,keyword,position,positionDate FROM applicationKeywordRank INNER JOIN applicationKeyword ON applicationKeywordRank.applicationKeywordId = applicationKeyword.applicationKeywordId WHERE %@ ORDER BY positionDate", positionDateClause];

        FMResultSet * rankResults = [database executeQuery: queryString];

        while([rankResults next])
        {
            NSNumber * applicationId = [NSNumber numberWithInt: [rankResults intForColumn: @"applicationId"]];

            // If the application id is not in our selection, ignore the row.
            if(nil != currentApplications && currentApplications.count > 0)
            {
                if(![currentApplications containsObject: applicationId])
                {
                    continue;
                }
            }

            NSNumber * countryId = [NSNumber numberWithInt: [rankResults intForColumn: @"countryId"]];
            if(![countryIds containsObject: countryId])
            {
                continue;
            }

            KeywordRankEntry * rankEntry = [[KeywordRankEntry alloc] init];

            rankEntry.applicationKeywordId = [NSNumber numberWithInt: [rankResults intForColumn: @"applicationKeywordId"]];
            rankEntry.applicationId = applicationId;
            rankEntry.countryId = countryId;
            rankEntry.keyword = [rankResults stringForColumn: @"keyword"];

            rankEntry.position = [NSNumber numberWithInt: [rankResults intForColumn: @"position"]];

            NSInteger timestamp = [rankResults intForColumn: @"positionDate"];
            NSDate * positionDate = [NSDate dateWithTimeIntervalSince1970: timestamp];
            rankEntry.positionDate = positionDate;

            [sqliteRankArray addObject: rankEntry];
        } // End of rank rows loop

        NSLog(@"There are %ld ranks.", sqliteRankArray.count);
    }];

    NSMutableDictionary<NSString*,KeywordChartEntry*> * newChartEntries = [NSMutableDictionary dictionary];

    [sqliteRankArray enumerateObjectsUsingBlock:
     ^(KeywordRankEntry * entry, NSUInteger rankIndex, BOOL * stop)
     {
         // Temp identifier.
         NSString * tempIdentifier = entry.applicationKeywordId.stringValue;

         KeywordChartEntry * identifierDetails = newChartEntries[tempIdentifier];
         NSMutableArray * currentEntries = identifierDetails.data;

         if(nil == currentEntries)
         {
             currentEntries = [NSMutableArray array];
             identifierDetails.data = currentEntries;

             NSNumber * countryId = entry.countryId;
             AWCountry * country = [AWCountry lookupByCountryId: countryId];
             if(nil == country)
             {
                 return;
             }

             NSNumber * applicationId = entry.applicationId;
             AWApplication * application =
                [AWApplication applicationByApplicationId: applicationId];

             if(nil == application)
             {
                 return;
             }

             KeywordChartEntry * chartEntry = [[KeywordChartEntry alloc] init];

             chartEntry.identifier = tempIdentifier;
             chartEntry.data = currentEntries;
             chartEntry.application = application.name;
             chartEntry.country = country.name;
             chartEntry.countryCode = country.countryCode;
             chartEntry.applicationId = entry.applicationId;
             chartEntry.countryId = entry.countryId;
             chartEntry.keyword = entry.keyword;

             newChartEntries[tempIdentifier] = chartEntry;
         } // End of we have no entry.

         NSTimeInterval temp = [entry.positionDate timeIntervalSince1970];

         [currentEntries addObject:
          @{
            xCord : [NSDecimalNumber numberWithFloat: temp],
            yCord: entry.position
            }];
     }];

    NSLog(@"Preparing data to reload rank chart.");

    __block NSMutableArray<LatestKeywordRankEntry*> * _latestRanks = [NSMutableArray array];

    [newChartEntries enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, KeywordChartEntry * obj, BOOL * stop)
    {
         NSArray * plotPoints = obj.data;
        
        if(0 == plotPoints.count)
        {
            return;
        } // End of no plotPoints

         NSArray * sortedPoints = [plotPoints sortedArrayUsingComparator: ^(id obj1, id obj2) {
             NSNumber * cmp1 = [obj1 objectForKey: xCord];
             NSNumber * cmp2 = [obj2 objectForKey: xCord];
             return [cmp2 compare: cmp1];
         }];

         NSDictionary * firstEntry = sortedPoints[0];
         __block NSNumber     * change = @0;

         // If we have more than one rank, then we can use the previous entry as our change.
         if(sortedPoints.count > 1)
         {
             NSDictionary * secondEntry = sortedPoints[1];
             change = [NSNumber numberWithInteger: [[secondEntry objectForKey: yCord] integerValue] - [[firstEntry objectForKey: yCord] integerValue]];
         }
         else
         {
             // We only had one rank. This is possible say the first entry on a 24 hour period chart. There may only be one rank visible, but we still want to display the change. In this instance we will load the change (we don't do this all the time as it slows things down).
             NSNumber * latestDate = [firstEntry objectForKey: xCord];
             NSTimeInterval latestDateTimeInterval = [latestDate floatValue];


            [[AWSQLiteHelper keywordsDatabaseQueue] inDatabase: ^(FMDatabase * database) {
                NSString * queryString = [NSString stringWithFormat:
                    @"SELECT position FROM applicationKeywordRank WHERE applicationKeywordId = %d AND positionDate < %d ORDER BY positionDate DESC LIMIT 1",
                                          [obj.applicationKeywordId intValue],
                                          (unsigned int)latestDateTimeInterval];

                FMResultSet * resultSet = [database executeQuery: queryString];
                while([resultSet next])
                {
                    change = [NSNumber numberWithInteger: [resultSet intForColumnIndex: 0] - [[firstEntry objectForKey: yCord] integerValue]];
                }
            }];
         }

        LatestKeywordRankEntry * latestRankEntry = [[LatestKeywordRankEntry alloc] init];

        latestRankEntry.rank = [firstEntry objectForKey: yCord];
        latestRankEntry.change = change;
        latestRankEntry.countryCode = obj.countryCode;
        latestRankEntry.country = obj.country;
        latestRankEntry.applicationId = obj.applicationId;
        latestRankEntry.application = obj.application;
        latestRankEntry.keyword = obj.keyword;
        latestRankEntry.lastSeen = [firstEntry objectForKey: xCord];
        latestRankEntry.identifier = key;

         [_latestRanks addObject: latestRankEntry];
    }];

    NSLog(@"Data prepared. Going to initialize graph.");

    latestRanks = [_latestRanks copy];
    plotData = newChartEntries;

    NSLog(@"ApplicationRankViewController - UI reload chart and table started.");
    dispatch_async(dispatch_get_main_queue(), ^{
        rankArray = [latestRanks copy];
        [self updateSorting: sortDescriptors];
    });
} // End of reloadDataInContext: endDate;

- (void) redrawChart
{
    NSLog(@"Going to initialize new graph");

    // Remove all plots.
    while(graphHostView.hostedGraph.allPlots.count > 0)
    {
        [graphHostView.hostedGraph
         removePlot: graphHostView.hostedGraph.allPlots[0]];
    } // End of plots loop

    NSLog(@"Existing plots have been removed");
    
    // Get our first sort descriptor
    NSSortDescriptor * sortDescriptor = nil;
    if(nil == keywordTableView.sortDescriptors || 0 == keywordTableView.sortDescriptors.count)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"Rank" ascending: YES];
    } // End of unsorted
    else
    {
        sortDescriptor = keywordTableView.sortDescriptors[0];
    }

    NSArray * tempRanks =
    [latestRanks sortedArrayUsingComparator:
     ^NSComparisonResult(LatestKeywordRankEntry* obj1, LatestKeywordRankEntry * obj2)
      {
          NSComparisonResult result = NSOrderedSame;

          if([@"Rank" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.rank compare: obj2.rank];
          }
          else if([@"Change" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.change compare: obj2.change];
          }
          else if([@"Country" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.country compare: obj2.country];
          }
          else if([@"Date" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.lastSeen compare: obj2.lastSeen];
          }
          else if([@"Keyword" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.keyword compare: obj2.keyword];
          }
          else if([@"Application" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.application compare: obj2.application];
          }

          // If they are the same, then follow up by comparing by rank
          if(NSOrderedSame == result)
          {
              result = [obj1.rank compare: obj2.rank];
          }
          
          // If they are still the same, sort by country
          if(NSOrderedSame == result)
          {
              result = [obj1.country compare: obj2.country];
          }
          
          // Lastly, if they are still the same, sort by chart
          if(NSOrderedSame == result)
          {
              result = [obj1.applicationId compare: obj2.applicationId];
          }

          return result;
      }];

    // Reverse it.
    if(!sortDescriptor.ascending)
    {
        tempRanks = [tempRanks reversedArray];
    }

    NSUInteger ranksToChart = [[AWSystemSettings sharedInstance] rankGraphChartEntries];

    [tempRanks enumerateObjectsUsingBlock:
     ^(LatestKeywordRankEntry * entry, NSUInteger index, BOOL * stop)
     {
         // Limit our chart to ten entries.
         if(index <= ranksToChart)
         {
             NSString * identifier = entry.identifier;
             
             NSColor * plotColor = [AWChartColorHelper colorForIndex: index];
             
             CPTColor * color = [CPTColor colorWithCGColor: plotColor.CGColor];
             [self addPlotEntryWithIdentifier: identifier
                                        color: color];

             entry.chartColor = plotColor;
         }
         else
         {
             entry.chartColor = nil;
         }
     }];

    latestRanks = tempRanks;

    [graphHostView.hostedGraph reloadData];
    
    NSLog(@"ApplicationRankViewController - UI reload chart and table finished.");
} // End of redrawChart

#pragma mark -
#pragma mark NSTableView

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger selectedRow = keywordTableView.selectedRow;

    NSString * checkingFor = @"";

    // If we have something selected
    if(!(-1 == selectedRow || selectedRow >= rankArray.count))
    {
        LatestKeywordRankEntry * rankEntry = rankArray[selectedRow];
        checkingFor = rankEntry.identifier;
    } // End of selectedRow changed

    // Loop through our plots
    NSLog(@"There are %ld plots", graphHostView.hostedGraph.allPlots.count);

    __block CPTScatterPlot * selectedPlot = nil;

    [graphHostView.hostedGraph.allPlots enumerateObjectsUsingBlock:
     ^(CPTScatterPlot * currentPlot, NSUInteger index, BOOL * stop)
    {
        NSString * identifier = (NSString*)currentPlot.identifier;

        CPTPlotSymbol *plotSymbol            = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill                      = [CPTFill fillWithColor: currentPlot.dataLineStyle.lineColor];

        if([identifier isEqualToString: checkingFor])
        {
            selectedPlot = currentPlot;
            CPTMutableLineStyle *lineStyle   = [currentPlot.dataLineStyle mutableCopy];
            lineStyle.lineWidth              = 4.0;
            currentPlot.dataLineStyle        = lineStyle;

            plotSymbol.lineStyle                 = lineStyle;
            plotSymbol.size                  = CGSizeMake(6.0, 6.0);
            currentPlot.plotSymbol           = plotSymbol;
        }
        else
        {
            CPTMutableLineStyle *lineStyle   = [currentPlot.dataLineStyle mutableCopy];
            lineStyle.lineWidth              = 2.0;
            currentPlot.dataLineStyle        = lineStyle;

            plotSymbol.lineStyle             = lineStyle;
            plotSymbol.size                  = CGSizeMake(3.0, 3.0);
            currentPlot.plotSymbol           = plotSymbol;
        }
    }]; // End of plots loop

    // Move the plot to the front.
    if(nil != selectedPlot)
    {
        [graphHostView.hostedGraph removePlot: selectedPlot];
        [graphHostView.hostedGraph addPlot: selectedPlot];
    } // End of selectedPlot
} // End of selection changed

- (NSString *)tableView:(NSTableView *)aTableView
         toolTipForCell:(NSCell *)aCell
                   rect:(NSRectPointer)rect
            tableColumn:(NSTableColumn *)aTableColumn
                    row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
    if(row >= rankArray.count)
    {
        return nil;
    }

    NSDictionary * rankEntry = rankArray[row];
    
    if(NSOrderedSame == [aTableColumn.identifier caseInsensitiveCompare: @"Application"])
    {
        return rankEntry[@"application"];
    }
    else if(NSOrderedSame == [aTableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return rankEntry[@"country"];
    }
    else
    {
        id result = [self tableView: aTableView objectValueForTableColumn: aTableColumn row:row];
        if([result isKindOfClass: [NSString class]])
        {
            return result;
        }
        else if([result isKindOfClass: [NSNumber class]])
        {
            return [result stringValue];
        }
        else
        {
            return @"";
        }
    } // End of unhandled
}

- (void)tableView:(NSTableView *)tableView
sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [keywordLoadingProgressIndicator startAnimation: self];

    // Deselect
    [tableView deselectAll: self];

    // Update our sorting
    [self updateSorting: tableView.sortDescriptors.copy];

    // Redraw our chart
    [self redrawChart];

    // Reload our table
    [tableView reloadData];
    
    [keywordLoadingProgressIndicator stopAnimation: self];
}

- (void) updateSorting: (NSArray<NSSortDescriptor*>*) sortDescriptors
{
    if(nil == sortDescriptors || 0 == sortDescriptors.count)
    {
        return;
    } // End of unsorted
    
    // Get our first sort descriptor
    NSSortDescriptor * sortDescriptor = sortDescriptors[0];
    //    NSInteger index = sortDescriptor.key.integerValue;

    // Sort our array
    rankArray = [rankArray sortedArrayUsingComparator:
                 ^NSComparisonResult(LatestKeywordRankEntry * obj1, LatestKeywordRankEntry * obj2)
    {
       NSComparisonResult result = NSOrderedSame;

       if([@"Rank" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.rank compare: obj2.rank];
       }
       else if([@"Change" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.change compare: obj2.change];
       }
       else if([@"Country" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.country compare: obj2.country];
       }
       else if([@"Date" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.lastSeen compare: obj2.lastSeen];
       }
       else if([@"Keyword" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.keyword compare: obj2.keyword];
       }
       else if([@"Application" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.application compare: obj2.application];
       }

       // If they are the same, then follow up by comparing by rank
       if(NSOrderedSame == result)
       {
           result = [obj1.rank compare: obj2.rank];
       }

       // If they are still the same, sort by country
       if(NSOrderedSame == result)
       {
           result = [obj1.country compare: obj2.country];
       }

       // Lastly, if they are still the same, sort by chart
       if(NSOrderedSame == result)
       {
           result = [obj1.applicationId compare: obj2.applicationId];
       }

       return result;
    }];

    // Reverse it.
    if(!sortDescriptor.ascending)
    {
        rankArray = [rankArray reversedArray];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"We have %ld ranks.", rankArray.count);
    return rankArray.count;
}

- (id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
             row:(NSInteger)row
{
    if(row >= rankArray.count)
    {
        return nil;
    }

    LatestKeywordRankEntry * rankEntry = rankArray[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Application"])
    {
        NSImage * appImage = [AWApplicationImageHelper imageForApplicationId: rankEntry.applicationId];
        return appImage;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"ChartColor"])
    {
        // Return the color
        return rankEntry.chartColor;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return rankEntry.country;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Keyword"])
    {
        return rankEntry.keyword;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Position"])
    {
        return rankEntry.rank;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Change"])
    {
        return rankEntry.change;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"LastSeen"])
    {
        NSDate * lastSeen = [NSDate dateWithTimeIntervalSince1970: [rankEntry.lastSeen floatValue]];

        return [rankTableDateFormatter stringFromDate: lastSeen];
    }
    else
    {
        NSLog(@"Unknown identifier: %@", tableColumn.identifier);
    }

    return nil;
}

- (void)tableView: (NSTableView *)tableView
  willDisplayCell: (id)cell
   forTableColumn: (NSTableColumn *)tableColumn
              row: (NSInteger)row
{
    if(row >= rankArray.count)
    {
        return;
    }

    LatestKeywordRankEntry * rankEntry = rankArray[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        [(ImageAndTextCell*)cell setImage: [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [rankEntry.countryCode lowercaseString]]]];
    }
}

#pragma mark -
#pragma mark CPTBarPlotDataSource

- (NSUInteger) numberOfRecordsForPlot: (CPTPlot *)plot
{
    NSArray * entries = [plotData[plot.identifier] data];
    return entries.count;
} // End of numberOfRecordsForPlot:

-(NSNumber *)numberForPlot: (CPTPlot *)plot
                     field: (NSUInteger)fieldEnum
               recordIndex: (NSUInteger)index
{
    NSArray * entries = [plotData[plot.identifier] data];

    NSDictionary * entry = [entries objectAtIndex: index];

    // If we want the x value, just return the regular
    NSNumber * result = [entry objectForKey: [NSNumber numberWithUnsignedInteger: fieldEnum]];

    if(CPTScatterPlotFieldY == fieldEnum)
    {
        if([[AWSystemSettings sharedInstance] RankGraphInvertChart])
        {
            result = [NSNumber numberWithInteger: [self graphYMax]  - result.integerValue];
        }
    }

    return result;
}

#pragma mark -
#pragma mark AWTrackedGraphHostingViewProtocol

- (void) trackedGraphHostingView: (AWTrackedGraphHostingView*) trackedGraphHostingView
                    mouseMovedTo: (NSPoint) oldMousePoint
{
    static const int plotOffset = 5;

    NSMutableArray<KeywordTooltipEntry*> * tooltipEntires = [NSMutableArray array];

    // Enumerate our graphs. Find entries that we are close to.
    [[graph allPlots] enumerateObjectsUsingBlock:
     ^(CPTScatterPlot * scatterPlot, NSUInteger scatterPlotIndex, BOOL * stop)
     {
         // Need to get the mousePoint within the plot.
         NSPoint mousePoint = [graph convertPoint: oldMousePoint toLayer: scatterPlot];

         // Figure out which index we are closet too (if any).
         NSUInteger visiblePointIndex = [scatterPlot indexOfVisiblePointClosestToPlotAreaPoint: mousePoint];

         if(NSNotFound == visiblePointIndex)
         {
             return;
         }

         // Find the actual point location and see if we are within our allowed range.
         NSPoint plotLocation = [scatterPlot plotAreaPointOfVisiblePointAtIndex: visiblePointIndex];

         // Are we within the x range?
         if((mousePoint.x > (plotLocation.x - plotOffset) && mousePoint.x < (plotLocation.x + plotOffset)) &&
            (mousePoint.y > (plotLocation.y - plotOffset) && mousePoint.y < (plotLocation.y + plotOffset)))
         {
             NSPoint testPoint = [graph convertPoint: plotLocation fromLayer: scatterPlot];

             KeywordTooltipEntry * tooltipEntry = [[KeywordTooltipEntry alloc] init];
             tooltipEntry.identifier = (NSString*) scatterPlot.identifier;
             tooltipEntry.index = [NSNumber numberWithInteger: visiblePointIndex];
             tooltipEntry.mouseLocation = NSStringFromPoint(testPoint);
             tooltipEntry.color = [scatterPlot.dataLineStyle.lineColor nsColor];

             [tooltipEntires addObject: tooltipEntry];
         }
     }];

    // If we have entries
    if(tooltipEntires.count > 0)
    {
        KeywordTooltipEntry * firstTooltip = tooltipEntires.firstObject;

        if(nil == rankPopoverDetails ||
           !([firstTooltip.identifier isEqualToString: rankPopoverDetails[0].identifier] && [firstTooltip.index isEqualToNumber: rankPopoverDetails[0].index])
           )
        {
            rankPopoverDetails = tooltipEntires;
            [popoverTimer invalidate];
            popoverTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                            target: self
                                                          selector: @selector(displayRankPopover:)
                                                          userInfo: tooltipEntires
                                                           repeats: NO];
        }
    }
    else if(rankPopover.isShown)
    {
        [popoverTimer invalidate];
        popoverTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                        target: self
                                                      selector: @selector(killRankPopover)
                                                      userInfo: nil
                                                       repeats: NO];
    }
}

- (CGFloat)widthOfString: (NSString *)string
                withFont: (NSFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (void) displayRankPopover: (id) sender
{
    NSArray * detailsArray = (NSArray*)[sender userInfo];

    // Get our first entry.
    KeywordTooltipEntry * details = detailsArray.firstObject;

    NSPoint displayPoint = NSPointFromString(details.mouseLocation);

    // Get our plot details
    KeywordChartEntry * plotDetails = plotData[details.identifier];

    NSUInteger index =
        [details.index unsignedIntegerValue];

    NSNumber * rank  =
        [[plotDetails.data objectAtIndex: index] objectForKey: yCord];

    NSNumber * dateTimeInterval =
        [[plotDetails.data objectAtIndex: index] objectForKey: xCord];
#if todo
    // Set the popover details
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter* dateFormatter = [AWDateHelper dateTimeFormatter];
        dateFormatter.timeZone         = [NSTimeZone timeZoneWithName:@"UTC"];

        // Set our rank
        rankPositionLabel.stringValue = [NSString stringWithFormat: @"#%@", rank];
        rankAppLabel.stringValue      = plotDetails.application;

        if(rankAppLabel.stringValue.length > 40)
        {
            rankAppLabel.stringValue = [rankAppLabel.stringValue substringToIndex: 40];
        }

        CGFloat fontSize = 13;
        while(true)
        {
            NSFont * targetFont = [NSFont fontWithName: rankAppLabel.font.fontName
                                                  size: fontSize];
            
            CGFloat outWidth = [self widthOfString: rankAppLabel.stringValue
                                          withFont: targetFont];

            if(outWidth > rankAppLabel.frame.size.width)
            {
                --fontSize;
            }
            else
            {
                rankAppLabel.font = targetFont;
                break;
            }
        }

        rankChartLabel.stringValue    = NSLocalizedString(plotDetails.chart, nil);
        rankGenreLabel.stringValue    = plotDetails.genre;
        rankCountryImageView.image    = [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [plotDetails.countryCode lowercaseString]]];
        rankCountryImageView.toolTip  = plotDetails.country;

        NSDate * date = [NSDate dateWithTimeIntervalSince1970: dateTimeInterval.floatValue];
        rankTimeLabel.stringValue     = [dateFormatter stringFromDate: date];

        [rankPopover showRelativeToRect: NSMakeRect(displayPoint.x,displayPoint.y,1,1) ofView: graphHostView preferredEdge: NSMinXEdge];
    });
#endif
}

- (void) killRankPopover
{
    [rankPopover close];
    
    rankPopoverDetails = nil;
}

#pragma mark -
#pragma mark NSPopoverDelegate

- (void)popoverDidClose:(NSNotification *)notification
{
    // Update our header view
    [keywordTableView.headerView setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark DateRangeSelectorDelegate

- (void) dateRangeDidChange
{
    [self reloadRanks];
} // End of dateRangeDidChange

#pragma mark -
#pragma mark FilterTableHeaderViewDelegate
#if todo
- (void) filterTableHeaderView: (AWFilterTableHeaderView*) headerView
  clickedFilterButtonForColumn: (NSTableColumn*) column
                    filterRect: (NSRect) filterRect
{
    if(nil != countryPopover)
    {
        if([countryPopover isShown])
        {
            [countryPopover close];
            return;
        }
    }
    
    countryPopover = [[NSPopover alloc] init];
    countryPopover.delegate = self;
    [countryPopover setBehavior: NSPopoverBehaviorSemitransient];
    [countryPopover setContentViewController: nil];

    if(NSOrderedSame == [@"Country" caseInsensitiveCompare: column.identifier])
    {
        rankCountryFilterViewController.countryKey = kRankGraphCountryFilterUserDefault;
        [countryPopover setContentViewController: rankCountryFilterViewController];

        rankCountryFilterViewController.didChange = NO;
    }

    // If we have a content view controller, then display it.
    if(nil != countryPopover.contentViewController)
    {
        [countryPopover showRelativeToRect: filterRect
                                    ofView: headerView
                             preferredEdge: NSMaxYEdge];
    }
} // End of filterTableHeaderView:clickedFilterButtonForColumn;
#endif
@end

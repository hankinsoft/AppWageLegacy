//
//  ApplicationRankViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/15/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//





///// How to do tooltips: https://groups.google.com/forum/#!topic/coreplot-discuss/YZJIQ55DbHI

#import "AWApplicationRankViewController.h"

#import "AWApplication.h"
#import "AWGenre.h"
#import "AWCountry.h"

#import "AWApplicationImageHelper.h"

#import <CorePlot.h>

#import "AWTrackedGraphHostingView.h"
#import "AWCollectionOperationQueue.h"

#import "AWRankCountryFilterPopoverViewController.h"
#import "AWDateRangeSelectorViewController.h"
#import "AWGenreFilterViewController.h"
#import "AWCategoryFilterViewController.h"

#import "BackgroundView.h"

#import "AWChartColorHelper.h"

#import "InvertedNumberFormatter.h"
#import "ImageAndTextCell.h"
#import "AWRankTableCell.h"
#import "AWFilterTableHeaderView.h"
#import "AWFilterTableHeaderCell.h"

@interface RankEntry : NSObject

@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,copy) NSNumber * genreId;
@property(nonatomic,copy) NSNumber * genreChartId;
@property(nonatomic,copy) NSNumber * countryId;
@property(nonatomic,copy) NSNumber * position;
@property(nonatomic,copy) NSDate   * positionDate;
                           
@end

@implementation RankEntry

@end

@interface LatestRankEntry : NSObject

@property(nonatomic,copy) NSNumber * rank;
@property(nonatomic,copy) NSNumber * change;
@property(nonatomic,copy) NSString * countryCode;
@property(nonatomic,retain) id country;
@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,retain) id application;
@property(nonatomic,copy) NSString * genre;
@property(nonatomic,copy) NSString * chart;
@property(nonatomic,copy) NSNumber * lastSeen;
@property(nonatomic,copy) NSString * identifier;
@property(nonatomic,copy) NSColor * chartColor;

@end

@implementation LatestRankEntry

@end

@interface ChartEntry : NSObject

@property(nonatomic,weak) NSString * identifier;
@property(nonatomic,retain) id data;
@property(nonatomic,copy) id application;
@property(nonatomic,copy) id country;
@property(nonatomic,copy) id countryCode;
@property(nonatomic,copy) id genre;
@property(nonatomic,copy) id chart;
@property(nonatomic,copy) id applicationId;
@property(nonatomic,copy) id countryId;
@property(nonatomic,copy) id genreId;
@property(nonatomic,copy) id genreChartId;

@end

@implementation ChartEntry

@end

@interface TooltipEntry : NSObject

@property(nonatomic,copy) NSString * identifier;
@property(nonatomic,copy) NSNumber * index;
@property(nonatomic,copy) NSString * mouseLocation;
@property(nonatomic,copy) NSColor  * color;

@end

@implementation TooltipEntry


@end

@interface AWApplicationRankViewController ()<NSTableViewDataSource, NSTableViewDelegate, CPTScatterPlotDataSource, CPTScatterPlotDelegate, AWTrackedGraphHostingViewProtocol, NSPopoverDelegate, AWDateRangeSelectorDelegate, AWFilterTableHeaderViewDelegate>
{
    IBOutlet NSProgressIndicator          * rankLoadingProgressIndicator;

    BOOL                                  requiresReload;
    dispatch_semaphore_t                  rankLoadSemaphore;

    NSSet                                 * currentApplications;

    IBOutlet    BackgroundView            * topToolbarView;
    IBOutlet    NSTableView               * rankTableView;
    IBOutlet    NSButton                  * dateRangeButton;

    NSArray                               * rankArray;
    NSArray                               * latestRanks;

    // Graph
    IBOutlet    AWTrackedGraphHostingView * graphHostView;
    CPTGraph                              * graph;

    NSDictionary                          * plotData;

    // Popover details
    IBOutlet NSPopover                    * rankPopover;
    NSTimer                               * popoverTimer;
    NSArray<TooltipEntry*>                * rankPopoverDetails;

    IBOutlet NSTextField                  * rankPositionLabel;
    IBOutlet NSTextField                  * rankAppLabel;
    IBOutlet NSTextField                  * rankGenreLabel;
    IBOutlet NSTextField                  * rankChartLabel;
    IBOutlet NSTextField                  * rankTimeLabel;
    IBOutlet NSImageView                  * rankCountryImageView;

    // Rank Country Filter
    AWRankCountryFilterPopoverViewController  * rankCountryFilterViewController;
    NSPopover                               * countryPopover;

    // Date range filter
    AWDateRangeSelectorViewController       * dateRangeSelectorViewController;
    NSPopover                             * dateRangeSelectorPopover;

    // Genere filter
    AWGenreFilterViewController           * genreFilterViewController;
    NSSet                                 * genreFilterSet;

    // Category filter
    AWCategoryFilterViewController        * categoryFilterViewController;

    AWFilterTableHeaderCell               * countryTableHeaderCell;
    AWFilterTableHeaderCell               * genreTableHeaderCell;
    AWFilterTableHeaderCell               * categoryTableHeaderCell;
}
@end

@implementation AWApplicationRankViewController

@synthesize isFocusedTab = _isFocusedTab;

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
    self = [super initWithNibName: @"AWApplicationRankViewController" bundle: nil];
    if(self)
    {
        rankLoadSemaphore        = dispatch_semaphore_create(1);

        currentApplications = [NSSet set];
        requiresReload      = YES;
    }

    return self;
}


- (void) setIsFocusedTab: (BOOL) isFocusedTab
{
    // If we were not focused, we are now and we require a reload.
    if(!_isFocusedTab && isFocusedTab && requiresReload)
    {
        // Start reloading the applications
        [self updateFilters];
        [self reloadRanks];
        requiresReload = NO;
    } // End of we need to reload the applications.

    _isFocusedTab = isFocusedTab;
}

- (void) setSelectedApplications: (NSSet*) newApplications
{
    if(nil != newApplications)
    {
        // If our apps have changed then we will deselect the table.
        if(![currentApplications isEqualToSet: newApplications])
        {
            [rankTableView deselectAll: self];
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
    [self updateFilters];
    [self reloadRanks];
} // End of setSelectedApplications

- (void) updateFilters
{
    __block NSArray * distinctCategories = nil;
    __block NSArray * distinctGenres     = nil;

    MachTimer * filterUpdateTimer = [MachTimer startTimer];
    @autoreleasepool {
        NSDate * endDate     = nil;
        NSDate * startDate   = nil;

        // Figure out our date ranges
        [AWDateRangeSelectorViewController determineDateRangeForType: kRankGraphDateRangeType
                                                           startDate: &startDate
                                                             endDate: &endDate];

        NSMutableString * rankClauseString = [NSMutableString string];
        [rankClauseString appendFormat: @" positionDate >= %ld AND positionDate <= %ld",
         (unsigned long)startDate.timeIntervalSince1970, (unsigned long)endDate.timeIntervalSince1970];

        // If we have applications specified
        if(0 != currentApplications.count)
        {
            [rankClauseString appendFormat: @" AND applicationId IN (%@)",
             [[currentApplications allObjects] componentsJoinedByString: @", "]];
        } // End of no applications selected

        NSPredicate * filteredCountryPredicate = [NSPredicate predicateWithFormat: @"countryCode IN %@",
                                                  [[NSUserDefaults standardUserDefaults] objectForKey:
                                                   kRankGraphCountryFilterUserDefault]];

        NSLog(@"Country code predicate: %@", filteredCountryPredicate.predicateFormat);

        NSArray * countriesWeCareAbout =
            [[AWCountry allCountries] filteredArrayUsingPredicate: filteredCountryPredicate];

        [rankClauseString appendFormat: @" AND countryId IN (%@)", [[countriesWeCareAbout valueForKey: @"countryId"] componentsJoinedByString: @","]];

        NSMutableArray * genreIds = [NSMutableArray array];
        NSMutableArray * genreChartIds = [NSMutableArray array];

        [[AWSQLiteHelper rankingDatabaseQueue] inDatabase: ^(FMDatabase * database) {
            FMResultSet * results;
            
            results = [database executeQuery:
                [NSString stringWithFormat: @"SELECT DISTINCT genreId FROM rank WHERE %@",
                    rankClauseString]];

            while([results next])
            {
                [genreIds addObject: [NSNumber numberWithInt: [results intForColumnIndex: 0]]];
            } // End of rank rows loop

            results = [database executeQuery:
                [NSString stringWithFormat: @"SELECT DISTINCT genreChartId FROM rank WHERE %@",
                    rankClauseString]];

            while([results next])
            {
                [genreChartIds addObject: [results objectForColumnIndex: 0]];
            } // End of rank rows loop
        }]; // End of SqliteHelper

        NSPredicate * genreChartPredicate =
            [NSPredicate predicateWithFormat: @"chartId IN %@", genreChartIds];

        NSPredicate * genrePredicate =
            [NSPredicate predicateWithFormat: @"genreId IN %@", genreIds];

        NSArray * charts = [[AWGenre allCharts] filteredArrayUsingPredicate: genreChartPredicate];
        distinctCategories = charts.copy;

        NSArray * genres = [[AWGenre allGenres] filteredArrayUsingPredicate: genrePredicate];
        distinctGenres = genres.copy;
    } // End of autoreleasepool

    NSMutableArray * categoryEntries = [NSMutableArray array];
    [distinctCategories enumerateObjectsUsingBlock: ^(AWGenreChart * chartEntry, NSUInteger index, BOOL * stop)
     {
         __block CategoryFilterEntry * entry = nil;
         [categoryEntries enumerateObjectsUsingBlock: ^(CategoryFilterEntry * categoryEntry, NSUInteger index, BOOL * stop)
          {
              if(NSOrderedSame == [NSLocalizedString(categoryEntry.categoryName, nil) caseInsensitiveCompare: NSLocalizedString(chartEntry.name, nil)])
              {
                  entry = categoryEntry;
                  *stop = YES;
              } // End of we found it
          }];

         if(nil == entry)
         {
             entry = [[CategoryFilterEntry alloc] init];
             entry.categoryName = NSLocalizedString(chartEntry.name, nil);
             [categoryEntries addObject: entry];
         } // End of no entry

         NSMutableSet * categoryIds = [NSMutableSet setWithSet: entry.categoryIds];
         [categoryIds addObject: chartEntry.chartId];

         // Set our categoryIds
         entry.categoryIds = categoryIds.copy;
     }];

    NSSortDescriptor * categorySorter = [NSSortDescriptor sortDescriptorWithKey: @"categoryName"
                                                                      ascending: YES];
    [categoryEntries sortUsingDescriptors: @[categorySorter]];

    NSLog(@"Filter update finished. Took %f.", [filterUpdateTimer elapsedSeconds]);

    // Setup our available genres
    genreFilterViewController.availableGenres = distinctGenres;

    // Setup our available categories
    categoryFilterViewController.allCategories = categoryEntries;

    // If the genreFilterSet is not nil, then lets see if it needs to be cleared.
    if(nil != genreFilterSet)
    {
        __block BOOL allFound = YES;
        [genreFilterSet enumerateObjectsUsingBlock: ^(NSString * selectedGenre, BOOL * stop)
         {
             if(![genreFilterViewController.availableGenres containsObject: selectedGenre])
             {
                 allFound = NO;
                 *stop = YES;
             }
         }];
        
        // If we did not find them all, then clear the filter.
        if(!allFound)
        {
            // Clear the genre filter.
            genreTableHeaderCell.isFiltered = NO;
            genreFilterSet    = nil;
        }
    }

    if(nil != categoryFilterViewController.selectedCategories)
    {
        __block BOOL allFound = YES;
        [categoryFilterViewController.selectedCategories enumerateObjectsUsingBlock: ^(NSString * selectedCategory, NSUInteger index, BOOL * stop)
         {
             if(![categoryFilterViewController.allCategories containsObject: selectedCategory])
             {
                 allFound = NO;
                 *stop = YES;
             }
         }];

        // If we did not find them all, then clear the filter.
        if(!allFound)
        {
            // Clear the genre filter.
            categoryTableHeaderCell.isFiltered = NO;
            categoryFilterViewController.selectedCategories    = nil;
        }
    }

    // Update our header
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update our headerView
        [rankTableView.headerView setNeedsDisplay: YES];
    });
} // End of updateFilters

- (IBAction) onDownloadRanks: (id) sender
{
    // Queue our ranks
    [AWCollectionOperationQueue.sharedInstance queueRankCollectionWithTimeInterval: 0
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

- (void) awakeFromNib
{
    [rankTableView setAutosaveName: @"RankTableView"];
    [rankTableView setAutosaveTableColumns: YES];

    topToolbarView.image = [NSImage imageNamed: @"Toolbar-Background"];

    rankPopover.animates = NO;
    graphHostView.mouseDelegate = self;

    // Watch for rank data change.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(newRanks:)
                                                 name: [AWCollectionOperationQueue newRanksNotificationName]
                                               object: nil];

    // Watch for the popover
    [[NSNotificationCenter defaultCenter] addObserverForName: NSPopoverDidShowNotification
                                                      object: rankPopover
                                                       queue: nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [[NSApp mainWindow] makeKeyWindow]; //Reclaim key from popover
                                                      [[NSApp mainWindow] makeFirstResponder:graphHostView];
                                                  }];

    // apply our custom ImageAndTextCell for rendering the first column's cells
    NSTableColumn *tableColumn = [rankTableView tableColumnWithIdentifier: @"Country"];
    ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setEditable: NO];
    [tableColumn setDataCell: imageAndTextCell];

    // Get our rank
    NSTableColumn * changeTableColumn = [rankTableView tableColumnWithIdentifier: @"Change"];
    AWRankTableCell * changeTableCell = [[AWRankTableCell alloc] init];
    changeTableCell.editable = NO;
    [changeTableColumn setDataCell: changeTableCell];

    // If we have no sort descriptors
    if(0 == rankTableView.sortDescriptors.count)
    {
        [rankTableView setSortDescriptors: @[
                                               [NSSortDescriptor sortDescriptorWithKey: @"Rank"
                                                                             ascending: YES]
                                               ]];
    }

    // Apply the header filters
    [self applyHeaderFilters];
    [self updateFilters];
}

- (void) applyHeaderFilters
{
    // Inititialize our filter views
    rankCountryFilterViewController = [[AWRankCountryFilterPopoverViewController alloc] init];
    rankCountryFilterViewController.countryKey = kRankGraphCountryFilterUserDefault;
    [rankCountryFilterViewController loadView];

    genreFilterViewController = [[AWGenreFilterViewController alloc] init];
    categoryFilterViewController = [[AWCategoryFilterViewController alloc] init];

    AWFilterTableHeaderView * headerView = [[AWFilterTableHeaderView alloc] init];
    headerView.delegate = self;
    [rankTableView setHeaderView: headerView];

    // Country has a custom icon and image view
    NSTableColumn * countryTableColumn = [rankTableView tableColumnWithIdentifier: @"Country"];
    countryTableHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    [countryTableHeaderCell setEditable: NO];
    countryTableHeaderCell.stringValue = [countryTableColumn.headerCell stringValue];
    [countryTableColumn setHeaderCell: countryTableHeaderCell];
    // The country column saves filtering, so set it up.
    countryTableHeaderCell.isFiltered = rankCountryFilterViewController.isFiltered;

    // Custom filter for our genre column
    NSTableColumn * genreTableColumn = [rankTableView tableColumnWithIdentifier: @"Genre"];
    genreTableHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    [genreTableHeaderCell setEditable: NO];
    genreTableHeaderCell.stringValue = [genreTableColumn.headerCell stringValue];
    [genreTableColumn setHeaderCell: genreTableHeaderCell];

    // Custom filter for our genre column
    NSTableColumn * categoryTableColumn = [rankTableView tableColumnWithIdentifier: @"Chart"];
    categoryTableHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    [categoryTableHeaderCell setEditable: NO];
    categoryTableHeaderCell.stringValue = [categoryTableColumn.headerCell stringValue];
    [categoryTableColumn setHeaderCell: categoryTableHeaderCell];
}

- (void) newRanks: (NSNotification*) aNotification
{
    if(_isFocusedTab)
    {
        NSLog(@"Has new ranks and is focused. Want to reload.");
        [self reloadRanks];
        requiresReload = NO;
    }
    else
    {
        NSLog(@"Has new ranks but is not focused. Not reloading.");
        requiresReload = YES;
    }
} // End of newRanks



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
                                                    length: @([[AWSystemSettings sharedInstance] rankGraphMax])];

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
    y.majorIntervalLength           = @(50.0);
    y.minorTicksPerInterval         = 0;
    y.majorGridLineStyle            = majorGridLineStyle;
//    y.orthogonalCoordinateDecimal   = @(test1);
    
    if([AWSystemSettings sharedInstance].RankGraphInvertChart)
    {
        InvertedNumberFormatter * invertedNumberFormatter = [[InvertedNumberFormatter alloc] initWithMax: [AWSystemSettings sharedInstance].rankGraphMax + 1];

        y.labelFormatter = invertedNumberFormatter;
    }
    else
    {
        NSNumberFormatter * wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
        wholeNumberFormatter.maximumFractionDigits  = 0;

        y.labelFormatter                = wholeNumberFormatter;
    }
} // End of initializeGraph

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

    if(nil == currentApplications) return;
    NSLog(@"reloadRanks entered (before singleton)");

    if(0 != dispatch_semaphore_wait(rankLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    [rankLoadingProgressIndicator startAnimation: self];

    NSLog(@"reloadRanks entered singleton.");

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            NSDate * endDate     = nil;
            NSDate * startDate   = nil;

            // Figure out our date ranges
            [AWDateRangeSelectorViewController determineDateRangeForType: kRankGraphDateRangeType
                                                               startDate: &startDate
                                                                 endDate: &endDate];

            NSLog(@"reloadRanks - Going to reloadData.");

            // Graph has been updated. Load our data.
            [self reloadDataInContext: startDate
                              endDate: endDate];

            dispatch_sync(dispatch_get_main_queue(), ^{
                // Initialize our graph
                [self initializeGraph: startDate
                              endDate: endDate];

                [self redrawChart];

                [rankTableView reloadData];

                // Clear our lock
                dispatch_semaphore_signal(rankLoadSemaphore);
                
                [rankLoadingProgressIndicator stopAnimation: self];
            });
        } // End of autorelease pool
    }); // End of dispatch_async
} // End of reloadRanks

- (void) reloadDataInContext: (NSDate*) startDate
                     endDate: (NSDate*) endDate
{
    NSLog(@"Want to reload ranks with applications: %@", currentApplications);

    NSPredicate * filteredCountryPredicate = [NSPredicate predicateWithFormat: @"countryCode IN %@",
                                              [[NSUserDefaults standardUserDefaults] objectForKey:
                                               kRankGraphCountryFilterUserDefault]];
    
    NSLog(@"Country code predicate: %@", filteredCountryPredicate.predicateFormat);
    
    NSArray * countriesWeCareAbout = [[AWCountry allCountries] filteredArrayUsingPredicate: filteredCountryPredicate];

    NSMutableString * rankClauseString = [NSMutableString string];

    [rankClauseString appendFormat: @" positionDate >= %ld AND positionDate <= %ld",
        (unsigned long)startDate.timeIntervalSince1970,
        (unsigned long)endDate.timeIntervalSince1970];

    // If we have applications specified
    if(0 != currentApplications.count)
    {
        [rankClauseString appendFormat: @" AND applicationId IN (%@)",
            [[currentApplications allObjects] componentsJoinedByString: @", "]];
    } // End of no applications

    // Append country id
    [rankClauseString appendFormat: @" AND countryId IN (%@)", [[countriesWeCareAbout valueForKey: @"countryId"] componentsJoinedByString: @","]];

    // If we have selected versions, then we need to add them in.
    if(genreFilterViewController.isFiltered && nil != genreFilterSet)
    {
        NSArray * genreIds = [genreFilterSet.allObjects valueForKeyPath: @"@distinctUnionOfObjects.genreId"];

        [rankClauseString appendFormat: @" AND genreId IN (%@)",
         [genreIds componentsJoinedByString: @","]];
    } // End of we have selectedVersions

    if(categoryFilterViewController.isFiltered)
    {
        NSArray * genreChartIds = [categoryFilterViewController.selectedCategories valueForKeyPath: @"@distinctUnionOfObjects.categoryIds"];

        NSMutableSet * filteredIds = [NSMutableSet set];
        [genreChartIds enumerateObjectsUsingBlock: ^(NSSet * entries, NSUInteger index, BOOL * stop)
         {
             [filteredIds addObjectsFromArray: entries.allObjects];
         }];

        [rankClauseString appendFormat: @" AND genreChartId IN (%@)",
         [filteredIds.allObjects componentsJoinedByString: @","]];
    }

    __block NSMutableArray<RankEntry*> * sqliteRankArray = [NSMutableArray array];
    [[AWSQLiteHelper rankingDatabaseQueue] inDatabase: ^(FMDatabase * database) {

        NSString * queryString =  [NSString stringWithFormat:
            @"SELECT applicationId,genreId,genreChartId,countryId,position,positionDate FROM rank WHERE %@ ORDER BY positionDate DESC", rankClauseString];

        FMResultSet * rankResults = [database executeQuery: queryString];

        while([rankResults next])
        {
            NSInteger timestamp = [rankResults intForColumnIndex: 5];
            NSDate * positionDate = [NSDate dateWithTimeIntervalSince1970: timestamp];

            RankEntry * rankEntry = [[RankEntry alloc] init];

            rankEntry.applicationId = [NSNumber numberWithInt: [rankResults intForColumnIndex: 0]];
            rankEntry.genreId = [NSNumber numberWithInt: [rankResults intForColumnIndex: 1]];
            rankEntry.genreChartId = [NSNumber numberWithInt: [rankResults intForColumnIndex: 2]];
            rankEntry.countryId = [NSNumber numberWithInt: [rankResults intForColumnIndex: 3]];
            rankEntry.position = [NSNumber numberWithInt: [rankResults intForColumnIndex: 4]];
            rankEntry.positionDate = positionDate;

            [sqliteRankArray addObject: rankEntry];
        } // End of rank rows loop

        NSLog(@"There are %ld ranks.", sqliteRankArray.count);
    }];

    NSMutableDictionary<NSString*,ChartEntry*> * newChartEntries = [NSMutableDictionary dictionary];

    [sqliteRankArray enumerateObjectsUsingBlock:
     ^(RankEntry * entry, NSUInteger rankIndex, BOOL * stop)
     {
         // Temp identifier.
         NSString * tempIdentifier =
            [NSString stringWithFormat: @"%@-%@-%@",
                entry.genreChartId,
                entry.countryId,
                entry.applicationId];

         ChartEntry * identifierDetails = newChartEntries[tempIdentifier];
         NSMutableArray * currentEntries = identifierDetails.data;

         if(nil == currentEntries)
         {
             currentEntries = [NSMutableArray array];
             identifierDetails.data = currentEntries;

             NSNumber * genreId = entry.genreId;
             AWGenre * genre = [AWGenre genreByGenreId: genreId];
             if(nil == genre)
             {
                 return;
             }

             NSNumber * genreChartId = entry.genreChartId;
             AWGenreChart * genreChart =
                [AWGenre chartByChartId: genreChartId];

             if(nil == genreChart)
             {
                 return;
             }

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

             ChartEntry * chartEntry = [[ChartEntry alloc] init];

             chartEntry.identifier = tempIdentifier;
             chartEntry.data = currentEntries;
             chartEntry.application = application.name;
             chartEntry.country = country.name;
             chartEntry.countryCode = country.countryCode;
             chartEntry.genre = genre.name;
             chartEntry.chart = genreChart.name;
             chartEntry.applicationId = entry.applicationId;
             chartEntry.countryId = entry.countryId;
             chartEntry.genreId = entry.genreId;
             chartEntry.genreChartId = entry.genreChartId;

             newChartEntries[tempIdentifier] = chartEntry;
         } // End of we have no entry.

         NSTimeInterval temp = [entry.positionDate timeIntervalSince1970];

         [currentEntries addObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
           [NSDecimalNumber numberWithFloat: temp], xCord,
           entry.position, yCord,
           nil]];
     }];

    NSLog(@"Preparing data to reload rank chart.");

    __block NSMutableArray<LatestRankEntry*> * _latestRanks = [NSMutableArray array];

    [newChartEntries enumerateKeysAndObjectsUsingBlock:
     ^(NSString * key, ChartEntry * obj, BOOL * stop)
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


            [[AWSQLiteHelper rankingDatabaseQueue] inDatabase: ^(FMDatabase * database) {
                NSString * queryString = [NSString stringWithFormat:
                    @"SELECT position FROM rank WHERE applicationId = %d AND countryId = %d AND genreId = %d AND genreChartId = '%@' AND positionDate < %d ORDER BY positionDate DESC LIMIT 1",
                                          [obj.applicationId intValue],
                                          [obj.countryId intValue],
                                          [obj.genreId intValue],
                                          obj.genreChartId,
                                          (unsigned int)latestDateTimeInterval];

                FMResultSet * resultSet = [database executeQuery: queryString];
                while([resultSet next])
                {
                    change = [NSNumber numberWithInteger: [resultSet intForColumnIndex: 0] - [[firstEntry objectForKey: yCord] integerValue]];
                }
            }];
         }

        LatestRankEntry * latestRankEntry = [[LatestRankEntry alloc] init];

        latestRankEntry.rank = [firstEntry objectForKey: yCord];
        latestRankEntry.change = change;
        latestRankEntry.countryCode = obj.countryCode;
        latestRankEntry.country = obj.country;
        latestRankEntry.applicationId = obj.applicationId;
        latestRankEntry.application = obj.application;
        latestRankEntry.genre = obj.genre;
        latestRankEntry.chart = obj.chart;
        latestRankEntry.lastSeen = [firstEntry objectForKey: xCord];
        latestRankEntry.identifier = key;

         [_latestRanks addObject: latestRankEntry];
    }];

    NSLog(@"Data prepared. Going to initialize graph.");

    latestRanks = [_latestRanks copy];
    plotData = newChartEntries;

    NSLog(@"ApplicationRankViewController - UI reload chart and table started.");
    rankArray = [latestRanks copy];
    [self updateSorting];
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
    NSSortDescriptor * sortDescriptor = rankTableView.sortDescriptors[0];
    if(nil == rankTableView.sortDescriptors || 0 == rankTableView.sortDescriptors.count)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"Rank" ascending: YES];
    } // End of unsorted

    NSArray * tempRanks =
    [latestRanks sortedArrayUsingComparator:
     ^NSComparisonResult(LatestRankEntry* obj1, LatestRankEntry * obj2)
      {
          NSComparisonResult result = NSOrderedSame;

          if([@"Genre" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.genre compare: obj2.genre];
          }
          else if([@"Rank" isEqualToString: sortDescriptor.key])
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
          else if([@"Category" isEqualToString: sortDescriptor.key])
          {
              result = [obj1.chart compare: obj2.chart];
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
              result = [obj1.chart compare: obj2.chart];
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
     ^(LatestRankEntry * entry, NSUInteger index, BOOL * stop)
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

- (void)tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger selectedRow = rankTableView.selectedRow;

    NSString * checkingFor = @"";

    // If we have something selected
    if(!(-1 == selectedRow || selectedRow >= rankArray.count))
    {
        LatestRankEntry * rankEntry = rankArray[selectedRow];
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

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [rankLoadingProgressIndicator startAnimation: self];

    // Deselect
    [tableView deselectAll: self];

    // Update our sorting
    [self updateSorting];

    // Redraw our chart
    [self redrawChart];

    // Reload our table
    [tableView reloadData];
    
    [rankLoadingProgressIndicator stopAnimation: self];
}

- (void) updateSorting
{
    if(nil == rankTableView.sortDescriptors || 0 == rankTableView.sortDescriptors.count)
    {
        return;
    } // End of unsorted
    
    // Get our first sort descriptor
    NSSortDescriptor * sortDescriptor = rankTableView.sortDescriptors[0];
    //    NSInteger index = sortDescriptor.key.integerValue;

    // Sort our array
    rankArray = [rankArray sortedArrayUsingComparator:
                 ^NSComparisonResult(LatestRankEntry * obj1, LatestRankEntry * obj2)
    {
       NSComparisonResult result = NSOrderedSame;

       if([@"Genre" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.genre compare: obj2.genre];
       }
       else if([@"Rank" isEqualToString: sortDescriptor.key])
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
       else if([@"Category" isEqualToString: sortDescriptor.key])
       {
           result = [obj1.chart compare: obj2.chart];
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
           result = [obj1.chart compare: obj2.chart];
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

    LatestRankEntry * rankEntry = rankArray[row];

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
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Genre"])
    {
        return rankEntry.genre;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Chart"])
    {
        return NSLocalizedString(rankEntry.chart, nil);
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

    LatestRankEntry * rankEntry = rankArray[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        [(ImageAndTextCell*)cell setImage: [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [rankEntry.countryCode lowercaseString]]]];
    }
}

#pragma mark -
#pragma mark CPTBarPlotDataSource

- (NSUInteger)numberOfRecordsForPlot: (CPTPlot *)plot
{
    NSArray * entries = [plotData[plot.identifier] data];
    return entries.count;
}

-(NSNumber *)numberForPlot: (CPTPlot *)plot
                     field: (NSUInteger)fieldEnum
               recordIndex: (NSUInteger)index
{
    NSArray * entries = [plotData[plot.identifier] data];

    // If we want the x value, just return the regular
    NSNumber * result = [[entries objectAtIndex:index] objectForKey: [NSNumber numberWithUnsignedInteger: fieldEnum]];

    if(CPTScatterPlotFieldY == fieldEnum)
    {
        if([[AWSystemSettings sharedInstance] RankGraphInvertChart])
        {
            result = [NSNumber numberWithInteger: [[AWSystemSettings sharedInstance] rankGraphMax] - result.integerValue];
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

    NSMutableArray<TooltipEntry*> * tooltipEntires = [NSMutableArray array];

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

             TooltipEntry * tooltipEntry = [[TooltipEntry alloc] init];
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
        TooltipEntry * firstTooltip = tooltipEntires.firstObject;

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
    TooltipEntry * details = detailsArray.firstObject;

    NSPoint displayPoint = NSPointFromString(details.mouseLocation);

    // Get our plot details
    ChartEntry * plotDetails = plotData[details.identifier];

    NSUInteger index =
        [details.index unsignedIntegerValue];

    NSNumber * rank  =
        [[plotDetails.data objectAtIndex: index] objectForKey: yCord];

    NSNumber * dateTimeInterval =
        [[plotDetails.data objectAtIndex: index] objectForKey: xCord];

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
    NSPopover * targetPopover = notification.object;

    if(rankCountryFilterViewController == targetPopover.contentViewController)
    {
        countryTableHeaderCell.isFiltered = rankCountryFilterViewController.isFiltered;

        if(rankCountryFilterViewController.didChange)
        {
            // Countries have changed. Lets reload.
            [self reloadRanks];
        } // End of countryFilterDidChange
    } // End of countryPopover
    else if(genreFilterViewController == targetPopover.contentViewController)
    {
        if(![genreFilterViewController.selectedGeneres isEqualToSet: genreFilterSet])
        {
            genreFilterSet = genreFilterViewController.selectedGeneres;
            [self reloadRanks];

            genreTableHeaderCell.isFiltered = genreFilterViewController.isFiltered;
        } // End of the selectedGenres changed
    } // End of genre changed
    else if(categoryFilterViewController == targetPopover.contentViewController)
    {
        [self reloadRanks];
        categoryTableHeaderCell.isFiltered = categoryFilterViewController.isFiltered;
    } // End of category changed

    // Update our header view
    [rankTableView.headerView setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark DateRangeSelectorDelegate

- (void) dateRangeDidChange
{
    [self reloadRanks];
} // End of dateRangeDidChange

#pragma mark -
#pragma mark FilterTableHeaderViewDelegate

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
    else if(NSOrderedSame == [@"Genre" caseInsensitiveCompare: column.identifier])
    {
        genreFilterViewController.selectedGeneres = genreFilterSet;
        [countryPopover setContentViewController: genreFilterViewController];
    }
    else if(NSOrderedSame == [@"Chart" caseInsensitiveCompare: column.identifier])
    {
        [countryPopover setContentViewController: categoryFilterViewController];
    }
    else
    {
        NSLog(@"Unknow filter clicked: %@", column.identifier);
    }

    // If we have a content view controller, then display it.
    if(nil != countryPopover.contentViewController)
    {
        [countryPopover showRelativeToRect: filterRect
                                    ofView: headerView
                             preferredEdge: NSMaxYEdge];
    }
} // End of filterTableHeaderView:clickedFilterButtonForColumn;

@end

//
//  ApplicationDashboardViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationDashboardViewController.h"
#import "BackgroundView.h"

#import "AWCollectionOperationQueue.h"
#import "AWSalesChart.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWSpinningProgressOverlay.h"

#import "AWCountryChart.h"
#import "AWDateRangeSelectorViewController.h"

#import "AWDashboardSummaryTileViewController.h"
#import "AWChartPopoverDetails.h"

@interface AWApplicationDashboardViewController ()<AWSalesChartDelegate, AWCountryChartDelegate, AWDateRangeSelectorDelegate, NSSplitViewDelegate>
{
    BOOL                                requiresReload;
    NSSet                               * selectedApplicationIds;

    AWSpinningProgressOverlay           * spinningProgressOverlay;
    IBOutlet BackgroundView             * topToolbarView;
    IBOutlet BackgroundView             * totalsToolbarView;
    IBOutlet NSPopUpButton              * graphTypePopupButton;
    IBOutlet NSPopUpButton              * salesChartDisplayModePopupButton;

    IBOutlet NSButton                   * dateRangeButton;
    IBOutlet NSProgressIndicator        * salesChartProgressIndicator;

    // Our salesChart and popover details
    IBOutlet NSView                     * salesChartParentView;
    IBOutlet AWSalesChart               * salesChart;
    IBOutlet NSPopover                  * salesChartPopover;
    IBOutlet NSImageView                * salesChartPopoverImageView;
    IBOutlet NSTextField                * chartPopoverProductTextField;
    IBOutlet NSTextField                * chartPopoverAmmountTextField;
    IBOutlet NSTextField                * chartPopoverDateTextField;

    // Country Chart
    IBOutlet AWCountryChart             * countryByRevenueChart;
    IBOutlet AWCountryChart             * countryByDownloadsChart;

    // Country chart popover
    IBOutlet NSPopover                  * countryChartPopover;
    IBOutlet NSTextField                * countryNameTextField;
    IBOutlet NSTextField                * countryDetailsTextField;

    // Date range filter
    AWDateRangeSelectorViewController   * dateRangeSelectorViewController;
    NSPopover                           * dateRangeSelectorPopover;

    NSTimer                             * dateRangeUpdateChart;

    IBOutlet NSSplitView                * totalsSplitView;

    NSArray                             * dashboardSummaryTiles;
}
@end

@implementation AWApplicationDashboardViewController

@synthesize isFocusedTab = _isFocusedTab;

- (id)init
{
    self = [super initWithNibName: @"AWApplicationDashboardViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    // Set our date range
    [dateRangeButton setTitle: [AWDateRangeSelectorViewController dateRangeStringForType: kDashboardDateRangeType]];

    [dateRangeButton sizeToFit];
    [dateRangeButton setFrame: NSMakeRect(topToolbarView.frame.size.width - dateRangeButton.frame.size.width - 5,
                                          dateRangeButton.frame.origin.y,
                                          dateRangeButton.frame.size.width,
                                          dateRangeButton.frame.size.height)];

    topToolbarView.image = [NSImage imageNamed: @"Toolbar-Background"];
    totalsToolbarView.image = [NSImage imageNamed: @"Toolbar-DashboardTotals"];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(newReports:)
                                                 name: [AWCollectionOperationQueue newReportsNotificationName]
                                               object: nil];

    DashboardChartDisplay chartDisplayMode = (DashboardChartDisplay)[[[NSUserDefaults standardUserDefaults] objectForKey: @"DashboardSalesChartStyle"] integerValue];

    switch(chartDisplayMode)
    {
        case DashboardChartDisplayUpgrades:
            [graphTypePopupButton selectItemWithTitle: @"Upgrades"];
            break;
        case DashboardChartDisplayTotalRevenue:
            [graphTypePopupButton selectItemWithTitle: @"Total revenue"];
            break;
        case DashboardChartDisplayTotalSales:
            [graphTypePopupButton selectItemWithTitle: @"All sales"];
            break;
        case DashboardChartDisplayTotalFreeSales:
            [graphTypePopupButton selectItemWithTitle: @"Free sales"];
            break;
        case DashboardChartDisplayTotalInAppPurchases:
            [graphTypePopupButton selectItemWithTitle: @"In-App purchases"];
            break;
        case DashboardChartDisplayTotalPaidSales:
            [graphTypePopupButton selectItemWithTitle: @"Paid sales"];
            break;
        case DashboardChartDisplayRefunds:
            [graphTypePopupButton selectItemWithTitle: @"Refunds"];
            break;
        case DashboardChartDisplayGiftPurchases:
            [graphTypePopupButton selectItemWithTitle: @"Gift purchases"];
            break;
        case DashboardChartDisplayGiftRedemption:
            [graphTypePopupButton selectItemWithTitle: @"Gift redemptions"];
            break;
        case DashboardChartDisplayPromoCodes:
            [graphTypePopupButton selectItemWithTitle: @"Promo codes"];
            break;
        case DashboardChartDisplayMAXIMUM:
            break;
    } // End of chartDisplayMode switch

    NSAssert(0 != graphTypePopupButton.titleOfSelectedItem.length, @"Invalid selection");

    [graphTypePopupButton sizeToFit];
    [graphTypePopupButton setFrame: NSMakeRect(5,
                                               graphTypePopupButton.frame.origin.y,
                                               graphTypePopupButton.frame.size.width,
                                               graphTypePopupButton.frame.size.height)];

    // Our chart styles
    countryByRevenueChart.pieChartGroupByMode = PieChartByApplication;
    countryByDownloadsChart.pieChartGroupByMode = PieChartByCountry;

    [self spaceEvenly: totalsSplitView];

    __block NSMutableArray * _dashboardSummaryTiles = [NSMutableArray array];

    // Setup our view controllers
    [totalsSplitView.subviews enumerateObjectsUsingBlock: ^(NSView * subview, NSUInteger index, BOOL * stop)
     {
         AWDashboardSummaryTileViewController * summaryTileViewController = [[AWDashboardSummaryTileViewController alloc] init];

         summaryTileViewController.mode = index;
         [summaryTileViewController.view setFrame: NSMakeRect(0,0,subview.frame.size.width,subview.frame.size.height)];
         [subview addSubview: summaryTileViewController.view];
         
         [_dashboardSummaryTiles addObject: summaryTileViewController];
     }];

    // Get our summary tiles
    dashboardSummaryTiles = [_dashboardSummaryTiles copy];
}

- (void) initialize
{
    // End of doUpdateDateRange
    [salesChartDisplayModePopupButton selectItemAtIndex: 0];
    [salesChart setSalesChartDisplayMode: SalesChartDateDisplayDaily];
    [salesChart updateChart];
    [countryByDownloadsChart updateChart];
    [countryByRevenueChart updateChart];
    [self calculateSums: YES selectionRangeChanged: YES];
}

- (void)spaceEvenly:(NSSplitView *)splitView
{
    // get the subviews of the split view
    NSArray *subviews = [splitView subviews];
    NSUInteger n = [subviews count];

    // compute the new width of each subview
    float divider = [splitView dividerThickness];
    float width = ([splitView bounds].size.width - (n - 1) *
                    divider) / n;
    
    // adjust the frames of all subviews
    float x = 0;
    NSView *subview;
    NSEnumerator *e = [subviews objectEnumerator];
    while ((subview = [e nextObject]) != nil)
    {
        NSRect frame = [subview frame];
        frame.origin.x = rintf(x);
        frame.size.width = rintf(width) - frame.origin.y;
        [subview setFrame:frame];
        x += width + divider;
    }
    
    // have the AppKit redraw the dividers
    [splitView adjustSubviews];
}

- (void) setSelectedApplications: (NSSet*) _selectedApplicationIds
{
    if(nil == _selectedApplicationIds)
    {
        return;
    } // End of setSelectedApplicationIds

    selectedApplicationIds = _selectedApplicationIds;

    // If we are not focused, then just set a require reload.
    // We will load it once the user focuses.
    if(!_isFocusedTab)
    {
        requiresReload = YES;
        return;
    } // End of we were not focused

    // Otherwise, we are the selected tab. Need to reload.
    [self appSelectionChanged];
}

- (void) setIsFocusedTab: (BOOL) isFocusedTab
{
    // If we were not focused, we are now and we require a reload.
    if(!_isFocusedTab && isFocusedTab && requiresReload)
    {
        [self appSelectionChanged];

        requiresReload = NO;
    } // End of we need to reload the applications.
    
    _isFocusedTab = isFocusedTab;
}

- (void) appSelectionChanged
{
    NSLog(@"Started appSelectionChanged");
    // Start reloading the applications
    [salesChart setSelectedApplicationIds: selectedApplicationIds];
    [countryByRevenueChart setSelectedApplicationIds: selectedApplicationIds];
    [countryByDownloadsChart setSelectedApplicationIds: selectedApplicationIds];
    
    [dashboardSummaryTiles enumerateObjectsUsingBlock:
     ^(AWDashboardSummaryTileViewController * controller, NSUInteger index, BOOL * stop)
     {
         [controller setSelectedProductIdentifiers: selectedApplicationIds];
         [controller update: YES upgradeSelectionRange: YES];
     }];
    NSLog(@"Finished appSelectionChanged");
}

- (void) newReports: (NSNotification*) aNotification
{
    NSLog(@"Dashboard has new reports");

    [salesChart updateChart];
    [countryByRevenueChart updateChart];
    [countryByDownloadsChart updateChart];

    [self calculateSums: YES
  selectionRangeChanged: YES];
}

- (void) calculateSums: (BOOL) reportsChanged selectionRangeChanged: (BOOL) selectionRangeChanged
{
    [dashboardSummaryTiles enumerateObjectsUsingBlock:
     ^(AWDashboardSummaryTileViewController * controller, NSUInteger index, BOOL * stop)
     {
         [controller update: reportsChanged upgradeSelectionRange: selectionRangeChanged];
     }];
}

#pragma mark -
#pragma Actions

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
    dateRangeSelectorViewController.dateRangeUserDefault = kDashboardDateRangeType;

    dateRangeSelectorPopover = [[NSPopover alloc] init];
    [dateRangeSelectorPopover setBehavior: NSPopoverBehaviorSemitransient];
    [dateRangeSelectorPopover setContentViewController: dateRangeSelectorViewController];
    [dateRangeSelectorPopover showRelativeToRect: [sender bounds]
                                          ofView: sender
                                   preferredEdge: NSMaxYEdge];
    
} // End of onDateRange

- (IBAction) onDownloadReports: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] queueReportCollectionWithTimeInterval: 0];
} // End of onDownloadReports

- (IBAction) onGraphType: (id) sender
{
    NSLog(@"Graph type changed: %@.",
          graphTypePopupButton.selectedItem.title);

    DashboardChartDisplay chartDisplayMode = DashboardChartDisplayTotalSales;
    if(NSOrderedSame == [@"All sales" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayTotalSales;
    }
    else if(NSOrderedSame == [@"Paid sales" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayTotalPaidSales;
    }
    else if(NSOrderedSame == [@"Free sales" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayTotalFreeSales;
    }
    else if(NSOrderedSame == [@"In-App purchases" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayTotalInAppPurchases;
    }
    else if(NSOrderedSame == [@"Upgrades" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayUpgrades;
    }
    else if(NSOrderedSame == [@"Total Revenue" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayTotalRevenue;
    }
    else if(NSOrderedSame == [@"Refunds" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayRefunds;
    }
    else if(NSOrderedSame == [@"Gift purchases" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayGiftPurchases;
    }
    else if(NSOrderedSame == [@"Gift redemptions" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayGiftRedemption;
    }
    else if(NSOrderedSame == [@"Promo codes" caseInsensitiveCompare: graphTypePopupButton.selectedItem.title])
    {
        chartDisplayMode = DashboardChartDisplayPromoCodes;
    }
    else
    {
        NSLog(@"Failed to get entry for graph type: %@", graphTypePopupButton.selectedItem.title);
        NSAssert(NO, @"Unknown graph type: %@", graphTypePopupButton.selectedItem.title);
    }

    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt: chartDisplayMode]
                                              forKey: @"DashboardSalesChartStyle"];

    [salesChart updateChart];
    [countryByRevenueChart updateChart];
    [countryByDownloadsChart updateChart];

    // The graph type changed. We don't need to update anything.
//    [self calculateSums: NO];

    [graphTypePopupButton sizeToFit];
    [graphTypePopupButton setFrame: NSMakeRect(5,
                                               graphTypePopupButton.frame.origin.y,
                                               graphTypePopupButton.frame.size.width,
                                               graphTypePopupButton.frame.size.height)];
}

- (IBAction) onSalesChartDisplayModeChanged: (id) sender
{
    NSLog(@"Sales chart display mode changed.");
    SalesChartDateDisplayMode newSalesChartDisplayMode = (SalesChartDateDisplayMode) salesChartDisplayModePopupButton.indexOfSelectedItem;

    [salesChart setSalesChartDisplayMode: newSalesChartDisplayMode];
    [salesChart updateChart];
} // End of onSalesChartDisplayModeChanged

#pragma mark -
#pragma mark AWSalesChartDelegate

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (void) salesChart: (AWSalesChart*) aSalesChart
shouldDisplayPopoverWithDetails: (AWChartPopoverDetails*) chartPopoverDetails
{
    NSPoint displayPoint = NSPointFromString(chartPopoverDetails.mouseLocation);

    // Set the popover details
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber * applicationId = chartPopoverDetails.identifier;
        AWProduct * product = [AWProduct productByAppleIdentifier:applicationId];

        // Load our image
        salesChartPopoverImageView.image =
            [AWApplicationImageHelper imageForApplicationId: product.applicationId];

        chartPopoverProductTextField.stringValue = nil == product ? chartPopoverDetails.identifier : product.title;

        chartPopoverDateTextField.stringValue    = chartPopoverDetails.date;
        chartPopoverAmmountTextField.stringValue = chartPopoverDetails.ammount;

        CGFloat fontSize = 13;
        while(true)
        {
            NSFont * targetFont = [NSFont fontWithName: chartPopoverProductTextField.font.fontName
                                                  size: fontSize];

            CGFloat outWidth = [self widthOfString: chartPopoverProductTextField.stringValue
                                          withFont: targetFont];

            if(outWidth > chartPopoverProductTextField.frame.size.width && fontSize > 10)
            {
                --fontSize;
            }
            else
            {
                chartPopoverProductTextField.font = targetFont;
                break;
            }
        }

        [countryChartPopover close];
        [salesChartPopover showRelativeToRect: NSMakeRect(displayPoint.x,displayPoint.y,1,1)
                                  ofView: aSalesChart
                           preferredEdge: [chartPopoverDetails.edge intValue]];
    });
}

- (void) salesChartShouldHidePopover: (AWSalesChart*) salesChart
{
    [countryChartPopover close];
    [salesChartPopover close];
}

- (void) salesChartStartedLoading: (AWSalesChart*) targetSalesChart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [salesChartProgressIndicator startAnimation: self];
    });
}

- (void) salesChartFinishedLoading: (AWSalesChart*) targetSalesChart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [salesChartProgressIndicator stopAnimation: self];
    });
}

#pragma mark -
#pragma mark AWCountryChartDelegate

- (void) countryChartStartedLoading: (AWCountryChart*) salesChart
{
    
}

- (void) countryChartFinishedLoading: (AWCountryChart*) salesChart
{
    
}

- (void) countryChart:(AWCountryChart *)countryChart
shouldDisplayPopoverWithDetails:(AWChartPopoverDetails *)chartPopoverDetails
{
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self countryChart: countryChart
    shouldDisplayPopoverWithDetails: chartPopoverDetails];
        });

        return;
    }

    NSPoint displayPoint = NSPointFromString(chartPopoverDetails.mouseLocation);

    countryNameTextField.stringValue = chartPopoverDetails.country;
    countryDetailsTextField.stringValue = chartPopoverDetails.details;

    [countryChartPopover showRelativeToRect: NSMakeRect(displayPoint.x,displayPoint.y,1,1)
                                     ofView: countryChart
                              preferredEdge: [chartPopoverDetails.edge intValue]];
}

- (void) countryChartShouldHidePopover: (AWCountryChart *)countryChart
{
    [countryChartPopover close];
    [salesChartPopover close];
}

#pragma mark -
#pragma mark DateRangeSelectorDelegate

- (void) dateRangeDidChange
{
    NSLog(@"Date range changed.");

    // Start the indicator early. UI looks like its running, but we will wait a bit to see if the date changes
    // again.
    dispatch_async(dispatch_get_main_queue(), ^{
        [salesChartProgressIndicator startAnimation: self];

        // Set our date range
        [dateRangeButton setTitle: [AWDateRangeSelectorViewController dateRangeStringForType: kDashboardDateRangeType]];
        [dateRangeButton sizeToFit];
        [dateRangeButton setFrame: NSMakeRect(topToolbarView.frame.size.width - dateRangeButton.frame.size.width - 5,
                                              dateRangeButton.frame.origin.y,
                                              dateRangeButton.frame.size.width,
                                              dateRangeButton.frame.size.height)];
    });

    [self calculateSums: NO selectionRangeChanged: YES];

    dispatch_async(dispatch_get_main_queue(), ^{
        // User may be changing the custom date range quicly. Make sure we dont load until they are done
        dateRangeUpdateChart =  [NSTimer scheduledTimerWithTimeInterval: 0.025
                                                                 target: self
                                                               selector: @selector(doUpdateDateRange)
                                                               userInfo: nil
                                                                repeats: NO];
    });
} // End of dateRangeDidChange

- (void) doUpdateDateRange
{
    // Update all of our charts.
    [salesChart updateChart];
    [countryByDownloadsChart updateChart];
    [countryByRevenueChart updateChart];

    [self calculateSums: NO
  selectionRangeChanged: YES];
} // End of doUpdateDateRange

#pragma mark -
#pragma mark NSSplitView

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    return NSZeroRect;
}

@end

//
//  SalesChart.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/30/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWTrackedGraphHostingView.h"

typedef enum {
    SalesChartDateDisplayDaily            = 0,
    SalesChartDateDisplayWeekly           = 1,
    SalesChartDateDisplayMonthly          = 2,
    SalesChartDateDisplayQuartly          = 3,
    SalesChartDateDisplayYearly           = 4,
} SalesChartDateDisplayMode;

@class AWSalesChart;
@class AWChartPopoverDetails;

@protocol AWSalesChartDelegate <NSObject>

- (void) salesChart: (AWSalesChart*) salesChart
shouldDisplayPopoverWithDetails: (AWChartPopoverDetails*) details;
- (void) salesChartShouldHidePopover: (AWSalesChart*) salesChart;

- (void) salesChartStartedLoading: (AWSalesChart*) salesChart;
- (void) salesChartFinishedLoading: (AWSalesChart*) salesChart;

@end

@interface AWSalesChart : AWTrackedGraphHostingView

- (void) setSelectedApplicationIds: (NSSet*) selectedApplicationIds;
- (void) setSalesChartDisplayMode: (SalesChartDateDisplayMode) salesChartDisplayMode;
- (void) updateChart;

@property(nonatomic,weak) IBOutlet id<AWSalesChartDelegate> delegate;

@end

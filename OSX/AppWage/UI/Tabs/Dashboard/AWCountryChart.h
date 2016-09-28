//
//  CountryChart.h
//  AppWage
//
//  Created by Kyle Hankinson on 2/5/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWTrackedGraphHostingView.h"

typedef enum {
    PieChartByCountry                       = 0,
    PieChartByApplication                   = 1,
} PieChartGroupByMode;

@class AWCountryChart;
@class AWChartPopoverDetails;

@protocol AWCountryChartDelegate <NSObject>

- (void) countryChart: (AWCountryChart*) countryChart
shouldDisplayPopoverWithDetails: (AWChartPopoverDetails*) details;

- (void) countryChartShouldHidePopover: (AWCountryChart*) countryChart;

- (void) countryChartStartedLoading: (AWCountryChart*) salesChart;
- (void) countryChartFinishedLoading: (AWCountryChart*) salesChart;

@end

@interface AWCountryChart : AWTrackedGraphHostingView

- (void) updateChart;
- (void) setSelectedApplicationIds: (NSSet*) selectedApplicationIds;

@property(nonatomic, assign) PieChartGroupByMode pieChartGroupByMode;
@property(nonatomic, weak) IBOutlet id<AWCountryChartDelegate> delegate;

@end

//
//  ApplicationDashboardViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWApplicationDashboardViewController : NSViewController

- (void) setSelectedApplications: (NSSet*) selectedApplicationIds;

- (void) initialize;
- (IBAction) onDateRange: (id)sender;
- (IBAction) onDownloadReports: (id) sender;
- (IBAction) onGraphType: (id) sender;
- (IBAction) onSalesChartDisplayModeChanged: (id) sender;

@property(nonatomic,assign) BOOL isFocusedTab;

@end

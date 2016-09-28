//
//  AppDelegate.h
//  AppWage
//
//  Created by Kyle Hankinson on 2013-10-17.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AWWindowAllowDrop.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet AWWindowAllowDrop * window;

- (IBAction) onPreferences: (id) sender;
- (IBAction) onDashboard: (id) sender;
- (IBAction) onReviews: (id) sender;
- (IBAction) onRanking: (id) sender;
- (IBAction) onToggleToolbarSelectedView: (id) sender;

- (IBAction) onLogs: (id) sender;
- (IBAction) onDatabase: (id) sender;

- (IBAction) onQueueRankings: (id) sender;
- (IBAction) onQueueReviews: (id) sender;
- (IBAction) onQueueRankingAndReviews: (id) sender;
- (IBAction) onQueueReports: (id) sender;
- (IBAction) onCancelAllCollections: (id) sender;
- (IBAction) onImportSalesReports: (id) sender;
- (IBAction) onToggleShowHiddenApplications: (id) sender;
- (IBAction) onSupportForum: (id) sender;
- (IBAction) onLinkedin: (id) sender;
- (IBAction) onHankinsoft: (id) sender;
- (IBAction) onRecalculateSales: (id) sender;

- (IBAction) onClearNonDailySales: (id) sender;
- (IBAction) onClearYearlySales: (id) sender;
- (IBAction) onClearMonthlySales: (id) sender;
- (IBAction) onClearWeeklySales: (id) sender;
- (IBAction) onClearDailySales: (id) sender;

- (IBAction) onClearRanks: (id) sender;
- (IBAction) onClearReviews: (id) sender;
- (IBAction) onClearSalesData: (id) sender;

- (IBAction) onWizard: (id) sender;

- (IBAction) onSendDailyEmail:(id)sender;

@end

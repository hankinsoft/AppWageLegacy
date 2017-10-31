//
//  AppDelegate.m
//  AppWage
//
//  Created by Kyle Hankinson on 2013-10-17.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AppDelegate.h"

#import "AWAccountHelper.h"

#import "AWAccount.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWGenre.h"
#import "AWiTunesConnectHelper.h"
#import "AWCountry.h"

#import "AWCurrencyHelper.h"

#import "AWApplicationListTreeViewController.h"
#import "AWApplicationDashboardViewController.h"
#import "AWApplicationRankViewController.h"
#import "AWApplicationReviewsViewController.h"
#import "AWMainTabViewController.h"

#import "AWIconCollectorOperation.h"

#import "AWCollectionOperationQueue.h"
#import "AWPreferencesWindowController.h"
#import "BackgroundView.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#import "AWProgressIndicatorWithLabel.h"
#import "HSProgressWindowController.h"

#import <FXKeychain/FXKeychain.h>

#import "AWEmailHelper.h"
#import "AWWebServer.h"

#import "AWReportImportHelper.h"
#import "AWWindowAllowDrop.h"

#import "AWCacheHelper.h"

#import "AWInitialSetupWizard.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate()<AWApplicationListTreeViewControllerProtocol, NSSplitViewDelegate, NSUserNotificationCenterDelegate, NSWindowDelegate, AWWindowAllowDropDelegate>
{
    DDFileLogger                                * fileLogger;

    AWPreferencesWindowController               * preferencesWindowController;

    IBOutlet NSSplitView                        * splitView;
    IBOutlet NSToolbarItem                      * customSpaceToolbarItem;
    IBOutlet NSView                             * splitViewLeft;
    IBOutlet NSView                             * splitViewRight;

    AWApplicationListTreeViewController         * applicationListViewController;
    AWMainTabViewController                     * mainTabViewController;
    AWInitialSetupWizard                        * initialSetupWizard;

    IBOutlet NSSegmentedControl                 * toolbarSelectedViewSegmentedControl;
    IBOutlet NSToolbar                          * toolbar;
    IBOutlet NSToolbarItem                      * selectedViewToolbarItem;
    IBOutlet NSMenuItem                         * showHiddenApplicationsMenuItem;
    IBOutlet NSMenuItem                         * dashboardMenuItem;
    IBOutlet NSMenuItem                         * reviewsMenuItem;
    IBOutlet NSMenuItem                         * rankingsMenuItem;

    // Progress toolbarItem
    IBOutlet NSToolbarItem                      * progressToolbarItem;
    IBOutlet NSView                             * progressToolbarItemView;
    IBOutlet AWProgressIndicatorWithLabel       * progressToolbarIndicator;

    NSTimer                                     * progressUpdateTimer;
    
    HSProgressWindowController                  * progressWindowController;
}
@end

@implementation AppDelegate
{
    BOOL finishedLaunching;
}

+ (void) initialize
{
    // Setup our user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
}

- (void) awakeFromNib
{
    NSString * frameRepresentation = [[NSUserDefaults standardUserDefaults] objectForKey: @"MainWindowFrame"];
    
    if(frameRepresentation.length > 0)
    {
        NSRect frame = NSRectFromString(frameRepresentation);
        [self.window setFrame: frame display: YES];
    }
}

- (void) initLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency                       = timeIntervalDay * 10; // 10 days logging
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];

    NSString * version =[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];

    DDLogInfo(@"Application %@ v%@ has launched.",
              [[NSBundle mainBundle] bundleIdentifier],
              version);
}

- (void) showMainApplicationWindowForCrashManager:(id)crashManager
{
    // launch the main app window
    [self.window makeFirstResponder: nil];
    [self.window makeKeyAndOrderFront: nil];
}

- (void) cleanupAccounts
{
    NSArray * allAccounts = [[AWAccountHelper sharedInstance] allAccounts].copy;

    for(AccountDetails * details in allAccounts)
    {
         if([details isKindOfClass: [NSDictionary class]])
         {
             [[AWAccountHelper sharedInstance] removeAll];
             break;
         } // End of break

         NSString * internalAccountId = details.accountInternalId;

         @autoreleasepool {
             AWAccount * account = [AWAccount accountByInternalAccountId: internalAccountId];

             // End of no account
             if(nil == account)
             {
                 [[AWAccountHelper sharedInstance] removeAccountDetails: details];
             } // End of no account
         } // End of autoreleasepool
    } // End of loop
} // End of cleanupAccounts

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults: @{ @"NSApplicationCrashOnExceptions": @YES }];

    [Fabric with:@[[Crashlytics class]]];

    [[AWSQLiteHelper rankingDatabaseQueue] inDatabase: ^(FMDatabase * database) {
        NSLog(@"Rating database initialized.");
    }];

    [self setupTitleAndToolbar];
    
    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];
    progressWindowController.labelString = @"Preparing database";
    [progressWindowController beginSheetModalForWindow: self.window
                                     completionHandler: nil];

    // If the http server is enabled, then start it up.
    if([[AWSystemSettings sharedInstance] isHttpServerEnabled])
    {
        [[AWWebServer sharedInstance] startServerOnPort: [[AWSystemSettings sharedInstance] HttpServerPort]];
    } // End of http server is enabled.

    // Toogle our state
    showHiddenApplicationsMenuItem.state = [[AWSystemSettings sharedInstance] shouldShowHiddenApplications] ? NSOnState : NSOffState;

    // Not indeterminate
    if([progressToolbarIndicator respondsToSelector: @selector(setIndeterminate:)])
    {
        [progressToolbarIndicator performSelector: @selector(setIndeterminate:)
                                       withObject: @YES];
    }

    // Initialize our logging
    [self initLogging];

    NSLog(@"Application started launching with arguments: %@",
          [[NSProcessInfo processInfo] arguments]);

    NSSize targetSize = progressToolbarItemView.bounds.size;

    [progressToolbarItem setView: progressToolbarItemView];
    [progressToolbarItem setMinSize: targetSize];
    [progressToolbarItem setMaxSize: targetSize];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Load our app data in the background. We have a progress bar open,
        // so the user cannot interact until is has been completed.
        [self initializeAppData];

        dispatch_async(dispatch_get_main_queue(), ^{
            // Handle the notification center message
            [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate: self];

            // Grab keychain access so that we can use it later.
            (void)[[FXKeychain defaultKeychain] objectForKey: @"EmailConfiguration"];

            NSLog(@"initializeApp - Entered main queue");
            
            // Load up our main tab view controller
            mainTabViewController = [[AWMainTabViewController alloc] init];
            [mainTabViewController loadView];

            // Setup out views.
            applicationListViewController = [[AWApplicationListTreeViewController alloc] init];
            [applicationListViewController loadView];
            [applicationListViewController initialize];
            applicationListViewController.delegate = self;
            [applicationListViewController.view setFrame: CGRectMake(0,0,splitViewLeft.frame.size.width, splitViewLeft.frame.size.height)];

            [splitViewLeft addSubview: applicationListViewController.view];
            
            [mainTabViewController.view setFrame: CGRectMake(0,0,splitViewRight.frame.size.width, splitViewRight.frame.size.height)];

            [splitViewRight addSubview: mainTabViewController.view];

            NSLog(@"initializeApp - dashboard");
            [self onDashboard: nil];

            // Enable collections
            [[AWCollectionOperationQueue sharedInstance] enableCollectionStartup];

            // Start collecting our data (if required)
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if(0 != [AWApplication allApplications].count &&
                   ![[AWSystemSettings sharedInstance] isDebugging] && [AWSystemSettings sharedInstance].runCollectionsAtStartup)
                {
                    // If we have accounts, then go ahead and queue them up.
                    if(0 != [[AWAccountHelper sharedInstance] accountsCount])
                    {
                        [[AWCollectionOperationQueue sharedInstance] queueReportCollectionWithTimeInterval: 2];
                    }
                    
                    if(0 != [AWSystemSettings sharedInstance].collectReviewsEveryXHours)
                    {
                        [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval:3
                                                                                         specifiedAppIds: nil];
                    }
                    
                    if(0 != [AWSystemSettings sharedInstance].collectRankingsEveryXHours)
                    {
                        [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 4
                                                                                       specifiedAppIds: nil];
                    }
                } // End of we have applications
            });

            // Update our exchange rates
            [[AWCurrencyHelper sharedInstance] updateExchangeRates];

            progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25
                                                                   target: self
                                                                 selector: @selector(updateProgress)
                                                                 userInfo: nil
                                                                  repeats: YES];

            // Allow dragging (users can drag/drop report files).
            [self.window registerForDraggedTypes: @[NSFilenamesPboardType]];

            NSLog(@"initializeApp - Finished main queue");

            // Initialize our timers.
            [self initTimers];

            [progressWindowController endSheetWithReturnCode: 0];

            // Initialize the main tab.
            [mainTabViewController initialize];
            [[AWCacheHelper sharedInstance] updateCacheVersion];
        });

        // Clear our accounts
        [self cleanupAccounts];
    });

    finishedLaunching = YES;
}

- (void)setupTitleAndToolbar
{
    [self.window setTitleVisibility: NSWindowTitleHidden];
    
    // Now that the title is hidden, we want to adjust our toolbar so that the items are properly aligned
    // This requires private API: https://stackoverflow.com/q/41372245
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    // Ensure that our segmented control is always aligned with the split view's left half.
    NSToolbarItem *firstItem = toolbar.items.firstObject;
    if ([firstItem respondsToSelector:@selector(setTrackedSplitView:)]) {
        [firstItem setValue:splitView forKey:@"trackedSplitView"];
    }
#pragma clang diagnostic pop
}

- (void) initializeAppData
{
    if([[[NSProcessInfo processInfo] arguments] containsObject: @"-clearAll"])
    {
        // CLEAR THE SALES REPORT DATA
        NSLog(@"Clearing all data");

        // Reset everything
        [[AWAccountHelper sharedInstance] removeAll];
    }

    // Initialize our data
    [self initData];

    // Requires update
    if([AWCacheHelper sharedInstance].requiresFullUpdate)
    {
        dispatch_semaphore_t updateSema = dispatch_semaphore_create(0);

        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Clearing sales cache";
        });
        
        [[AWCacheHelper sharedInstance] clearCache: ^(double progress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressWindowController setProgress: progress];
             });
         }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Updating sales cache";
        });
        
        [[AWCacheHelper sharedInstance] updateCache: NO
                                      updateBlock: ^(double progress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressWindowController setProgress: progress];
             });
         }
                                         finished: ^(void) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [progressWindowController endSheetWithReturnCode: 0];
                                                 dispatch_semaphore_signal(updateSema);
                                             });
                                         }];

        dispatch_semaphore_wait(updateSema, DISPATCH_TIME_FOREVER);
    } // End of requiresFullUpdate

    NSLog(@"Finished initData");
}

- (void) initTimers
{
    NSDate * midnight = [[NSDate date] dateByAddingTimeInterval: timeIntervalDay];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    midnight = [calendar dateFromComponents: [calendar components: preservedComponents
                                                         fromDate: midnight]];
    
    // At midnight, we need to udpate our rank chart. It could be on newday, etc.
    NSTimer * midnightTimer = [[NSTimer alloc] initWithFireDate: midnight
                                                       interval: timeIntervalDay
                                                         target: self
                                                       selector: @selector(midnightNotification)
                                                       userInfo: nil
                                                        repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer: midnightTimer
                                 forMode: NSDefaultRunLoopMode];

    // "All reports are generally available by 9 a.m. Pacific Time (PT)."
    // Re: http://www.apple.com/itunesnews/docs/AppStoreReportingInstructions.pdf
    calendar = [NSCalendar autoupdatingCurrentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

    NSDate * pacificReportDownload =
        [calendar dateFromComponents: [calendar components: preservedComponents
                                                  fromDate: midnight]];

    pacificReportDownload = [pacificReportDownload dateByAddingTimeInterval: (timeIntervalHour * 12)];
    NSLog(@"Want to download reports at: %@", pacificReportDownload);

    NSTimer * reportDownloadTimer = [[NSTimer alloc] initWithFireDate: pacificReportDownload
                                                             interval: timeIntervalDay
                                                               target: self
                                                             selector: @selector(reportDownloadNotification)
                                                             userInfo: nil
                                                              repeats: YES];
    
    [[NSRunLoop currentRunLoop] addTimer: reportDownloadTimer
                                 forMode: NSDefaultRunLoopMode];
} // End of initTimers

- (void) midnightNotification
{
    NSLog(@"I think its midnight. %@", [NSDate date]);

    // Reload the ranks. Chart needs to be updated.
    [mainTabViewController clearSelectedApplications];

    // If we are waiting for reports before sending emails, then do not send yet.
    if(![[AWSystemSettings sharedInstance] emailsWaitForReports])
    {
        // Send our daily email (if things are configured)
        [[AWEmailHelper sharedInstance] sendDailyEmailAuto];
    } // End of email waiting for reports
}

- (void) reportDownloadNotification
{
    if(![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reportDownloadNotification];
        });

        return;
    } // End of not on the main thread

    NSLog(@"I think its time to download the reports. %@", [NSDate date]);
    if(0 != [AWApplication allApplications].count &&
       0 != [[AWAccountHelper sharedInstance] accountsCount] &&
       1 == [[AWSystemSettings sharedInstance] collectReportsMode])
    {
        [[AWCollectionOperationQueue sharedInstance] queueReportCollectionWithTimeInterval: 0];
    } // End of we want to download reports
    else
    {
        NSLog(@"Not configured to download daily reports.");
    } // End of else
} // End of reportDownloadNotification

- (BOOL) applicationShouldHandleReopen: (NSApplication *) theApplication
                     hasVisibleWindows: (BOOL) flag
{
    [self.window makeKeyAndOrderFront:self];
    return NO;
}

- (void) initData
{
    NSLog(@"initData called on %@ thread.", [NSThread currentThread].isMainThread ? @"main" : @"background");

    [AWSQLiteHelper initializeSQLite];
    [AWAccount initializeAllAccounts];
    [AWApplication initializeAllApplications];
    [AWProduct initializeAllProducts];
    [AWCountry initializeCountriesFromFileSystem];
    [AWGenre initializeChartsFromFileSystem];

    NSUInteger totalCountries = [AWCountry allCountries].count;
    NSUInteger totalGenres    = [AWGenre allGenres].count;
    NSLog(@"We have %ld countries and %ld genres.",
          totalCountries,
          totalGenres
    );
} // End of initData

- (void) updateProgress
{
    AWCollectionOperationQueue * queue = [AWCollectionOperationQueue sharedInstance];
    progressToolbarIndicator.progressString = queue.currentStateString;
    progressToolbarIndicator.doubleValue = queue.currentProgress / 100.0;

    dispatch_async(dispatch_get_main_queue(), ^{
        [progressToolbarIndicator setNeedsDisplay: YES];
    });
}

- (void) applicationWillTerminate: (NSNotification *) notification
{
    NSLog(@"ApplicationWillTerminate");

    // Stop the server
    [[AWWebServer sharedInstance] stopServer];
}

#pragma mark -
#pragma mark Actions

- (IBAction) onPreferences: (id) sender
{
    // Get our conversion rate before
    NSString * currencyCode = [[AWSystemSettings sharedInstance] currencyCode];

    preferencesWindowController =
        [[AWPreferencesWindowController alloc] init];

    [preferencesWindowController beginSheetModalForWindow: self.window
                                        completionHandler: ^(NSModalResponse returnCode)
    {
        if (returnCode != NSModalResponseOK)
        {
            return;
        }

        [[AWWebServer sharedInstance] stopServer];
        if([[AWSystemSettings sharedInstance] isHttpServerEnabled])
        {
            [[AWWebServer sharedInstance] startServerOnPort: [[AWSystemSettings sharedInstance] HttpServerPort]];
        } // End of server is enabled

        // The currency code changed
        if(![currencyCode isEqualToString: [[AWSystemSettings sharedInstance] currencyCode]])
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // Update the revene cache
                [[AWCacheHelper sharedInstance] updateRevenueCacheInWindow: self.window];

                dispatch_async(dispatch_get_main_queue(), ^{
                    // Post a new reports
                    [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName] object: nil];
                });
            });
        }
    }];
}

- (IBAction) onToggleToolbarSelectedView: (id) sender
{
    NSSegmentedControl * segmentedControl = (NSSegmentedControl*) sender;

    if(0 == segmentedControl.selectedSegment)
    {
        [self onDashboard: sender];
    }
    else if(1 == segmentedControl.selectedSegment)
    {
        [self onReviews: sender];
    }
    else if(2 == segmentedControl.selectedSegment)
    {
        [self onRanking: sender];
    }
}

- (IBAction) onDashboard: (id) sender
{
    [dashboardMenuItem setState: NSOnState];
    [reviewsMenuItem setState: NSOffState];
    [rankingsMenuItem setState: NSOffState];
    [mainTabViewController selectDashboard];

    [toolbarSelectedViewSegmentedControl setSelectedSegment: 0];
}

- (IBAction) onReviews: (id) sender
{
    [dashboardMenuItem setState: NSOffState];
    [reviewsMenuItem setState: NSOnState];
    [rankingsMenuItem setState: NSOffState];
    [mainTabViewController selectReviews];

    [toolbarSelectedViewSegmentedControl setSelectedSegment: 1];
}

- (IBAction) onRanking: (id) sender
{
    [dashboardMenuItem setState: NSOffState];
    [reviewsMenuItem setState: NSOffState];
    [rankingsMenuItem setState: NSOnState];
    [mainTabViewController selectRankings];
    
    [toolbarSelectedViewSegmentedControl setSelectedSegment: 2];
}

- (IBAction) onLogs: (id) sender
{
    DDLogVerbose(@"User wants to open logs. Path is: %@", [fileLogger.logFileManager logsDirectory]);
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: [fileLogger.logFileManager logsDirectory]]];
} // End of onLogs

- (IBAction) onDatabase: (id) sender
{
    NSString * path = [AWSQLiteHelper rootDatabasePath];

    DDLogVerbose(@"User wants to open database. Path is: %@", path);
    [[NSWorkspace sharedWorkspace] openURL: [NSURL fileURLWithPath: path]];
} // End of onDatabase

- (IBAction) onQueueRankings: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 0
                                                                   specifiedAppIds: nil];
}

- (IBAction) onQueueReviews: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval: 0
                                                                     specifiedAppIds: nil];
}

- (IBAction) onQueueReports: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] queueReportCollectionWithTimeInterval: 0];
}

- (IBAction) onQueueRankingAndReviews: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 0
                                                                   specifiedAppIds: nil];

    [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval: 0
                                                                     specifiedAppIds: nil];
}

- (IBAction) onCancelAllCollections: (id) sender
{
    [[AWCollectionOperationQueue sharedInstance] cancelAllOperations: YES];
} // End of onCancelAllCollections

- (IBAction) onImportSalesReports: (id) sender
{
    NSLog(@"onImportSalesReports: %ld", [[AWAccountHelper sharedInstance] accountsCount]);

    // Start our import
    AWReportImportHelper * reviewImportHelper = [[AWReportImportHelper alloc] initWithWindow: self.window];
    [reviewImportHelper startImportViaDialog];
} // End of onImportSalesReports

- (IBAction) onExportCompressedSalesReports: (id) sender
{
    // Start our export
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    savePanel.canCreateDirectories    = NO;
    savePanel.title = @"Choose file for export export";
    savePanel.allowedFileTypes = @[@"tar.gz"];
    [savePanel setNameFieldStringValue: @"archive-AppWage_Sales_Report.tar.gz"];

    [savePanel beginSheetModalForWindow: self.window
                      completionHandler: ^(NSInteger result)
     {
         if (result != NSFileHandlingPanelOKButton)
         {
             return;
         }

         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);

         NSString *path = [paths objectAtIndex:0];
         NSString *localReportPath = [path stringByAppendingString: [NSString stringWithFormat: @"/%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]]];

         localReportPath = [[localReportPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"com.hankinsoft.osx.appwage.iTunesCollectionService"];

         NSString *cmd =
            [NSString stringWithFormat:@"tar -zcvf '%@' '%@'",
                [savePanel URL].path,
                localReportPath];

         NSString* actualScript = [NSString stringWithFormat:@"do shell script \"%@\"", cmd ];

         NSAppleScript *as   = [[NSAppleScript alloc] initWithSource: actualScript];
         NSDictionary *error = [[NSDictionary alloc] init];

         if ([as executeAndReturnError: &error])
         {
             [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: @[[savePanel URL]]];
         }
         else
         {
             NSLog(@"Failed to export reports. %@.", error);
         }
     }];
} // End of onExportCompressedSalesReports

- (IBAction) onToggleShowHiddenApplications: (id) sender
{
    // Toogle our state
    [[AWSystemSettings sharedInstance] setShouldShowHiddenApplications: showHiddenApplicationsMenuItem.state != NSOnState ? YES : NO];

    // Update the UI
    showHiddenApplicationsMenuItem.state =
        [[AWSystemSettings sharedInstance] shouldShowHiddenApplications] ? NSOnState : NSOffState;

    // We want to update the UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                            object: nil];
    });
}

- (IBAction) onSupportForum: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://github.com/hankinsoft/AppWage/issues"]];
}

- (IBAction) onLinkedin: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://www.linkedin.com/in/kylehankinson"]];
} // End of onLinkedin

- (IBAction) onHankinsoft: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"https://hankinsoft.com"]];
} // End of onHankinsoft

- (IBAction) onRecalculateSales: (id) sender
{
    progressWindowController = [[HSProgressWindowController alloc] init];
        progressWindowController.labelString = @"Clearing sales cache";
    [progressWindowController beginSheetModalForWindow: self.window
                                     completionHandler: nil];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[AWCacheHelper sharedInstance] clearCache: ^(double progress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressWindowController setProgress: progress];
             });
         }];

        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Updating sales cache";
        });

        [[AWCacheHelper sharedInstance] updateCache: NO
                                      updateBlock: ^(double progress)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressWindowController setProgress: progress];
             });
         }
         finished: ^(void) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [progressWindowController endSheetWithReturnCode: 0];

                 // Post a new reports
                 [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName] object: nil];
             });
         }];
    });
} // End of onRecalcualteSales

- (IBAction) onClearNonDailySales: (id) sender
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
        [salesDatabase executeUpdate:
         [NSString stringWithFormat: @"DELETE FROM salesReport WHERE salesReportType != %d", SalesReportDaily]];
    }];

    [self onRecalculateSales: sender];
} // End of onClearNonDailySales

- (IBAction) onClearYearlySales: (id) sender
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
        [salesDatabase executeUpdate:
         [NSString stringWithFormat: @"DELETE FROM salesReport WHERE salesReportType == %d", SalesReportYearly]];
    }];
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         // Vacuum cannot be run in transaction.
         [salesDatabase executeUpdate: @"VACUUM"];
     }];
    
    [self onRecalculateSales: sender];
}

- (IBAction) onClearMonthlySales: (id) sender
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
        [salesDatabase executeUpdate:
         [NSString stringWithFormat: @"DELETE FROM salesReport WHERE salesReportType == %d", SalesReportMonthly]];
    }];
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         // Vacuum cannot be run in transaction.
         [salesDatabase executeUpdate: @"VACUUM"];
     }];
    
    [self onRecalculateSales: sender];
}

- (IBAction) onClearWeeklySales: (id) sender
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
        [salesDatabase executeUpdate:
         [NSString stringWithFormat: @"DELETE FROM salesReport WHERE salesReportType == %d", SalesReportWeekly]];
    }];
    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         // Vacuum cannot be run in transaction.
         [salesDatabase executeUpdate: @"VACUUM"];
     }];
    
    [self onRecalculateSales: sender];
}

- (IBAction) onClearDailySales: (id) sender
{
    [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
        [salesDatabase executeUpdate:
         [NSString stringWithFormat: @"DELETE FROM salesReport WHERE salesReportType == %d", SalesReportDaily]];
    }];

    [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
     {
         // Vacuum cannot be run in transaction.
         [salesDatabase executeUpdate: @"VACUUM"];
     }];
    
    [self onRecalculateSales: sender];
}

- (IBAction) onClearRanks: (id) sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];

    [alert setMessageText:     @"Remove all Ranks?"];
    [alert setInformativeText: @"Are you sure that you would like to clear all of the Ranks? Once removed, you will be unable to recover them."];

    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(removeRanksAlertDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];

}

- (IBAction) onClearReviews: (id) sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];
    
    [alert setMessageText:     @"Remove all Reviews?"];
    [alert setInformativeText: @"Are you sure that you would like to clear all of the Reviews?"];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(removeReviewsAlertDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];
}

- (IBAction) onClearSalesData: (id) sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];
    
    [alert setMessageText:     @"Remove all Sales Data?"];
    [alert setInformativeText: @"Are you sure that you would like to remove all Sales Data?"];

    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(removeSalesDataAlertDidEnd:returnCode:contextInfo:)
                        contextInfo: NULL];
}

- (IBAction) onWizard: (id) sender
{
    initialSetupWizard = [[AWInitialSetupWizard alloc] init];
    [initialSetupWizard beginSheetModalForWindow: self.window
                               completionHandler: nil];
}

- (IBAction) onSendDailyEmail:(id)sender
{
    // Send our daily email (if things are configured)
    [[AWEmailHelper sharedInstance] sendDailyEmailAuto: YES];
} // End of onSendDailyEmail

- (void)removeRanksAlertDidEnd:(NSAlert *)alert
                    returnCode:(NSInteger)returnCode
                   contextInfo:(void *)contextInfo
{
    // Did not press ok.
    if (returnCode != NSAlertFirstButtonReturn)
    {
        return;
    } // End of did not press ok

    // Cancel any and all operations we have going
    [[AWCollectionOperationQueue sharedInstance] cancelAllOperations: YES];
    
    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressWindowController.labelString = @"Removing Ranks";
                [progressWindowController beginSheetModalForWindow: self.window
                                                 completionHandler: nil];
            });

            [[AWSQLiteHelper rankingDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
                // Delete all
                [database executeUpdate: @"DELETE FROM rank"];
            }];

            // Post a rank update
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newRanksNotificationName]
                                                                object: nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [progressWindowController endSheetWithReturnCode: 0];
            });
        } // End of autorelease pool
    });
}

- (void)removeReviewsAlertDidEnd:(NSAlert *)alert
                      returnCode:(NSInteger)returnCode
                     contextInfo:(void *)contextInfo
{
    // Did not press ok.
    if (returnCode != NSAlertFirstButtonReturn)
    {
        return;
    } // End of we pressed cancel

    // Cancel any and all operations we have going
    [[AWCollectionOperationQueue sharedInstance] cancelAllOperations: YES];

    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            dispatch_async(dispatch_get_main_queue(), ^{
                progressWindowController.labelString = @"Removing Reviews";
                [progressWindowController beginSheetModalForWindow: self.window
                                                 completionHandler: nil];
            });

            [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
                // Delete all
                [database executeUpdate: @"DELETE FROM review"];
            }];

            // Post a review update
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                                object: nil];
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                object: nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [progressWindowController endSheetWithReturnCode: 0];
            });
        } // End of autorelease pool
    });
}

- (void)removeSalesDataAlertDidEnd: (NSAlert *)alert
                        returnCode: (NSInteger)returnCode
                       contextInfo: (void *)contextInfo
{
    // Did not press ok.
    if (returnCode != NSAlertFirstButtonReturn) return;

    // Cancel any and all operations we have going
    [[AWCollectionOperationQueue sharedInstance] cancelAllOperations: YES];

    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Removing sales data";
            [progressWindowController beginSheetModalForWindow: self.window
                                             completionHandler: nil];
        });

        [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
            [salesDatabase executeUpdate: @"DELETE FROM salesReportCache"];
            [salesDatabase executeUpdate: @"DELETE FROM salesReport"];
            [salesDatabase executeUpdate: @"DELETE FROM iAdReportDaily"];
            [salesDatabase executeUpdate: @"DELETE FROM salesReportCachePerApp"];
        }];

        [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
         {
             // Vacuum cannot be run in transaction.
             [salesDatabase executeUpdate: @"VACUUM"];
         }];

        // Post a new reports
        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName] object: nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressWindowController endSheetWithReturnCode: 0];
        });
    }); // End of dispatch_async
}

#pragma mark -
#pragma mark ApplicationListTreeViewControllerProtocol

- (void) selectedApplicationsChanged: (NSSet*) newSelection
{
    NSLog(@"SelectedApplicationChanged: %@", newSelection);
    [mainTabViewController setSelectedApplications: newSelection];
} // End of selectedApplicationsChanged

#pragma mark -
#pragma mark NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if(0 == dividerIndex)
    {
        return 150;
    }
    
    return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if(0 == dividerIndex)
    {
        return 500;
    }
    
    return proposedMaximumPosition;
}

#pragma mark -
#pragma mark NSUserNotificationCenter

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    // Give a notification if they are enabled.
    return [[AWSystemSettings sharedInstance] notificationsEnabled];
}

#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowWillBeginSheet:(NSNotification *)notification;
{
    NSLog(@"Window will begin sheet");
    [[AWCollectionOperationQueue sharedInstance] disableCollectionStartup];
}

- (void)windowDidEndSheet:(NSNotification *)notification;
{
    NSLog(@"Window ended sheet.");
    [[AWCollectionOperationQueue sharedInstance] enableCollectionStartup];
}

- (void)windowDidMove:(NSNotification *)notification
{
    if(finishedLaunching)
    {
        [[NSUserDefaults standardUserDefaults] setObject: NSStringFromRect(self.window.frame)
                                                  forKey: @"MainWindowFrame"];
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    if(finishedLaunching)
    {
        [[NSUserDefaults standardUserDefaults] setObject: NSStringFromRect(self.window.frame)
                                                  forKey: @"MainWindowFrame"];
    }

    NSLog(@"Window resized");
}

-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}

-(BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    NSLog(@"PrepareForDragOperation");
//    NSPasteboard * pbrd = [sender draggingPasteboard];

    // Do something here.
    return YES;
}

#pragma mark -
#pragma mark 

- (BOOL) droppedURLS: (NSArray*) urls
{
    // If we are already running, the exit
    if([AWCollectionOperationQueue sharedInstance].isRunning)
    {
        NSAlert * alert = [NSAlert alertWithMessageText: @"Cannot import"
                                          defaultButton: @"OK"
                                        alternateButton: nil
                                            otherButton: nil
                              informativeTextWithFormat: @"You must wait for all collections to finish."];

        [alert beginSheetModalForWindow: self.window
                          modalDelegate: nil
                         didEndSelector: nil
                            contextInfo: NULL];

        return NO;
    } // End of already collecting

    // Import
    AWReportImportHelper * helper = [[AWReportImportHelper alloc] initWithWindow: self.window];
    [helper importWithUrls: [urls copy]];
    
    return YES;
}

@end

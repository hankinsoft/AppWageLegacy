//
//  SystemSettings.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/16/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRankGraphCountryFilterUserDefault      @"RankGraphCountryCodes"
#define kReviewFilterCountryUserDefault         @"ReviewFilterCountryCodes"
#define kEnableNotifications                    @"EnableNotifications"




@interface AWSystemSettings : NSObject

+ (AWSystemSettings*) sharedInstance;

- (BOOL) isDebugging;
- (BOOL) isRunningFromApplications;

- (BOOL) shouldAutoLunchAppWage;
- (void) setShouldAutoLunchAppWage: (BOOL) shouldLaunch;

- (BOOL) notificationsEnabled;

- (BOOL) isFirstLaunch;
- (void) clearIsFirstLaunch;

- (BOOL) emailsEnabled;
- (void) setEmailsEnabled: (BOOL) emailsEnabled;

- (BOOL) runCollectionsAtStartup;
- (void) setRunCollectionsAtStartup: (BOOL) shouldRunCollectionsAtStartup;

- (BOOL) emailsMarkSentReviewsAsRead;
- (void) setEmailsMarkSentReviewsAsRead: (BOOL) shouldMarkReviewsAsRead;

- (BOOL) emailsWaitForReports;
- (void) setEmailsWaitForReports: (BOOL) shouldWait;

- (BOOL) shouldShowHiddenApplications;
- (void) setShouldShowHiddenApplications: (BOOL) shouldShowHiddenApplications;

- (NSInteger) collectReviewsEveryXHours;
- (void) setCollectReviewsEveryXHours: (NSInteger) reviewCollectHours;

- (void) setCollectRankingsEveryXHours: (NSInteger) rankCollectHours;
- (NSInteger) collectRankingsEveryXHours;

- (void) setCollectReportsMode: (NSInteger) collectReportsMode;
- (NSInteger) collectReportsMode;

- (NSString*) currencyCode;
- (void) setCurrencyCode: (NSString*) currencyCode;

- (BOOL) graphAnimationsEnabled;
- (void) setAnimationsEnabled: (BOOL) animationsEnabled;

- (void) setCollectReportsRetry: (BOOL) shouldRetry;
- (BOOL) collectReportsRetry;

- (void) setRankGraphChartLineStyle: (NSInteger) chartLineStyle;
- (NSInteger) rankGraphChartLineStyle;

- (void) setRankGraphMax: (NSUInteger) max;
- (NSUInteger) rankGraphMax;

- (void) setRankGraphChartEntires: (NSUInteger) max;
- (NSUInteger) rankGraphChartEntries;

- (void) setReviewTranslations: (NSString*) language;
- (NSString*) reviewTranslations;

- (BOOL) isHttpServerEnabled;
- (void) setHttpServerEnabled: (BOOL) isEnabled;

- (NSUInteger) HttpServerPort;
- (void) setHttpServerPort: (NSUInteger) port;

- (BOOL) RankGraphInvertChart;
- (void) setRankGraphInvertChart: (BOOL) invert;

- (NSArray*) ReviewRatingFilter;
- (void) setReviewRatingFilter: (NSArray*) ReviewRatingFilter;

@end

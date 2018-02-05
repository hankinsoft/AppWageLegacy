//
//  SystemSettings.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/16/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWSystemSettings.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

@implementation AWSystemSettings

#define kNotificationsEnabled           @"EnableNotifications"
#define kCollectReviewsEveryXHours      @"CollectReviewsEveryXHours"
#define kCollectRanksEveryXHours        @"CollectRanksEveryXHours"
#define kCollectKeywordRanksEveryXHours        @"CollectKeywordRanksEveryXHours"
#define kCollectReportsMode             @"CollectReportsMode"
#define kCollectReportsRetry            @"CollectReportsRetry"
#define kRunCollectionsAtStartup        @"CollectRunCollectionsAtStartup"

#define kCurrencyCode                   @"CurrencyCode"

#define kShouldShowHiddenApplications   @"ShowHiddenApplications"

#define kGraphAnimationsEnabled         @"GraphAnimationsEnabled"

#define kRankGraphChartLineStyle        @"RankGraphChartLineStyle"

#define kSendsEmails                    @"Email-SendDailyEmail"
#define kEmailsWaitForReports           @"Email-WaitForReports"
#define kEmailMarkSentReviewsAsRead     @"Email-MarkSentReviewsAsRead"

#define kRankGraphMax                   @"RankGraphMax"
#define kRankGraphChartEntries          @"RankGraphChartEntries"
#define kRankGraphInvertChart           @"RankGraphInvertChart"

#define kReviewTranslations             @"ReviewTranslantions"



#define kHttpServerIsEnabled            @"HTTPServer-IsEnabled"
#define kHttpServerPort                 @"HTTPServer-Port"

#define kIsFirstLaunch                  @"General-IsFirstLaunch"
#define kAutoStartApp                   @"General-AutoStartApp"

#define kReviewRatingFilter             @"ReviewRatingFilter"

+(AWSystemSettings*)sharedInstance
{
    static dispatch_once_t pred;
    static AWSystemSettings *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AWSystemSettings alloc] init];
    });
    return sharedInstance;
}

- (BOOL) isDebugging
{
    return AmIBeingDebugged();
}

static bool AmIBeingDebugged(void)

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

- (BOOL) isRunningFromApplications
{
    NSString * bundlePath = [[NSBundle mainBundle] bundlePath];

    if(![bundlePath hasPrefix: @"/Applications"])
    {
        return NO;
    }

    return YES;
}

- (BOOL) shouldAutoLunchAppWage
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kAutoStartApp] boolValue];
}

- (void) setShouldAutoLunchAppWage: (BOOL) shouldLaunch
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: shouldLaunch]
                                              forKey: kAutoStartApp];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) isFirstLaunch
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kIsFirstLaunch] boolValue];
}

- (void) clearIsFirstLaunch
{
    [[NSUserDefaults standardUserDefaults] setObject: @NO
                                              forKey: kIsFirstLaunch];
} // End of clearIsFirstLaunch

- (BOOL) notificationsEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kNotificationsEnabled] boolValue];
}

- (BOOL) runCollectionsAtStartup
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kRunCollectionsAtStartup] boolValue];
}

- (void) setRunCollectionsAtStartup: (BOOL) shouldRunCollectionsAtStartup
{
    NSNumber * value = [NSNumber numberWithBool: shouldRunCollectionsAtStartup];

    [[NSUserDefaults standardUserDefaults] setObject: value
                                              forKey: kRunCollectionsAtStartup];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) emailsEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kSendsEmails] boolValue];
}

- (void) setEmailsEnabled: (BOOL) emailsEnabled
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: emailsEnabled]
                                              forKey: kSendsEmails];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) emailsMarkSentReviewsAsRead
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kEmailMarkSentReviewsAsRead] boolValue];
} // End of emailsWaitForReports

- (void) setEmailsMarkSentReviewsAsRead: (BOOL) shouldMarkReviewsAsRead
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: shouldMarkReviewsAsRead]
                                              forKey: kEmailMarkSentReviewsAsRead];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
} // End of setEmailsWaitForReports

- (BOOL) emailsWaitForReports
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kEmailsWaitForReports] boolValue];
} // End of emailsWaitForReports

- (void) setEmailsWaitForReports: (BOOL) shouldWait
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: shouldWait]
                                              forKey: kEmailsWaitForReports];

    [[NSUserDefaults standardUserDefaults] synchronize];
} // End of setEmailsWaitForReports

- (NSInteger) collectReviewsEveryXHours
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kCollectReviewsEveryXHours] integerValue];
}

- (NSInteger) collectRankingsEveryXHours
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kCollectRanksEveryXHours] integerValue];
}

- (NSInteger) collectKeywordRankingsEveryXHours
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kCollectKeywordRanksEveryXHours] integerValue];
}

- (void) setCollectReviewsEveryXHours: (NSInteger) reviewCollectHours
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: reviewCollectHours]
                                                     forKey: kCollectReviewsEveryXHours];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setCollectRankingsEveryXHours: (NSInteger) rankCollectHours
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: rankCollectHours]
                                              forKey: kCollectRanksEveryXHours];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setCollectKeywordRankingsEveryXHours: (NSInteger) rankCollectHours
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: rankCollectHours]
                                              forKey: kCollectKeywordRanksEveryXHours];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) currencyCode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: kCurrencyCode];
}

- (void) setCurrencyCode: (NSString*) currencyCode
{
    [[NSUserDefaults standardUserDefaults] setObject: currencyCode forKey: kCurrencyCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) shouldShowHiddenApplications
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kShouldShowHiddenApplications] boolValue];
}

- (void) setShouldShowHiddenApplications: (BOOL) shouldShowHiddenApplications
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: shouldShowHiddenApplications]
                                              forKey: kShouldShowHiddenApplications];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) graphAnimationsEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kGraphAnimationsEnabled] boolValue];
}

- (void) setAnimationsEnabled: (BOOL) animationsEnabled
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: animationsEnabled]
                                              forKey: kGraphAnimationsEnabled];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setCollectReportsMode: (NSInteger) collectReportsMode
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: collectReportsMode]
                                              forKey: kCollectReportsMode];

    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger) collectReportsMode
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kCollectReportsMode] integerValue];
}

- (void) setCollectReportsRetry: (BOOL) shouldRetry
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: shouldRetry]
                                              forKey: kCollectReportsRetry];
    
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) collectReportsRetry
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kCollectReportsRetry] boolValue];
}

- (void) setRankGraphChartLineStyle: (NSInteger) chartLineStyle
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInteger: chartLineStyle]
                                              forKey: kRankGraphChartLineStyle];

    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger) rankGraphChartLineStyle
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphChartLineStyle] integerValue];
}

- (void) setRankGraphMax: (NSUInteger) max
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithUnsignedInteger: max]
                                              forKey: kRankGraphMax];
    
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) rankGraphMax
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphMax] unsignedIntegerValue];
}

- (void) setRankGraphChartEntires: (NSUInteger) max
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithUnsignedInteger: max]
                                              forKey: kRankGraphChartEntries];
    
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) rankGraphChartEntries
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphChartEntries] unsignedIntegerValue];
}

- (void) setReviewTranslations: (NSString*) language
{
    [[NSUserDefaults standardUserDefaults] setObject: language
                                              forKey: kReviewTranslations];
    
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) reviewTranslations
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: kReviewTranslations];
}

- (BOOL) isHttpServerEnabled
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kHttpServerIsEnabled] boolValue];
}

- (void) setHttpServerEnabled: (BOOL) isEnabled
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: isEnabled]
                                              forKey: kHttpServerIsEnabled];

    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) HttpServerPort
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kHttpServerPort] unsignedIntegerValue];
}

- (void) setHttpServerPort: (NSUInteger) port
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithUnsignedInteger: port]
                                              forKey: kHttpServerPort];
    
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) RankGraphInvertChart
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphInvertChart] boolValue];
}

- (void) setRankGraphInvertChart: (BOOL) invert
{
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: invert]
                                              forKey: kRankGraphInvertChart];
    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSArray*) ReviewRatingFilter
{
    return [[NSUserDefaults standardUserDefaults] objectForKey: kReviewRatingFilter];
}

- (void) setReviewRatingFilter: (NSArray*) reviewRatingFilter
{
    [[NSUserDefaults standardUserDefaults] setObject: reviewRatingFilter
                                              forKey: kReviewRatingFilter];

    // Sync
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

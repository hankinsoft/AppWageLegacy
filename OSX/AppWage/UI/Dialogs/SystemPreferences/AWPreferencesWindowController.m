//
//  PreferencesWindowController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/20/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWPreferencesWindowController.h"
#import "AWAccount.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWGenre.h"

#import "AWAccountHelper.h"
#import "AWEmailHelper.h"
#import "AWCurrencyHelper.h"

#import "AWAccountsViewController.h"
#import "HSProgressWindowController.h"

#import "AWiTunesConnectHelper.h"
#import "AWApplicationFinder.h"

#import "AWApplicationListTreeViewController.h"
#import "AWCollectionOperationQueue.h"
#import "AWNetworkHelper.h"
#import "AWCacheHelper.h"
#import "AWWebServer.h"

#import "AWCountry.h"

#import <FXKeychain.h>

@interface AWPreferencesWindowController ()<NSTableViewDataSource, NSTableViewDelegate, AccountsViewControllerDelegate>
{
    HSProgressWindowController           * progressWindowController;
    AWAccountsViewController             * accountsViewController;

    // Toolbar
    IBOutlet NSToolbar                   * toolbar;
    IBOutlet NSToolbarItem               * accountsToolbarItem;
    IBOutlet NSToolbarItem               * emailToolbarItem;
    IBOutlet NSToolbarItem               * notificationToolbarItem;
    IBOutlet NSToolbarItem               * rankingToolbarItem;
    IBOutlet NSToolbarItem               * networkToolbarItem;

    IBOutlet NSTabView          * tabView;

    // Rankings
    IBOutlet NSView             * rankingsPerferencesView;
    IBOutlet NSTableView        * rankCountriesTableView;
    IBOutlet NSPopUpButton      * rankChartStyleButton;
    IBOutlet NSPopUpButton      * rankChartYAxisButton;
    IBOutlet NSTextField        * rankNumberOfChartEntriesTextField;

    // General
    IBOutlet NSView             * generalPreferencesView;
    IBOutlet NSButton           * enableNotificationsButton;
    IBOutlet NSButton           * launchApplicationOnStartupButton;
    IBOutlet NSPopUpButton      * downloadReviewsPopupButton;
    IBOutlet NSPopUpButton      * downloadRanksPopupButton;
    IBOutlet NSPopUpButton      * downloadReportsPopupButton;
    IBOutlet NSButton           * retryReportsButton;
    IBOutlet NSButton           * runCollectionsAtStartup;
    IBOutlet NSButton           * enableAnimationsButton;

    // Email outlets
    IBOutlet NSView             * emailPreferencesView;
    IBOutlet NSButton           * sendEmailButton;
    IBOutlet NSButton           * emailWaitsForReportsButton;
    IBOutlet NSButton           * emailMarkReviewsAsSentButton;
    IBOutlet NSButton           * sendTestEmailButton;
    IBOutlet NSTextField        * emailSMTPAddressTextField;
    IBOutlet NSTextField        * emailSMTPPortTextField;
    IBOutlet NSButton           * emailSMTPuseTLSButton;
    IBOutlet NSTextField        * emailUsernameTextField;
    IBOutlet NSSecureTextField  * emailPasswordTextField;
    IBOutlet NSTextField        * emailSendToTextField;

    // Buttons for cancel and accept
    IBOutlet NSButton           * cancelButton;
    IBOutlet NSButton           * acceptButton;

    // Currency
    IBOutlet NSPopUpButton      * currencyPopupButton;
    // Translation
    IBOutlet NSPopUpButton      * translationPopupButton;

    
    
    

    // Network
    IBOutlet NSView             * networkView;
    IBOutlet NSButton           * enableIOSServer;
    IBOutlet NSButton           * testPortButton;
    IBOutlet NSProgressIndicator* testingPortProgressIndicator;
    IBOutlet NSTextField        * iosServerPort;
}
@end

@implementation AWPreferencesWindowController
{
    NSArray                     * countries;
}

@synthesize addingDeveloper;

static NSDictionary * localizedEntries;

+ (void) initialize
{
    localizedEntries = @{
        @"Arabic"   : @"ar",
        @"English"  : @"en",
        @"Dutch"    : @"nl",
        @"French"   : @"fr",
        @"German"   : @"de",
        @"Italian"  : @"it",
        @"Russian"  : @"ru",
        @"Swedish"  : @"sv",
        @"Spanish"  : @"es",
    };
}

- (id) init
{
    self = [super initWithWindowNibName: @"AWPreferencesWindowController"];
    if(self)
    {
        addingDeveloper = NO;
    } // End of self
    
    return self;
} // End of init

- (void) windowDidLoad
{
    [super windowDidLoad];

    [self initializeCurrency];
    [self initializeReviewTranslate];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSTabViewItem * generalItem = [tabView tabViewItemAtIndex: 0];
    [generalItem setView: generalPreferencesView];

    accountsViewController = [[AWAccountsViewController alloc] init];
    accountsViewController.delegate = self;

    NSTabViewItem * accountsItem = [tabView tabViewItemAtIndex: 1];
    [accountsItem setView: accountsViewController.view];

    NSTabViewItem * item = [tabView tabViewItemAtIndex: 2];
    [item setView: emailPreferencesView];

    NSTabViewItem * rankItem = [tabView tabViewItemAtIndex: 3];
    [rankItem setView: rankingsPerferencesView];

    NSTabViewItem * iOSItem = [tabView tabViewItemAtIndex: 4];
    [iOSItem setView: networkView];

    // Load our countries.
    countries = [[AWCountry allCountries] copy];

    // Start with General.
    [toolbar setSelectedItemIdentifier: notificationToolbarItem.itemIdentifier];

    enableNotificationsButton.state = [[[NSUserDefaults standardUserDefaults] objectForKey: kEnableNotifications] boolValue] ? NSOnState : NSOffState;

    // Graph animations
    enableAnimationsButton.state = [[AWSystemSettings sharedInstance] graphAnimationsEnabled] ? NSOnState : NSOffState;

    // Get our email settings
    NSDictionary * emailSettings =
        [[FXKeychain defaultKeychain] objectForKey: @"EmailConfiguration"];

    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.maximumFractionDigits  = 0;

    [emailSMTPPortTextField setFormatter: formatter];

    if(nil != emailSettings)
    {
        emailUsernameTextField.stringValue    = emailSettings[@"username"];
        emailPasswordTextField.stringValue    = emailSettings[@"password"];
        emailSMTPAddressTextField.stringValue = emailSettings[@"smtp"];
        emailSMTPPortTextField.stringValue    = nil == emailSettings[@"smtpPort"] ? @"465" : [emailSettings[@"smtpPort"] stringValue];

        NSString * sendToEmail = emailSettings[@"sendTo"];
        if(0 == sendToEmail.length)
        {
            sendToEmail = emailSettings[@"username"];
        }
        emailSendToTextField.stringValue = sendToEmail;

        if([@"0" isEqualToString: emailSMTPPortTextField.stringValue])
        {
            emailSMTPPortTextField.stringValue = @"465";
        }

        if(nil == emailSettings[@"smtpTLS"])
        {
            emailSMTPuseTLSButton.state = YES;
        }
        else
        {
            emailSMTPuseTLSButton.state = YES == [emailSettings[@"smtpTLS"] boolValue] ? NSOnState : NSOffState;
        }

        sendEmailButton.state = [AWSystemSettings sharedInstance].emailsEnabled ? NSOnState : NSOffState;
    } // End of emailSettings

    // Set our email wait button
    emailWaitsForReportsButton.state   = [AWSystemSettings sharedInstance].emailsWaitForReports ? NSOnState : NSOffState;

    // Set our email marks reviews as read button
    emailMarkReviewsAsSentButton.state = [AWSystemSettings sharedInstance].emailsMarkSentReviewsAsRead ? NSOnState : NSOffState;

    // Setup our collection buttons
    switch([[AWSystemSettings sharedInstance] collectRankingsEveryXHours])
    {
        case 0: [downloadRanksPopupButton selectItemAtIndex: 0]; break;
        case 1: [downloadRanksPopupButton selectItemAtIndex: 1]; break;
        case 2: [downloadRanksPopupButton selectItemAtIndex: 2]; break;
        case 3: [downloadRanksPopupButton selectItemAtIndex: 3]; break;
        case 6: [downloadRanksPopupButton selectItemAtIndex: 4]; break;
        case 12: [downloadRanksPopupButton selectItemAtIndex: 5]; break;
    } // End of switch

    switch([[AWSystemSettings sharedInstance] collectReviewsEveryXHours])
    {
        case 0: [downloadReviewsPopupButton selectItemAtIndex: 0]; break;
        case 1: [downloadReviewsPopupButton selectItemAtIndex: 1]; break;
        case 2: [downloadReviewsPopupButton selectItemAtIndex: 2]; break;
        case 3: [downloadReviewsPopupButton selectItemAtIndex: 3]; break;
        case 6: [downloadReviewsPopupButton selectItemAtIndex: 4]; break;
        case 12: [downloadReviewsPopupButton selectItemAtIndex: 5]; break;
    } // End of switch

    // Set our run collections at startup option
    [runCollectionsAtStartup setState: [AWSystemSettings sharedInstance].runCollectionsAtStartup ? NSOnState : NSOffState];

    switch([[AWSystemSettings sharedInstance] collectReportsMode])
    {
        case 0: [downloadReportsPopupButton selectItemAtIndex: 0];
            [retryReportsButton setEnabled: NO];
            [retryReportsButton setState: NSOffState];
            break;
        case 1: [downloadReportsPopupButton selectItemAtIndex: 1];
            [retryReportsButton setEnabled: YES];
            [retryReportsButton setState: [[AWSystemSettings sharedInstance] collectReportsRetry] ? NSOnState : NSOffState];
            break;
    }

    // Set our autolaunch option
    if(![AWSystemSettings sharedInstance].isRunningFromApplications)
    {
        [launchApplicationOnStartupButton setEnabled: NO];
        [launchApplicationOnStartupButton setTitle: @"App must be in the Applications folder for auto-launch to be enabled."];
    } // End of autolaunch

    launchApplicationOnStartupButton.state = [[AWSystemSettings sharedInstance] shouldAutoLunchAppWage];

    // Switch based on the rank graph line style
    switch([[AWSystemSettings sharedInstance] rankGraphChartLineStyle])
    {
        case 0:
            [rankChartStyleButton selectItemAtIndex: 0];
            break;
        case 1:
            [rankChartStyleButton selectItemAtIndex: 1];
            break;
    } // End of rank graph line style
    
    if([[AWSystemSettings sharedInstance] RankGraphInvertChart])
    {
        [rankChartYAxisButton selectItemAtIndex: 1];
    }
    else
    {
        [rankChartYAxisButton selectItemAtIndex: 0];
    }

    // Set our rank chart number of entries.
    [rankNumberOfChartEntriesTextField setStringValue: [NSString stringWithFormat: @"%ld", [[AWSystemSettings sharedInstance] rankGraphChartEntries]]];

    // Initialize the network tab.
    [self initializeNetwork];

    // If we are adding a developer, then we will switch to that context.
    if(addingDeveloper)
    {
        // Default to accounts
        [self onAccounts: nil];
        [accountsViewController addAccount];
    } // End of addingDevleoper
}

- (void) initializeNetwork
{
    if([[AWSystemSettings sharedInstance] isHttpServerEnabled])
    {
        enableIOSServer.state = NSOnState;
    }
    else
    {
        enableIOSServer.state = NSOffState;
    }

    [iosServerPort setStringValue: [NSString stringWithFormat: @"%ld", [[AWSystemSettings sharedInstance] HttpServerPort]]];
}

- (void) initializeCurrency
{
    // Clear our currency list
    while(currencyPopupButton.itemTitles.count)
    {
        [currencyPopupButton removeItemAtIndex: 0];
    }

    __block NSString * selectedCurrencyTitle = @"";
    NSString * selectedCurrencyCode  = [[AWSystemSettings sharedInstance] currencyCode];

    [[[AWCurrencyHelper sharedInstance] allCurrencies] enumerateObjectsUsingBlock:^(NSDictionary * currencyDetails, NSUInteger currencyIndex, BOOL * stop)
     {
         [currencyPopupButton addItemWithTitle: currencyDetails[kCurrencyName]];
         if(NSOrderedSame == [selectedCurrencyCode caseInsensitiveCompare: currencyDetails[kCurrencyCode]])
         {
             selectedCurrencyTitle = currencyDetails[kCurrencyName];
         }
     }];

    // Select our currency
    [currencyPopupButton selectItemWithTitle: selectedCurrencyTitle];
} // End of initializeCurrency

- (void) initializeReviewTranslate
{
    // Clear the translations list
    while(translationPopupButton.itemTitles.count)
    {
        [translationPopupButton removeItemAtIndex: 0];
    }

    __block NSString * selectedReviewTranslateTitle = @"";
    NSString * selectedReviewTranslateLocal  = [[AWSystemSettings sharedInstance] reviewTranslations];

    [localizedEntries enumerateKeysAndObjectsUsingBlock: ^(NSString * key, NSString * value, BOOL * stop)
     {
         [translationPopupButton addItemWithTitle: key];
         if(NSOrderedSame == [selectedReviewTranslateLocal caseInsensitiveCompare: value])
         {
             selectedReviewTranslateTitle = key;
         }
     }];

    // Select our local
    [translationPopupButton selectItemWithTitle: selectedReviewTranslateTitle];
} // End of initializeReviewTranslate

- (BOOL) isEmailValid
{
    return YES;
}

- (IBAction) onAccounts: (id) sender
{
    [toolbar setSelectedItemIdentifier: accountsToolbarItem.itemIdentifier];
    [tabView selectTabViewItemAtIndex: 1];
} // End of onAccounts

- (IBAction) onEmail: (id) sender
{
    [toolbar setSelectedItemIdentifier: emailToolbarItem.itemIdentifier];
    [tabView selectTabViewItemAtIndex: 2];
}

- (IBAction) onNotifications: (id) sender
{
    [toolbar setSelectedItemIdentifier: notificationToolbarItem.itemIdentifier];
    [tabView selectTabViewItemAtIndex: 0];
}

- (IBAction) onEnableAnimations: (id) sender
{
    BOOL newState = enableAnimationsButton.state == NSOnState ? YES : NO;
    [[AWSystemSettings sharedInstance] setAnimationsEnabled: newState];
}

- (IBAction) onTestPort:(id)sender
{
    [iosServerPort setEnabled: NO];
    [testPortButton setEnabled: NO];
    [testingPortProgressIndicator startAnimation: self];
    NSString * currentPortValue = iosServerPort.stringValue;
    NSInteger portToCheck = [currentPortValue integerValue];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Stop any existing servers
        [[AWWebServer sharedInstance] stopServer];

        [[AWWebServer sharedInstance] startServerOnPort: portToCheck];

        bool isPortOpen = [AWNetworkHelper checkPort: portToCheck];
        [[AWWebServer sharedInstance] stopServer];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * alertString = [NSString stringWithFormat: @"Port %ld is %@open.",
                                      portToCheck,
                                      isPortOpen ? @"" : @"not "];

            NSAlert * alert = [NSAlert alertWithMessageText: alertString
                                              defaultButton: @"OK"
                                            alternateButton: nil
                                                otherButton: nil
                                  informativeTextWithFormat: !isPortOpen ? @"Contact your network administrator to ensure that port forwarding has been properly configured." : @"You should now be able to configure devices for connection."];

            [alert beginSheetModalForWindow: self.window
                              modalDelegate: self
                             didEndSelector: nil
                                contextInfo: NULL];

            [iosServerPort setEnabled: YES];
            [testPortButton setEnabled: YES];
            [testingPortProgressIndicator stopAnimation: self];
        });
    });
}

- (IBAction) onRankings: (id) sender
{
    [toolbar setSelectedItemIdentifier: rankingToolbarItem.itemIdentifier];
    [tabView selectTabViewItemAtIndex: 3];
}

- (IBAction) onNetwork: (id) sender
{
    [toolbar setSelectedItemIdentifier: networkToolbarItem.itemIdentifier];
    [tabView selectTabViewItemAtIndex: 4];
}

- (IBAction) onCancel: (id) sender
{
    [self endSheetWithReturnCode: NSModalResponseCancel];
} // End of onCancel

- (IBAction) onAccept: (id) sender
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if([self updateDetails])
        {
            // Update the network settings
            [self updateNetworkSettings];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                    object: nil];
                
                // Post a review and rank update
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                                    object: nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName]
                                                                    object: nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newRanksNotificationName]
                                                                    object: nil];

                // Close our sheet.
                [self endSheetWithReturnCode: NSModalResponseOK];
            });
        } // End of updateDetails
    });
}

- (void) updateNetworkSettings
{
    NSUInteger port = [iosServerPort.stringValue integerValue];
    [[AWSystemSettings sharedInstance] setHttpServerEnabled: enableIOSServer.state == NSOnState ? YES : NO];

    [[AWSystemSettings sharedInstance] setHttpServerPort: port];
} // End of updateNetworkSettings

- (BOOL) updateDetails
{
    // If our accounts are not valid, then give an error
    if(![accountsViewController isValid])
    {
        [self onAccounts: nil];

        NSError * error = [NSError errorWithDomain: AWErrorDomain
                                              code: 0
                                          userInfo: @{
                                                      NSLocalizedDescriptionKey : @"Account details are incomplete."
                                                      }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                        modalDelegate: self
                                                       didEndSelector: nil
                                                          contextInfo: NULL];
        });

        return NO;
    } // End of accounts were not valid.

    // If the accounts have changed, lets save them.
    if(0 != [accountsViewController changedAccounts].count)
    {
        NSLog(@"Accounts have changed. Should save.");

        // Setup the progressWindowController
        progressWindowController = [[HSProgressWindowController alloc] init];

        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"";
            [progressWindowController beginSheetModalForWindow: self.window
                                             completionHandler: nil];
        });

        __block BOOL newAccounts = NO;

        @autoreleasepool {
            for(AccountDetails * accountDetails in [accountsViewController changedAccounts])
            {
                 // If the account is deleted, then skip for now.
                 if(accountDetails.removed)
                 {
                     continue;
                 }

                 newAccounts = YES;

                 // At this point its a new account. Add it in.
                 dispatch_async(dispatch_get_main_queue(), ^{
                     progressWindowController.labelString = [NSString stringWithFormat: @"Adding Account %@", accountDetails.vendorName];
                 });

                 // Get our account (create if need be).
                 AWAccount * account = nil;

                 if(0 != accountDetails.accountInternalId.length)
                 {
                     account = [AWAccount accountByInternalAccountId: accountDetails.accountInternalId];

                     // Update the account details
                     [[AWAccountHelper sharedInstance] updateAccount: accountDetails];
                 } // End of the account already exists.

                 if(nil == account)
                 {
                     // Create our account
                     accountDetails.accountInternalId = [[NSProcessInfo processInfo] globallyUniqueString];

                     account = [[AWAccount alloc] init];
                     account.internalAccountId = accountDetails.accountInternalId;
                     account.accountType       = @(AccountType_iTunes);

                     [AWAccount addAccount: account];

                     // Add our account details
                     [[AWAccountHelper sharedInstance] addAccountDetails: accountDetails];
                 } // End of account was null

                // Make sure the account is expanded
                [AWApplicationListTreeViewController expandAccount: accountDetails.vendorName];
            }

            // Find our removed accounts
            for(AccountDetails * accountDetails in [accountsViewController changedAccounts])
            {
                 // If the account is deleted, then skip for now.
                 if(!accountDetails.removed)
                 {
                     continue;
                 }

                 // At this point its a new account. Add it in.
                 dispatch_async(dispatch_get_main_queue(), ^{
                     progressWindowController.labelString = [NSString stringWithFormat: @"Removing Account: %@", accountDetails.vendorName];
                 });

                 [[AWSQLiteHelper salesDatabaseQueue] inTransaction: ^(FMDatabase * salesDatabase, BOOL * rollback) {
                     [salesDatabase executeUpdate: @"DELETE FROM iAdReportDaily WHERE internalAccountId = ?" withArgumentsInArray: @[accountDetails.accountInternalId]];
                     [salesDatabase executeUpdate: @"DELETE FROM salesReport WHERE internalAccountId = ?" withArgumentsInArray: @[accountDetails.accountInternalId]];
                     [salesDatabase executeUpdate: @"DELETE FROM salesReportCache"];
                     [salesDatabase executeUpdate: @"DELETE FROM salesReportCachePerApp"];
                 }];

                 [[AWSQLiteHelper appWageDatabaseQueue] inTransaction:^(FMDatabase * appwageDatabase, BOOL * stop)
                  {
                      [appwageDatabase executeUpdate: @"DELETE FROM account WHERE internalAccountId = ?"
                                withArgumentsInArray: @[accountDetails.accountInternalId]];

                      [appwageDatabase executeUpdate: @"DELETE FROM product WHERE applicationId IN (SELECT applicationId FROM application WHERE application.internalAccountId = ?)"
                                withArgumentsInArray: @[accountDetails.accountInternalId]];

                      [appwageDatabase executeUpdate: @"DELETE FROM applicationGenre WHERE applicationId IN (SELECT applicationId FROM application WHERE application.internalAccountId = ?)"
                                withArgumentsInArray: @[accountDetails.accountInternalId]];

                      [appwageDatabase executeUpdate: @"DELETE FROM application WHERE application.internalAccountId = ?"
                                withArgumentsInArray: @[accountDetails.accountInternalId]];
                  }];

                 [[AWSQLiteHelper salesDatabaseQueue] inDatabase: ^(FMDatabase * salesDatabase)
                  {
                      // Vacuum cannot be run in transaction.
                     [salesDatabase executeUpdate: @"VACUUM"];
                  }];

                 // Initialize all of our accounts
                 [AWAccount initializeAllAccounts];
                 [AWApplication initializeAllApplications];
                 [AWProduct initializeAllProducts];

                 [[AWCacheHelper sharedInstance] updateCache: NO
                                                 updateBlock: ^(double progress)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [progressWindowController setProgress: progress];
                      });
                  }
                  finished: ^(void) {
                  }];

                 // And our internal representation
                 [[AWAccountHelper sharedInstance] removeAccountDetails: accountDetails];
            }

            if(newAccounts)
            {
                [[AWCollectionOperationQueue sharedInstance] queueReportCollectionWithTimeInterval: 0];

                if(0 != [AWSystemSettings sharedInstance].collectReviewsEveryXHours)
                {
                    [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval: 5
                                                                                     specifiedAppIds: nil];
                }

                if(0 != [AWSystemSettings sharedInstance].collectRankingsEveryXHours)
                {
                    [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 10
                                                                                   specifiedAppIds: nil];
                }
            }

            // Update our list of apps (users account name may of changed)
            [[NSNotificationCenter defaultCenter] postNotificationName: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                                                object: nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [progressWindowController endSheetWithReturnCode: 0];
            });
        } // End of autoreleasepool
    } // End of accounts have changed.

    // If our email details are valid, then we will go ahead and save them.
    if([self isEmailValid])
    {
        // Get our email settings
        NSDictionary * emailSettings = @{
                                         @"username":emailUsernameTextField.stringValue,
                                         @"password":emailPasswordTextField.stringValue,
                                         @"smtp":emailSMTPAddressTextField.stringValue,
                                         @"smtpPort":[NSNumber numberWithInteger: emailSMTPPortTextField.stringValue.integerValue],
                                         @"smtpTLS":[NSNumber numberWithBool: emailSMTPuseTLSButton.state == NSOnState ? YES : NO],
                                         @"sendTo":emailSendToTextField.stringValue,
                                         };

        [[FXKeychain defaultKeychain] setObject: emailSettings
                                         forKey: @"EmailConfiguration"];
    } // End of email details are valid

    // Set our send email option
    [[AWSystemSettings sharedInstance] setEmailsEnabled: sendEmailButton.state == NSOnState ? YES : NO];

    [[AWSystemSettings sharedInstance] setEmailsWaitForReports: emailWaitsForReportsButton.state == NSOnState ? YES : NO];

    [[AWSystemSettings sharedInstance] setEmailsMarkSentReviewsAsRead:     emailMarkReviewsAsSentButton.state == NSOnState ? YES : NO];

    // Toogle notifications
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: enableNotificationsButton.state == NSOnState ? YES : NO]
                                              forKey: kEnableNotifications];


    switch(downloadRanksPopupButton.indexOfSelectedItem)
    {
        case 0: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 0]; break;
        case 1: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 1]; break;
        case 2: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 2]; break;
        case 3: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 3]; break;
        case 4: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 6]; break;
        case 5: [[AWSystemSettings sharedInstance] setCollectRankingsEveryXHours: 12]; break;
        default: NSAssert(false, @"Invalid downloadRanksPopupButton selection");
    } // End of switch

    switch(downloadReviewsPopupButton.indexOfSelectedItem)
    {
        case 0: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 0]; break;
        case 1: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 1]; break;
        case 2: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 2]; break;
        case 3: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 3]; break;
        case 4: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 6]; break;
        case 5: [[AWSystemSettings sharedInstance] setCollectReviewsEveryXHours: 12]; break;
        default: NSAssert(false, @"Invalid downloadReviewsPopupButton selection");
    } // End of switch

    // Figure our our currency.
    [[[AWCurrencyHelper sharedInstance] allCurrencies] enumerateObjectsUsingBlock:^(NSDictionary * currencyDetails, NSUInteger index, BOOL * stop)
     {
         if([currencyPopupButton.selectedItem.title isEqualToString: currencyDetails[kCurrencyName]])
         {
             [[AWSystemSettings sharedInstance] setCurrencyCode: currencyDetails[kCurrencyCode]];

             // No need to loop anymore
             *stop = YES;
         }
     }];

    // Figure our our review translation.
    [localizedEntries enumerateKeysAndObjectsUsingBlock: ^(NSString * key, NSString * value, BOOL * stop)
     {
         if(NSOrderedSame == [translationPopupButton.selectedItem.title caseInsensitiveCompare: key])
         {
             [[AWSystemSettings sharedInstance] setReviewTranslations: value];

             // No need to loop anymore
             *stop = YES;
         } // End of match
     }];

    // Set our chart style
    [[AWSystemSettings sharedInstance] setRankGraphChartLineStyle: rankChartStyleButton.indexOfSelectedItem];

    [[AWSystemSettings sharedInstance] setRankGraphInvertChart: rankChartYAxisButton.indexOfSelectedItem == 1 ? YES : NO];

    // Set our runCollectionsAtStartup option
    [[AWSystemSettings sharedInstance] setRunCollectionsAtStartup: runCollectionsAtStartup.state == NSOnState];

    // Set the max number of rank chart entries
    [[AWSystemSettings sharedInstance] setRankGraphChartEntires: [[rankNumberOfChartEntriesTextField stringValue] integerValue]];

    // Update our countries
    [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * appwageDatabase)
     {
         [countries enumerateObjectsUsingBlock: ^(AWCountry * country, NSUInteger index, BOOL * stop)
          {
              NSArray * arguments = @[
                [NSNumber numberWithBool: country.shouldCollectRanks],
                country.countryId
              ];

              [appwageDatabase executeUpdate: @"UPDATE country SET shouldCollectRanks = ? WHERE countryId = ?"
                        withArgumentsInArray: arguments];
          }]; // End of countries enumeration
     }];

    // Reload our countries
    [AWCountry initializeCountriesFromFileSystem];

    return YES;
} // End of onAccept

- (IBAction) onTestEmail: (id) sender
{
    NSNumber * smtpPort = [NSNumber numberWithInteger: emailSMTPPortTextField.stringValue.integerValue];

    NSString * emailTo = emailSendToTextField.stringValue;
    if(0 == emailTo.length)
    {
        emailTo = emailUsernameTextField.stringValue;
    } // End of no target email specified.
    
    [sendTestEmailButton setEnabled: NO];

    [[AWEmailHelper sharedInstance] sendDailyEmail: emailUsernameTextField.stringValue
                                        password: emailPasswordTextField.stringValue
                                        smtpHost: emailSMTPAddressTextField.stringValue
                                        smtpPort: smtpPort
                                             tls: emailSMTPuseTLSButton.state = NSOnState ? YES : NO
                                         emailTo: [emailTo componentsSeparatedByString: @";"]
                                      dailyEmail: NO
                                           finishedBlock: ^(NSError * error)
     {
         [sendTestEmailButton setEnabled: YES];

         // If we have an error, display it.
         if(nil != error)
         {
             [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                         modalDelegate: self
                                                        didEndSelector: nil
                                                           contextInfo: NULL];
         }
         else
         {
             [[NSAlert alertWithMessageText: @"Success"
                              defaultButton: @"OK"
                            alternateButton: nil
                                otherButton: nil
                  informativeTextWithFormat: @"SMTP details verified."] beginSheetModalForWindow: self.window
              modalDelegate: self
              didEndSelector: nil
              contextInfo: NULL];
         } // end of else
     }];
}

#pragma mark -
#pragma mark NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(tableView == rankCountriesTableView)
    {
        return countries.count;
    }

    return 0;
}

- (id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
             row:(NSInteger)row
{
    if(row >= countries.count)
    {
        return nil;
    }

    AWCountry * country = countries[row];
    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CollectRank"])
    {
        return [NSNumber numberWithBool: country.shouldCollectRanks];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CountryImage"])
    {
        return [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [country.countryCode lowercaseString]]];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return country.name;
    }

    NSLog(@"Unknown column: %@", tableColumn.identifier);
    return @"";
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row
{
    NSLog(@"Want to change column %@.", tableColumn.identifier);

    if(row >= countries.count)
    {
        return;
    }

    AWCountry * country = countries[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CollectRank"])
    {
        if([object isKindOfClass: [NSNumber class]])
        {
            country.shouldCollectRanks = [(NSNumber*)object boolValue];
        }
        else
        {
            NSLog(@"????");
        }
    } // End of CollectRank
}

#pragma mark -
#pragma mark AccountsViewControllerDelegate

- (void) beganLoadingVendorId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cancelButton setEnabled: NO];
        [acceptButton setEnabled: NO];
    });
}

- (void) accountsViewControllerHasError: (NSError*) error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSAlert alertWithError: error] beginSheetModalForWindow: self.window
                                                    modalDelegate: nil
                                                   didEndSelector: nil
                                                      contextInfo: NULL];
    });
}

- (void) endLoadingVendorId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cancelButton setEnabled: YES];
        [acceptButton setEnabled: YES];
    });
}

@end

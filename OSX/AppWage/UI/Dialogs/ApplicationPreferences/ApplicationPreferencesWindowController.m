//
//  ApplicationPreferencesWindowController.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/7/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "ApplicationPreferencesWindowController.h"
#import "AWApplication.h"

#import "AWCollectionOperationQueue.h"
#import "HSProgressWindowController.h"

@interface ApplicationPreferencesWindowController ()
{
    IBOutlet NSImageView             * applicationImageView;
    IBOutlet NSTextField             * applicationHeaderTextField;
    IBOutlet NSTextField             * applicationDetailsTextField;

    IBOutlet NSButtonCell            * downloadReviewsButtonCell;
    IBOutlet NSButtonCell            * downloadRanksButtonCell;
    
    HSProgressWindowController       * progressWindowController;
}
@end

@implementation ApplicationPreferencesWindowController

@synthesize applicationIds;

-(id) init
{
    return [super initWithWindowNibName: @"ApplicationPreferencesWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Get our applications.
    NSPredicate * applicationPredicate = [NSPredicate predicateWithFormat: @"%K IN %@",
                                          @"applicationId", applicationIds];

    NSArray * applications =
        [[AWApplication allApplications] filteredArrayUsingPredicate: applicationPredicate];

    // States for checkbox properties
    __block NSInteger rankState = -1;
    __block NSInteger reviewState = -1;

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    if(applications.count > 1)
    {
        applicationImageView.image = [NSImage imageNamed: @"AppIcon"];

        applicationHeaderTextField.stringValue = [NSString stringWithFormat: @"%ld Application%@",
                                                  applicationIds.count,
                                                  1 == applicationIds.count ? @"" : @"s"];

        applicationDetailsTextField.stringValue = [[applications valueForKey: @"name"] componentsJoinedByString: @", "];

        [applications enumerateObjectsUsingBlock:
         ^(AWApplication * application, NSUInteger applicationIndex, BOOL * stop)
         {
             // First entry
             if(0 == applicationIndex)
             {
                 rankState = application.shouldCollectRanks.boolValue ? NSOnState : NSOffState;
                 reviewState = application.shouldCollectReviews.boolValue ? NSOnState : NSOffState;

                 return;
             }

             if(rankState != application.shouldCollectRanks.boolValue ? NSOnState : NSOffState)
             {
                 rankState = NSMixedState;
             }

             if(reviewState != application.shouldCollectReviews.boolValue ? NSOnState : NSOffState)
             {
                 reviewState = NSMixedState;
             }
         }];
    } // End of we have more than one application
    else
    {
        AWApplication * targetApp = applications[0];

        applicationImageView.image =
            [AWApplicationImageHelper imageForApplicationId: targetApp.applicationId];

        // Set our title + detail
        applicationHeaderTextField.stringValue  = targetApp.name;
        applicationDetailsTextField.stringValue = targetApp.publisher;

        // Set our states
        reviewState = targetApp.shouldCollectReviews.boolValue ? NSOnState : NSOffState;
        rankState   = targetApp.shouldCollectRanks.boolValue   ? NSOnState : NSOffState;
    } // End of single application

    // ReviewState
    downloadReviewsButtonCell.allowsMixedState = reviewState == NSMixedState ? YES : NO;
    downloadReviewsButtonCell.state = reviewState;

    // RankState
    downloadRanksButtonCell.allowsMixedState = rankState == NSMixedState ? YES : NO;
    downloadRanksButtonCell.state = rankState;
}

- (IBAction) onCheckboxStateChanged: (id) sender
{
    NSButton * button = (NSButton*) sender;

    // User has made a change. No longer allow mixed states.
    button.allowsMixedState = NO;
} // End of onCheckboxStateChanged

- (IBAction) onClearData: (id) sender
{
    NSAlert *alert = [[NSAlert alloc] init];

    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText: @"Clear historical data?"];
    [alert setInformativeText: @"This will clear all information about the selected application(s). This action cannot be undone."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow: self.window
                      modalDelegate: self
                     didEndSelector: @selector(clearDataAlertDidEnd:returnCode:contextInfo:)
                        contextInfo: nil];
} // End of onClearData

- (void)clearDataAlertDidEnd: (NSAlert *)alert
                  returnCode: (NSInteger)returnCode
                 contextInfo: (void *)contextInfo
{
    // Did not press ok.
    if (returnCode != NSAlertFirstButtonReturn)
    {
        return;
    } // End of user hit cancel

    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Removing Data";
            [progressWindowController beginSheetModalForWindow: self.window
                                             completionHandler: nil];
        });

        NSPredicate * deletePredicate = [NSPredicate predicateWithFormat: @"application.applicationId IN %@", applicationIds];
        NSLog(@"Format is: %@", deletePredicate.predicateFormat);

        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            NSString * deleteQuery = [NSString stringWithFormat: @"DELETE FROM review WHERE applicationId IN (%@)",
                                      [applicationIds componentsJoinedByString: @","]];

            BOOL success = [database executeUpdate: deleteQuery];

            if(!success)
            {
                NSLog(@"Failed to delete from ranks.");
            }
            else
            {
                NSLog(@"Was able to delete from ranks.");
            }

        }];

        [[AWSQLiteHelper rankingDatabaseQueue] inTransaction: ^(FMDatabase * database, BOOL * rollback) {
            NSString * deleteQuery = [NSString stringWithFormat: @"DELETE FROM rank WHERE applicationId IN (%@)",
                                      [applicationIds componentsJoinedByString: @","]];

            BOOL success = [database executeUpdate: deleteQuery];

            if(!success)
            {
                NSLog(@"Failed to delete from ranks.");
            }
            else
            {
                NSLog(@"Was able to delete from ranks.");
            }
        }];

        // Fire some update notifications.
        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReportsNotificationName]
                                                            object: nil];

        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newRanksNotificationName]
                                                            object: nil];

        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                            object: nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [progressWindowController endSheetWithReturnCode: 0];
        });
    });
}

- (IBAction) onCancel: (id) sender
{
    [self endSheetWithReturnCode: NSModalResponseCancel];
}

- (IBAction) onAccept: (id) sender
{
    // Update our apps.
    NSPredicate * applicationPredicate = [NSPredicate predicateWithFormat: @"%K IN %@",
                                          @"applicationId", applicationIds];

    NSArray * applications = [[AWApplication allApplications] filteredArrayUsingPredicate: applicationPredicate];

    [applications enumerateObjectsUsingBlock: ^(AWApplication * application, NSUInteger applicationIndex, BOOL * stop)
     {
         if(downloadRanksButtonCell.state != NSMixedState)
         {
             application.shouldCollectRanks = [NSNumber numberWithBool: downloadRanksButtonCell.state == NSOnState ? YES : NO];
         }

         if(downloadReviewsButtonCell.state != NSMixedState)
         {
             application.shouldCollectReviews = [NSNumber numberWithBool: downloadReviewsButtonCell.state == NSOnState ? YES : NO];
         }

        [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appwageDatabase, BOOL * rollback)
         {
             NSArray * arguments = @[
                 application.shouldCollectRanks,
                 application.shouldCollectReviews,
                 application.applicationId
             ];

             [appwageDatabase executeUpdate: @"UPDATE application SET shouldCollectRanks = ?, shouldCollectReviews = ? WHERE applicationId = ?"
                       withArgumentsInArray: arguments];
         }];
     }];

    [self endSheetWithReturnCode: NSModalResponseOK];
}

@end

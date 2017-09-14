//
//  ApplicationSelectionWindowController.m
//  AppWage
//
//  Created by Kyle Hankinson on 12/5/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "ApplicationSelectionWindowController.h"
#import "AWApplication.h"
#import "AWApplicationFinder.h"
#import "AWIconCollectorOperation.h"

@interface ApplicationSelectionWindowController ()<ApplicationFinderProtocol, NSTableViewDataSource, NSTableViewDelegate, AWIconCollectionProtocol>
{
    IBOutlet    NSTableView                 * searchResultTableView;
    IBOutlet    NSSearchField               * appSearchField;
    IBOutlet    NSProgressIndicator         * searchingProgressIndicator;

    IBOutlet    NSButtonCell                * toggleAllAppsButtonCell;
    IBOutlet    NSButtonCell                * osxPlatformButtonCell;
    IBOutlet    NSButtonCell                * iosPlatformButtonCell;
    IBOutlet    NSButtonCell                * iBookPlatformButtonCell;

    NSTimer                                 * searchTimer;
    NSString                                * lastSearch;
    
    AWApplicationFinder                     * applicationFinder;
    NSArray                                 * currentApplications;
    
    NSMutableArray                          * selectedApplicationIds;
    
    NSOperationQueue                        * iconCollectionOperationQueue;
}
@end

@implementation ApplicationSelectionWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    selectedApplicationIds = [NSMutableArray array];
}

- (IBAction) onToggleAllApps: (id) sender
{
    // No apps available, do nothing.
    if(0 == currentApplications.count)
    {
        toggleAllAppsButtonCell.allowsMixedState = NO;
        toggleAllAppsButtonCell.state = NSOffState;
        return;
    }

    if(0 == selectedApplicationIds.count)
    {
        [selectedApplicationIds removeAllObjects];
        [selectedApplicationIds addObjectsFromArray:
         [currentApplications valueForKey: @"applicationId"]
         ];

        toggleAllAppsButtonCell.allowsMixedState = NO;
        toggleAllAppsButtonCell.state = NSOnState;
    }
    else
    {
        [selectedApplicationIds removeAllObjects];

        toggleAllAppsButtonCell.allowsMixedState = NO;
        toggleAllAppsButtonCell.state = NSOffState;
    }
    
    [searchResultTableView reloadData];
}

- (IBAction) doSearch: (id) sender
{
    [searchTimer invalidate];
    searchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                   target: self
                                                 selector: @selector(actualSearch)
                                                 userInfo: nil
                                                  repeats: NO];
}

- (void) actualSearch
{
    if([lastSearch isEqualToString: appSearchField.stringValue]) return;
    lastSearch = appSearchField.stringValue;

    NSLog(@"Want to search for: %@", appSearchField.stringValue);

    toggleAllAppsButtonCell.state = NSOffState;
    toggleAllAppsButtonCell.allowsMixedState = NO;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Setup our icon collection (cancel any existing)
        [iconCollectionOperationQueue cancelAllOperations];
        iconCollectionOperationQueue = [[NSOperationQueue alloc] init];
        iconCollectionOperationQueue.maxConcurrentOperationCount = 1;

        [selectedApplicationIds removeAllObjects];

        currentApplications = [NSArray array];

        dispatch_async(dispatch_get_main_queue(), ^{
            if(0 == appSearchField.stringValue.length)
            {
                NSLog(@"Nothing entered in search field. Clearing.");
                    [searchingProgressIndicator stopAnimation: self];
                    [searchResultTableView reloadData];
                return;
            }

            [searchResultTableView reloadData];
            [searchingProgressIndicator startAnimation: self];
        });

        // The application finder
        applicationFinder.delegate = nil;

        NSLog(@"Going to start the search");
        applicationFinder = [[AWApplicationFinder alloc] init];
        applicationFinder.delegate = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            [applicationFinder beginFindApplications: appSearchField.stringValue
             includeIOS: true includeOSX: true includeIBOOK: false];
        });
    });
}

- (IBAction) onCancel: (id) sender
{
    // Cancel
    [iconCollectionOperationQueue cancelAllOperations];

    [self endSheetWithReturnCode: NSModalResponseCancel];
} // End of onCancel

- (IBAction) onAccept: (id) sender
{
    // Cancel
    [iconCollectionOperationQueue cancelAllOperations];

    [self endSheetWithReturnCode: NSModalResponseOK];
} // End of onAccept

#pragma mark -
#pragma mark ApplicationFinderDelegate

- (void) applicationFinder: (AWApplicationFinder *)applicationFinder
      receivedApplications: (NSArray *)applications
{
    NSLog(@"Found %ld results.", applications.count);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [applications enumerateObjectsUsingBlock:
         ^(AWApplicationFinderEntry * applicationFinderEntry, NSUInteger index, BOOL * stop)
         {
             if(nil != [AWApplicationImageHelper imageForApplicationId: applicationFinderEntry.applicationId])
             {
                 return;
             } // End of we alrady have an image.

             // Otherwise, we need to download the image
             IconCollectorOperation * iconCollectionOperation = [[IconCollectorOperation alloc] init];
             iconCollectionOperation.applicationId = applicationFinderEntry.applicationId;
             iconCollectionOperation.delegate = self;
             iconCollectionOperation.shouldRoundIcon = [applicationFinderEntry.applicationType isEqual: ApplicationTypeIOS];

             [iconCollectionOperationQueue addOperation: iconCollectionOperation];
         }];
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        [selectedApplicationIds removeAllObjects];
        currentApplications = applications;
        [searchResultTableView reloadData];
        [searchingProgressIndicator stopAnimation: self];
    });
} // End of received applications

- (void) applicationFinder: (AWApplicationFinder*) applicationFinder
             receivedError: (NSError*) error
{
    NSLog(@"Received an error searching: %@", error.localizedDescription);
}

- (NSArray*) getSelectedApplications
{
    NSMutableArray * results = [NSMutableArray array];
    for(AWApplicationFinderEntry * entry in currentApplications)
    {
        if([selectedApplicationIds containsObject: entry.applicationId])
        {
            [results addObject: entry];
        }
    }
    
    return results;
}

#pragma mark -
#pragma mark NSTableView

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return currentApplications.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row >= currentApplications.count)
    {
        return nil;
    }
    
    AWApplicationFinderEntry * entry = currentApplications[row];

    if(NSOrderedSame == [@"Application" caseInsensitiveCompare: tableColumn.identifier])
    {
        return entry.applicationName;
    }
    else if(NSOrderedSame == [@"Publisher" caseInsensitiveCompare: tableColumn.identifier])
    {
        return entry.applicationDeveloper;
    }
    else if(NSOrderedSame == [@"IsApplicationSelected" caseInsensitiveCompare: tableColumn.identifier])
    {
        return [NSNumber numberWithBool: [selectedApplicationIds containsObject: entry.applicationId]];
    }
    else if(NSOrderedSame == [@"Platform" caseInsensitiveCompare: tableColumn.identifier])
    {
        return [entry.applicationType isEqual: ApplicationTypeIOS] ? @"iOS" : @"OSX";
    }
    else if(NSOrderedSame == [@"Image" caseInsensitiveCompare: tableColumn.identifier])
    {
        return [AWApplicationImageHelper imageForApplicationId: entry.applicationId];
    }

    NSLog(@"Unknown column: %@", tableColumn.identifier);
    return tableColumn.identifier;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row >= currentApplications.count)
    {
        return;
    }

    AWApplicationFinderEntry * entry = currentApplications[row];

    if(NSOrderedSame == [@"IsApplicationSelected" caseInsensitiveCompare: tableColumn.identifier])
    {
        NSNumber * numberValue = object;
        if([numberValue boolValue])
        {
            [selectedApplicationIds addObject: entry.applicationId];
        }
        else
        {
            [selectedApplicationIds removeObject: entry.applicationId];
        }

        if(0 == selectedApplicationIds.count)
        {
            toggleAllAppsButtonCell.allowsMixedState = NO;
            toggleAllAppsButtonCell.state = NSOffState;
        }
        else if (selectedApplicationIds.count == currentApplications.count)
        {
            toggleAllAppsButtonCell.allowsMixedState = NO;
            toggleAllAppsButtonCell.state = NSOnState;
        }
        else
        {
            toggleAllAppsButtonCell.allowsMixedState = YES;
            toggleAllAppsButtonCell.state = NSMixedState;
        }
    }
}

#pragma mark -
#pragma mark AWIconCollectionProtocol

- (void) receivedIconForApplicationId: (NSNumber*) applicationId
{
    NSLog(@"Received an icon image.");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [searchResultTableView reloadData];
    });
}

@end

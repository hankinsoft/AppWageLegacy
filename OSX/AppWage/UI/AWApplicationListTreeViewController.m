//
//  ApplicationListTreeViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationListTreeViewController.h"

#import "AWApplicationListTreeEntry.h"

#import "AWAccountHelper.h"

#import "AWAccount.h"
#import "AWApplication.h"
#import "AWProduct.h"
#import "AWApplicationCollection.h"
#import "AWGenre.h"

#import "AWApplicationImageHelper.h"
#import "AWApplicationTableCellView.h"

#import "AWCollectionOperationQueue.h"
#import "ApplicationSelectionWindowController.h"

#import "AWApplicationFinder.h"

#import "AWIconCollectorOperation.h"
#import "HSProgressWindowController.h"
#import "ApplicationPreferencesWindowController.h"
#import "AWPreferencesWindowController.h"

#import "HSOutlineView.h"

#define kExpandedEntries                @"ApplicationListTreeView-ExpandedItems"

@interface AWApplicationListTreeViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate, OutlineViewWithMenuDelegate, AWIconCollectionProtocol, NSMenuDelegate>
{
    dispatch_semaphore_t                    applicationLoadSemaphore;

    ApplicationSelectionWindowController    * applicationSelectionWindowController;
    ApplicationPreferencesWindowController  * applicationPreferencesWindowController;
    AWPreferencesWindowController           * preferencesWindowController;

    HSProgressWindowController              * progressWindowController;

    IBOutlet NSScrollView                   * applicationListScrollView;
    IBOutlet HSOutlineView                  * applicationsOutlineView;
    IBOutlet NSView                         * bottomBarImageView;
    IBOutlet NSMenu                         * addMenu;
    IBOutlet NSMenuItem                     * hideApplicationsMenuItem;
    IBOutlet NSMenuItem                     * removeApplicationsMenuItem;

    NSArray                                 * treeEntries;
    NSSet                                   * currentlySelectedApplicationIds;
    NSIndexSet                              * previouslySelectedIndexSet;

    IBOutlet NSMenu                         * applicationsOutlineViewMenu;

    NSOperationQueue                        * iconDownloadOperationQueue;
}
@end

@implementation AWApplicationListTreeViewController

@synthesize delegate;

static NSMutableSet                            * outlineViewExpandedEntries;

+ (void) initialize
{
    // Initialize our expanded entries
    outlineViewExpandedEntries = [NSMutableSet setWithArray: [[NSUserDefaults standardUserDefaults] objectForKey: kExpandedEntries]];
} // End of initialize

#pragma mark -
#pragma mark NSOutlineViewDataSource

+ (NSString*) applicationListRequiresUpdateNotificationName
{
    return @"applicationListRequiresUpdateNotification";
}

+ (void) expandAccount: (NSString*) accountName
{
    [outlineViewExpandedEntries addObject: accountName];
    
    [[NSUserDefaults standardUserDefaults] setObject: [outlineViewExpandedEntries allObjects]
                                              forKey: kExpandedEntries];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
} // End of expandAccount

- (id) init
{
    self = [super initWithNibName: @"AWApplicationListTreeViewController"
                           bundle: nil];
    if(self)
    {
        applicationLoadSemaphore   = dispatch_semaphore_create(1);

        iconDownloadOperationQueue = [[NSOperationQueue alloc] init];
        iconDownloadOperationQueue.maxConcurrentOperationCount = 1;
    } // End of self

    return self;
} // End of init

- (void) loadView
{
    [super loadView];
    
    [applicationsOutlineView setIsDark: YES];
} // End of loadView

- (void) initialize
{
    applicationsOutlineView.menuDelegate = self;
    currentlySelectedApplicationIds = [NSSet set];

    // Watch for application changes.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(shouldReloadApplications:)
                                                 name: [AWApplicationListTreeViewController applicationListRequiresUpdateNotificationName]
                                               object: nil];
    
    // Watch for review changes.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(newReviews:)
                                                 name: [AWCollectionOperationQueue newReviewsNotificationName]
                                               object: nil];
    
    // Reload the applications
    [self reloadApplications];
} // End of initialize

- (void) shouldReloadApplications: (NSNotification*) aNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Reload the applications
        [self reloadApplications];
    });
}

- (void) newReviews: (NSNotification*) aNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Reload the applications
        [self reloadApplications];
    });
}

- (void)addApplications: (NSMutableArray *)childEntries
                   root: (AWApplicationListTreeEntry *)root
           applications: (NSArray *)allApplications
{
    // No applications, then do nothing.
    if(nil == allApplications || 0 == allApplications.count)
    {
        return;
    }

    BOOL showingHiddenApplications = [[AWSystemSettings sharedInstance] shouldShowHiddenApplications];

    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                                      ascending: YES
                                                                       selector: @selector(localizedCaseInsensitiveCompare:)];

    NSArray * applications = [allApplications sortedArrayUsingDescriptors: @[sortDescriptor]];

    [applications enumerateObjectsUsingBlock:
     ^(AWApplication * temp, NSUInteger applicationIndex, BOOL * stop)
     {
        if(!showingHiddenApplications && temp.hiddenByUser.boolValue)
        {
            return;
        }

        AWApplicationListTreeEntry * childEntry = [[AWApplicationListTreeEntry alloc] init];
        childEntry.display           = temp.name;

        childEntry.parent            = root;
        childEntry.children          = nil;
        childEntry.representedObject = temp.applicationId;
        childEntry.representedType   = ApplicationListTreeEntryTypeApplication;
        childEntry.isHidden          = temp.hiddenByUser.boolValue;

        __block NSUInteger reviewCount = 0;

        [[AWSQLiteHelper reviewDatabaseQueue] inDatabase:^(FMDatabase * reviewDatabase) {
             // Delete all
            NSString * countQuery = [NSString stringWithFormat: @"SELECT COUNT(*) FROM review WHERE applicationId = %@", temp.applicationId];

            FMResultSet * results = [reviewDatabase executeQuery: countQuery];
            while([results next])
            {
                reviewCount = [results intForColumnIndex: 0];
            } // End of loop
        }];

        childEntry.subDisplay = [NSString stringWithFormat: @"%ld reviews", reviewCount];

        NSImage * image = [AWApplicationImageHelper imageForApplicaton: temp];
        if(nil == image)
        {
            IconCollectorOperation * iconCollectionOperation = [[IconCollectorOperation alloc] init];
            iconCollectionOperation.applicationId = temp.applicationId;
            iconCollectionOperation.delegate = self;
            iconCollectionOperation.shouldRoundIcon = [temp.applicationType isEqual: ApplicationTypeIOS];

            // Add our icon collection operation
            [iconDownloadOperationQueue addOperation: iconCollectionOperation];
        } // End of we had no image

        NSArray * applicationProducts = nil;

         // Do we have any child products?
        applicationProducts = [AWProduct productsByApplicationId: temp.applicationId];

         __block NSMutableArray * productTreeEntries = [NSMutableArray array];

         // Generally we will have one product to represent the application itself. Its possible
         // we may have more (in app purchases, iAds, etc).
         if(applicationProducts.count > 1)
         {
             // Add the child products.
             [applicationProducts enumerateObjectsUsingBlock:
              ^(AWProduct * product, NSUInteger index, BOOL * stop)
              {
                  AWApplicationListTreeEntry * productEntry = [[AWApplicationListTreeEntry alloc] init];

                  productEntry.display           = product.title;
                  productEntry.parent            = childEntry;
                  productEntry.children          = nil;
                  productEntry.representedObject = product.appleIdentifier;
                  productEntry.representedType   = ApplicationListTreeEntryTypeProduct;
                  productEntry.isHidden          = NO;

                  // The product that links directly to the app, goes first.
                  if([product.appleIdentifier isEqualToNumber: temp.applicationId])
                  {
                      [productTreeEntries insertObject: productEntry
                                               atIndex: 0];
                  }
                  // Add it to the end.
                  else
                  {
                      // Add the product entry
                      [productTreeEntries addObject: productEntry];
                  }
              }];
         } // End of we have more than one product

         // Set the children
         childEntry.children = [productTreeEntries copy];

        [childEntries addObject: childEntry];
    }]; // End of applications loop

    // Set the children.
    root.children = [childEntries copy];
}

- (void) reloadApplications
{
    if(0 != dispatch_semaphore_wait(applicationLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    NSPoint currentScrollPosition = [[applicationListScrollView contentView] bounds].origin;
    NSSet * selection = [self preserveApplicationTreeSelection];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"ApplicationListTreeViewController - Reloading applications.");
        @autoreleasepool {
            // Entries have been loaded. We can reload the UI.
            dispatch_async(dispatch_get_main_queue(), ^{
                // Load our applications
                treeEntries = [self safeLoadApplications];

                [applicationsOutlineView reloadData];

                // Make sure we are expanded where we should be.
                for(NSInteger index = 0; index < [applicationsOutlineView numberOfRows]; ++index)
                {
                    AWApplicationListTreeEntry * treeEntry = [applicationsOutlineView itemAtRow: index];

                    // If our expanded entries contains the current identifier, then we can expand.
                    if([outlineViewExpandedEntries filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"self ==[cd] %@", [treeEntry identifier]]].count > 0)
                    {
                        // Expand our toplevel nodes
                        [applicationsOutlineView expandItem: treeEntry
                                             expandChildren: NO];
                    }
                } // End of loop

                // Restore our selection
                [self restoreApplicationTreeSelection: selection];

                // Restore scroll position
                [[applicationListScrollView documentView] scrollPoint:currentScrollPosition];

                dispatch_semaphore_signal(applicationLoadSemaphore);
            });
        } // End of autorelease pool
    });
} // End of reloadApplications

- (NSArray *) safeLoadApplications
{
    AWApplicationListTreeEntry * allAccountsEntry = [[AWApplicationListTreeEntry alloc] init];
    allAccountsEntry.display = @"All Products";
    allAccountsEntry.parent            = nil;
    allAccountsEntry.representedObject = nil;
    allAccountsEntry.representedType   = ApplicationListTreeEntryTypeAllProducts;

    NSMutableArray * rootNodes = [NSMutableArray arrayWithObject: allAccountsEntry];

    // Add any nodes for accounts
    NSArray * nodesForAccounts = [self nodesForAccounts];
    if(0 != nodesForAccounts.count)
    {
        [rootNodes addObjectsFromArray: nodesForAccounts];
    } // End of we had accounts

    NSArray * nodesForCollections = [self nodesForCollections];
    if(0 != nodesForCollections.count)
    {
        [rootNodes addObjectsFromArray: nodesForCollections];
    }

    // Set our children
    return rootNodes;
} // End of safeLoadApplications

- (NSArray*) nodesForCollections
{
    NSMutableArray * results = [NSMutableArray array];

    NSMutableArray * allCollections = [NSMutableArray array];
    NSMutableArray * uncategorizedApplications = [NSMutableArray array];

    [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database)
     {
         FMResultSet * results = [database executeQuery: @"SELECT * FROM applicationCollection ORDER BY name"];

         while([results next])
         {
             NSDictionary * collection = @{
                @"id": [NSNumber numberWithInt: [results intForColumn: @"id"]],
                @"name": [results stringForColumn: @"name"]
             };

             [allCollections addObject: collection];
         } // End of results loop

         // Get all applications
         results = [database executeQuery: @"SELECT applicationId FROM application WHERE internalAccountId IS NULL"];

         while([results next])
         {
             NSUInteger _applicationId = [results intForColumn: @"applicationId"];
             NSNumber * applicationId = [NSNumber numberWithInteger: _applicationId];

             AWApplication * application = [AWApplication applicationByApplicationId: applicationId];

             [uncategorizedApplications addObject: application];
         } // End of results loop
     }];

#if Collections
    [allCollections enumerateObjectsUsingBlock: ^(ApplicationCollection * collection, NSUInteger collectionIndex, BOOL * stop)
     {
         ApplicationListTreeEntry * treeEntry = [[ApplicationListTreeEntry alloc] init];
         treeEntry.display           = collection.name;
         treeEntry.parent            = nil;
         treeEntry.representedObject = nil;

         NSMutableArray * children = [NSMutableArray array];

         [self addApplications: children
                          root: treeEntry
                  applications: [collection.applications allObjects]
                     inContext: appLoadingContext];
         
         treeEntry.children          = [NSArray arrayWithArray: children];

         [rootNodes addObject: treeEntry];
     }];
#endif

    if(nil != uncategorizedApplications && 0 != uncategorizedApplications.count)
    {
        AWApplicationListTreeEntry * treeEntry = [[AWApplicationListTreeEntry alloc] init];
        treeEntry.display           = NSLocalizedString(@"Uncategorized", nil);
        treeEntry.parent            = nil;
        treeEntry.representedObject = nil;

        NSMutableArray * childEntries = [NSMutableArray array];
        [self addApplications: childEntries
                         root: treeEntry
                 applications: uncategorizedApplications];

        [results addObject: treeEntry];
    } // End of we had uncategorized apps

    return results;
} // End of nodesForCollections

- (NSArray*) nodesForAccounts
{
    NSArray * allAccounts = [AWAccount allAccounts];

    NSMutableArray * results = [NSMutableArray array];

    if(allAccounts.count > 0)
    {
        AWApplicationListTreeEntry * iTunesConnectEntry = [[AWApplicationListTreeEntry alloc] init];
        iTunesConnectEntry.display           = @"iTunes Connect";
        iTunesConnectEntry.parent            = nil;
        iTunesConnectEntry.representedObject = nil;
        
        NSMutableArray * iTunesConnectChildren = [NSMutableArray array];

        for(AWAccount * account in allAccounts)
        {
             // Get our account details
             AccountDetails * accountDetails =
                [[AWAccountHelper sharedInstance] accountDetailsForInternalAccountId: account.internalAccountId];

             AWApplicationListTreeEntry * accountEntry = [[AWApplicationListTreeEntry alloc] init];

             accountEntry.display           =
                nil == accountDetails ? @"Unknown account" : accountDetails.vendorName;

             accountEntry.parent            = iTunesConnectEntry;
             accountEntry.children          = nil;
             accountEntry.representedObject = nil;

             NSArray * accountApplications =
                [AWApplication applicationsByInternalAccountId: account.internalAccountId];

             NSMutableArray * childEntries = [NSMutableArray array];
             [self addApplications: childEntries
                              root: accountEntry
                      applications: accountApplications];

             // Add our sub account.
             [iTunesConnectChildren addObject: accountEntry];
        } // End of allAccounts enumeration

        iTunesConnectEntry.children          = [NSArray arrayWithArray: iTunesConnectChildren];
        [results addObject: iTunesConnectEntry];
    } // End of we have an iTunes Connect account

    return results;
}

#pragma mark -
#pragma mark OutlineViewWithMenu

-(NSMenu*) menuForEvent:(NSEvent*)theEvent
{
	if ([theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask))
    {
		NSPoint clickPoint = [applicationsOutlineView convertPoint:[theEvent locationInWindow] fromView:nil];
		NSInteger row = [applicationsOutlineView rowAtPoint:clickPoint];
		id item = [applicationsOutlineView itemAtRow:row];

		if (item != nil)
        {
            AWApplicationListTreeEntry * sourceListItem = (AWApplicationListTreeEntry*) item;
            if(sourceListItem.representedType == ApplicationListTreeEntryTypeApplication)
            {
                __block BOOL found = false;
                
                [[applicationsOutlineView selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger rowIndex, BOOL * stop)
                 {
                     if(rowIndex == row)
                     {
                         found = true;
                         *stop = true;
                     }
                 }];

                if(!found)
                {
                    NSLog(@"Selecting row %ld", row);

                    // Select the table.
                    [applicationsOutlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: row]
                                         byExtendingSelection: NO];
                }

                // Get our selected applicationIds
                NSSet * selectedApplicationsIds = [self getCurrentlySelectedProductIds];

                __block NSInteger state = NSOffState;
                __block NSInteger applicationHasAccount = NSOffState;

                NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"applicationId IN %@", selectedApplicationsIds];

                NSArray * applications = [[AWApplication allApplications] filteredArrayUsingPredicate: searchPredicate];

                @autoreleasepool {
                    [applications enumerateObjectsUsingBlock: ^(AWApplication * application, NSUInteger applicationIndex, BOOL * stop)
                     {
                         if(NSMixedState != state)
                         {
                             if(state == NSOnState && !application.hiddenByUser.boolValue)
                             {
                                 state = NSMixedState;
                             }
                             else if(application.hiddenByUser.boolValue)
                             {
                                 state = NSOnState;
                             }
                         }

                         if(NSMixedState != applicationHasAccount)
                         {
                             if(NSOnState == state && nil == application.internalAccountId)
                             {
                                 applicationHasAccount = NSMixedState;
                             }
                             else if(nil != application.internalAccountId)
                             {
                                 applicationHasAccount = NSOnState;
                             }
                         }
                     }];
                } // End of autoreleasepool

                // Update our hide menu
                [hideApplicationsMenuItem setState: state];
                [hideApplicationsMenuItem setEnabled: NO];
                [removeApplicationsMenuItem setEnabled: NO];

                if(NSOnState == applicationHasAccount)
                {
                    [hideApplicationsMenuItem setEnabled: YES];
                    [removeApplicationsMenuItem setEnabled: NO];
                }
                else if(NSOffState == applicationHasAccount)
                {
                    [hideApplicationsMenuItem setEnabled: NO];
                    [removeApplicationsMenuItem setEnabled: YES];
                }

                return applicationsOutlineViewMenu;
            }
		}
	} // End of right mouse button
	return nil;

} // End of menuForEvent

#pragma mark -
#pragma mark Actions

- (IBAction) onAdd: (id) sender
{
    NSButton * senderButton = (NSButton*) sender;

    NSPoint tableMenuPoint = [senderButton frame].origin;
    tableMenuPoint.x = NSMaxX([senderButton frame]) - [senderButton frame].size.width;

    NSPoint menuLocation = [NSEvent mouseLocation];
    menuLocation.x += 10;
    menuLocation.y += 10;

    [addMenu popUpMenuPositioningItem: [addMenu itemAtIndex: 1]
                           atLocation: menuLocation
                               inView: nil];
}

- (IBAction) onAddApplication: (id) sender
{
    applicationSelectionWindowController =
        [[ApplicationSelectionWindowController alloc] initWithWindowNibName: @"ApplicationSelectionWindowController"];

    [applicationSelectionWindowController beginSheetModalForWindow: self.view.window
                                                 completionHandler:^ (NSModalResponse returnCode)
     {
         if (returnCode != NSModalResponseOK)
         {
             return;
         } // End of user did not hit OK

         NSArray * selectedApplications = [applicationSelectionWindowController getSelectedApplications];

         for(AWApplicationFinderEntry * entry in selectedApplications)
         {
             // Find
             AWApplication * application = [AWApplication applicationByApplicationId: entry.applicationId];

             // We already track this application. Keep looking.
             if(nil != application)
             {
                 continue;
             } // End of no application

             application = [AWApplication createFromApplicationEntry: entry];
             // Save and wait. Do this for each application as each has modified the genre (by adding a link to it).

             // Add our application to the database
             [AWApplication addApplication: application];
         } // End of appliction loop

         // Reload our apps
         [self reloadApplications];

         // Queue our rank and review collection.
         [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval:
          0 == [AWSystemSettings sharedInstance].collectReviewsEveryXHours ? -1 : 0 specifiedAppIds: nil];

         [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 0 == [AWSystemSettings sharedInstance].collectRankingsEveryXHours ? -1 : 0
                                                                        specifiedAppIds: nil];
     }];
}

- (IBAction) onAddDeveloper: (id) sender
{
    preferencesWindowController = [[AWPreferencesWindowController alloc] init];
    preferencesWindowController.addingDeveloper = YES;

    [preferencesWindowController beginSheetModalForWindow: self.view.window
                                        completionHandler: ^(NSModalResponse returnCode)
     {
         if (returnCode != NSModalResponseOK)
         {
             return;
         }
     }];
}

- (IBAction) onHideApplications: (id) sender
{
    NSLog(@"Want to hide applications");

    NSSet * selectedApplicationIds = [self getCurrentlySelectedProductIds];
    NSPredicate * searchPredicate =
        [NSPredicate predicateWithFormat: @"%K IN %@", @"applicationId", selectedApplicationIds];

    NSArray * applications =
        [[AWApplication allApplications] filteredArrayUsingPredicate: searchPredicate];

    for(AWApplication * application in applications)
    {
        application.hiddenByUser = [NSNumber numberWithBool: !application.hiddenByUser.boolValue];
        [[AWSQLiteHelper appWageDatabaseQueue] inTransaction: ^(FMDatabase * appwageDatabase, BOOL * rollback) {
            [appwageDatabase executeUpdate: @"UPDATE application SET hiddenByUser = ? WHERE applicationId = ?"
                      withArgumentsInArray: @[application.hiddenByUser, application.applicationId]];
        }];
    } // End of application enumeration

    [self reloadApplications];
} // End of onHideApplications

- (IBAction) onCollectReviewForSelectedApplications: (id) sender
{
    // Queue review colleciton with our selection.
    [[AWCollectionOperationQueue sharedInstance] queueReviewCollectionWithTimeInterval: 0
                                                                     specifiedAppIds: currentlySelectedApplicationIds];
}

- (IBAction) onCollectRanksForSelectedApplications: (id) sender
{
    // Queue rank colleciton with our selection.
    [[AWCollectionOperationQueue sharedInstance] queueRankCollectionWithTimeInterval: 0
                                                                     specifiedAppIds: currentlySelectedApplicationIds];
}

- (IBAction) onRemoveApplication: (id) sender
{
    // Lets find all applications to remove.
    __block NSMutableArray * applicationIdsToRemove = [NSMutableArray array];
    [[applicationsOutlineView selectedRowIndexes] enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL * stop)
     {
         AWApplicationListTreeEntry * treeEntry = [applicationsOutlineView itemAtRow: index];
         if(nil == treeEntry || treeEntry.representedType == ApplicationListTreeEntryTypeUnspecified)
         {
             return;
         }

         [applicationIdsToRemove addObject: treeEntry.representedObject];
     }];
    
    // If we have no apps to remove, then exit
    if(0 == applicationIdsToRemove.count)
    {
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle: @"OK"];
    [alert addButtonWithTitle: @"Cancel"];
    
    if(1 == applicationIdsToRemove.count)
    {
        id applicationIdToRemove = applicationIdsToRemove[0];
        AWApplication * applicationToRemove = [AWApplication applicationByApplicationId: applicationIdToRemove];

        [alert setMessageText:     [NSString stringWithFormat: @"Remove '%@'?", applicationToRemove.name]];
        [alert setInformativeText: [NSString stringWithFormat: @"Are you sure that you would like to remove '%@'? The data cannot be recovered.", applicationToRemove.name]];
    }
    else
    {
        [alert setMessageText:     @"Remove application(s)?"];
        [alert setInformativeText: @"Are you sure that you would like to remove the selected applications? The data cannot be recovered."];
    }

    [alert setAlertStyle: NSWarningAlertStyle];
    [alert beginSheetModalForWindow: self.view.window
                      modalDelegate: self
                     didEndSelector: @selector(removeApplicationsAlertDidEnd:returnCode:contextInfo:)
                        contextInfo: (__bridge_retained void *)(applicationIdsToRemove)];

    NSLog(@"Want to remove app with ids: %@", applicationIdsToRemove);
}



- (void)removeApplicationsAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode
                 contextInfo:(void *)contextInfo
{
    // Did not press ok.
    if (returnCode != NSAlertFirstButtonReturn)
    {
        return;
    }

    NSArray * applicationIdsToRemove = (__bridge_transfer NSArray*) contextInfo;

    // Cancel any and all operations we have going
    [[AWCollectionOperationQueue sharedInstance] cancelAllOperations: YES];

    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = [NSString stringWithFormat: @"Removing application%@",
                                                    1 == applicationIdsToRemove.count ? @"" : @"s"];
            [progressWindowController beginSheetModalForWindow: self.view.window
                                             completionHandler: nil];
        });

        __block NSUInteger reviewCount = 0;

        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete all
            NSString * countQuery = [NSString stringWithFormat: @"SELECT COUNT(*) FROM review WHERE applicationId IN (%@)", [applicationIdsToRemove componentsJoinedByString: @", "]];

            FMResultSet * results = [database executeQuery: countQuery];
            while([results next])
            {
                reviewCount = [results intForColumnIndex: 0];
            } // End of loop
        }];

        NSPredicate * linkDeletePredicate = [NSPredicate predicateWithFormat: @"%K IN %@",
                                             @"application.applicationId",
                                             applicationIdsToRemove];
        NSPredicate * applicationDeletePredicate = [NSPredicate predicateWithFormat: @"%K IN %@",
                                                    @"applicationId",
                                                    applicationIdsToRemove];

        NSArray * applicationsToDelete = [[AWApplication allApplications] filteredArrayUsingPredicate: applicationDeletePredicate];

        NSLog(@"Deleting %ld reviews for %ld apps.\r\n%@\r\n%@",
              reviewCount,
              applicationsToDelete.count,
              [linkDeletePredicate predicateFormat],
              [applicationDeletePredicate predicateFormat]
        );

        [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete all
            NSString * deleteQuery = [NSString stringWithFormat: @"DELETE FROM review WHERE applicationId IN (%@)", [applicationIdsToRemove componentsJoinedByString: @", "]];

            [database executeUpdate: deleteQuery];
        }];

        [[AWSQLiteHelper rankingDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete all
            NSString * deleteQuery = [NSString stringWithFormat: @"DELETE FROM rank WHERE applicationId IN (%@)", [applicationIdsToRemove componentsJoinedByString: @", "]];

            [database executeUpdate: deleteQuery];
        }];

        NSLog(@"Deleting %ld of %ld Apps",
              applicationsToDelete.count,
              [AWApplication allApplications].count
        );

        [[AWSQLiteHelper appWageDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL * rollback) {
            // Delete genre links first
            NSString * deleteQuery = [NSString stringWithFormat: @"DELETE FROM applicationGenre WHERE applicationId IN (%@)", [applicationIdsToRemove componentsJoinedByString: @", "]];

            [database executeUpdate: deleteQuery];

            // Now delete the apps
            deleteQuery = [NSString stringWithFormat: @"DELETE FROM application WHERE applicationId IN (%@)", [applicationIdsToRemove componentsJoinedByString: @", "]];

            [database executeUpdate: deleteQuery];
        }];

        NSLog(@"We have %ld apps left.", [AWApplication allApplications].count);

        // Post a review and rank update
        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newReviewsNotificationName]
                                                            object: nil];

        [[NSNotificationCenter defaultCenter] postNotificationName: [AWCollectionOperationQueue newRanksNotificationName]
                                                            object: nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadApplications];

            // Deselect them all
            [applicationsOutlineView deselectAll: self];

            [self handleApplicationSelectionChanged];

            [progressWindowController endSheetWithReturnCode: 0];
        });
    });
}

- (IBAction) onApplicationProperties: (id) sender
{
    NSLog(@"On application properties");

    applicationPreferencesWindowController = [[ApplicationPreferencesWindowController alloc] init];
    applicationPreferencesWindowController.applicationIds = [[self getCurrentlySelectedProductIds] allObjects];

    [applicationPreferencesWindowController beginSheetModalForWindow: self.view.window
                                                   completionHandler: nil];
}

- (IBAction) onTwitter: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://twitter.com/appwage"]];
}

- (IBAction) onFacebook: (id) sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://facebook.com/appwage"]];    
}

#pragma mark -
#pragma mark OutletView

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView
                 rowViewForItem:(id)item
{
    HSTableRowView *rowView = [[HSTableRowView alloc] initWithFrame: NSZeroRect];
    rowView.isDark = applicationsOutlineView.isDark;

    return rowView;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(nil == item)
    {
        return treeEntries.count;
    } // End of root item

    AWApplicationListTreeEntry * currentTreeEntry = (AWApplicationListTreeEntry *) item;
    if(nil == currentTreeEntry.children)
    {
        return 0;
    }

    return currentTreeEntry.children.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(nil == item)
    {
        return treeEntries[index];
    }

    AWApplicationListTreeEntry * currentEntry = (AWApplicationListTreeEntry*) item;
    id result = currentEntry.children[index];

    NSAssert([result isKindOfClass: [AWApplicationListTreeEntry class]], @"Invalid class");
    return result;
}

- (CGFloat)outlineView: (NSOutlineView *)outlineView
     heightOfRowByItem: (id)item
{
    AWApplicationListTreeEntry * currentEntry = (AWApplicationListTreeEntry*) item;

    if(currentEntry.representedType == ApplicationListTreeEntryTypeApplication)
    {
        return 36;
    } // End of table

    return 22;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    AWApplicationListTreeEntry * currentEntry = (AWApplicationListTreeEntry*) item;

    NSTableCellView * resultCell;

    __block BOOL isSelected = NO;
    
    if(-1 != [outlineView selectedRow])
    {
        [[outlineView selectedRowIndexes] enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL * stop)
         {
             AWApplicationListTreeEntry * selectedTreeEntry = [outlineView itemAtRow: index];
             if(selectedTreeEntry == currentEntry)
             {
                 isSelected = YES;
             }
         }];
    } // End of we have something selected

    if(ApplicationListTreeEntryTypeUnspecified == currentEntry.representedType)
    {
        resultCell = [outlineView makeViewWithIdentifier: @"HeaderCell" owner:self];
    }
    else if(ApplicationListTreeEntryTypeAllProducts == currentEntry.representedType)
    {
        resultCell = [outlineView makeViewWithIdentifier: @"HeaderCell" owner:self];
    }
    else if(ApplicationListTreeEntryTypeProduct == currentEntry.representedType)
    {
        resultCell = [outlineView makeViewWithIdentifier: @"ProductCell" owner:self];
    }
    else if(ApplicationListTreeEntryTypeApplication == currentEntry.representedType)
    {
        resultCell = [outlineView makeViewWithIdentifier: @"DataCell" owner:self];
    }

    // Update the cell
    [self updateCell: resultCell
          isSelected: isSelected
               entry: currentEntry];

    return resultCell;
}

- (void) updateCell: (NSTableCellView*) tableCellView
         isSelected: (BOOL) isSelected
              entry: (AWApplicationListTreeEntry *) currentEntry
{
    NSColor * textColor = [NSColor colorWithSRGBRed: 180.0 / 255.0
                                              green: 178.0 / 255.0
                                               blue: 178.0 / 255.0
                                              alpha: 1.0];

    NSColor * textColor3 = [NSColor colorWithSRGBRed: 0.9
                                               green: 0.9
                                                blue: 0.9
                                               alpha: 1.0];

    if(ApplicationListTreeEntryTypeUnspecified == currentEntry.representedType ||
       ApplicationListTreeEntryTypeAllProducts == currentEntry.representedType)
    {
        tableCellView.textField.stringValue = [nil == currentEntry.display ? @"<nil>" : currentEntry.display uppercaseString];
        
        tableCellView.textField.textColor   = textColor3;
    }
    else if(ApplicationListTreeEntryTypeProduct == currentEntry.representedType)
    {
        tableCellView.textField.stringValue = nil == currentEntry.display ? @"<nil>" : currentEntry.display;
        tableCellView.textField.textColor   = textColor3;
    } // End of product
    else if(ApplicationListTreeEntryTypeApplication == currentEntry.representedType)
    {
        AWApplicationTableCellView * applicationTableViewCell = (AWApplicationTableCellView*) tableCellView;

        // Setup our display
        applicationTableViewCell.appNameTextView.stringValue    = currentEntry.display;
        NSMutableAttributedString *as = [[applicationTableViewCell.appNameTextView attributedStringValue] mutableCopy];
        
        [as addAttribute: NSStrikethroughStyleAttributeName
                   value: (NSNumber *)(currentEntry.isHidden ? kCFBooleanTrue : kCFBooleanFalse)
                   range: NSMakeRange(0, [as length])];

        [as addAttribute: NSForegroundColorAttributeName
                   value: textColor3
                   range: NSMakeRange(0, [as length])];

        [applicationTableViewCell.appNameTextView setAttributedStringValue: as];

        applicationTableViewCell.appDetailsTextView.stringValue = currentEntry.subDisplay;
        applicationTableViewCell.appDetailsTextView.textColor   = textColor;
        
        tableCellView.imageView.image =
            [AWApplicationImageHelper imageForApplicationId: currentEntry.representedObject];
    }
} // End of updateCell

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if(nil == item)
    {
        return NO;
    }

    AWApplicationListTreeEntry * currentEntry = (AWApplicationListTreeEntry *) item;
    if(0 == currentEntry.children.count)
    {
        return NO;
    }

    return YES;
}

- (BOOL)outlineView: (NSOutlineView *)outlineView
        isGroupItem: (id)item
{
    return NO;
}

#pragma mark -
#pragma mark Notifications

- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    NSString * sourceIdentifier = [[[notification userInfo] objectForKey:@"NSObject"] identifier];
    [outlineViewExpandedEntries removeObject: sourceIdentifier];

    [[NSUserDefaults standardUserDefaults] setObject: [outlineViewExpandedEntries allObjects]
                                              forKey: kExpandedEntries];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    NSString * sourceIdentifier = [[[notification userInfo] objectForKey:@"NSObject"] identifier];
    [outlineViewExpandedEntries addObject: sourceIdentifier];

    [[NSUserDefaults standardUserDefaults] setObject: [outlineViewExpandedEntries allObjects]
                                              forKey: kExpandedEntries];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    // Our selection has changed.
    [self handleApplicationSelectionChanged];

    NSDisableScreenUpdates();

    for(NSInteger index = 0; index < applicationsOutlineView.numberOfRows; ++index)
    {
        if([applicationsOutlineView numberOfRows] < index) return;

        NSTableRowView * tableRow = [applicationsOutlineView rowViewAtRow: index
                                                          makeIfNecessary: YES];

        NSTableCellView * tableCell = [tableRow viewAtColumn: 0];

        AWApplicationListTreeEntry * currentEntry = [applicationsOutlineView itemAtRow: index];

        if([[applicationsOutlineView selectedRowIndexes] containsIndex: index])
        {
            [self updateCell: tableCell
                  isSelected: YES
                       entry: currentEntry];
        } // End of the row is selected
        else if([previouslySelectedIndexSet containsIndex: index])
        {
            [self updateCell: tableCell
                  isSelected: NO
                       entry: currentEntry];
        } // End of the row is selected
    };

    // Re-enable screen updates
    NSEnableScreenUpdates();

    // Copy our selected indexes
    previouslySelectedIndexSet = [applicationsOutlineView.selectedRowIndexes copy];
}

- (void) handleApplicationSelectionChanged
{
    NSIndexSet * selectedRows = [applicationsOutlineView selectedRowIndexes];

    if(nil == selectedRows || 0 == selectedRows.count)
    {
        if(0 != currentlySelectedApplicationIds.count)
        {
            currentlySelectedApplicationIds = [NSSet set];
            NSLog(@"Selection changed. %ld entries.", currentlySelectedApplicationIds.count);

            // Update our selected applications
            [delegate selectedApplicationsChanged: currentlySelectedApplicationIds];
        } // End of we previously had nothing selected.

        return;
    } // End of selection changed

    NSSet * _selectedApplicationIds = [self getCurrentlySelectedProductIds];

    if(![_selectedApplicationIds isEqualToSet: currentlySelectedApplicationIds])
    {
        currentlySelectedApplicationIds = _selectedApplicationIds;
        NSLog(@"Selection changed. %ld entries.", currentlySelectedApplicationIds.count);

        // Update our selected applications
        [delegate selectedApplicationsChanged: currentlySelectedApplicationIds];
    }
}

- (void)processSelectionForTreeEntry: (AWApplicationListTreeEntry *)treeEntry
                 _selectedProductIds: (NSMutableSet *)_selectedProductIds
{
    if(ApplicationListTreeEntryTypeAllProducts == treeEntry.representedType)
    {
        [[AWSQLiteHelper appWageDatabaseQueue] inDatabase: ^(FMDatabase * database) {
            FMResultSet * results = [database executeQuery: @"SELECT DISTINCT applicationId FROM application UNION SELECT DISTINCT appleIdentifier FROM product"];
            while([results next])
            {
                NSNumber * identifier = [NSNumber numberWithInteger: [results intForColumnIndex: 0]];
                [_selectedProductIds addObject: identifier];
            } // End of results loop
        }];

        return;
    }

    // If a product is selected, then we will just add it.
    if(ApplicationListTreeEntryTypeProduct == treeEntry.representedType)
    {
        [_selectedProductIds addObject: treeEntry.representedObject];
    }
    // If an application is selected, we may need to also add the child products.
    else if(ApplicationListTreeEntryTypeApplication == treeEntry.representedType)
    {
        [_selectedProductIds addObject: treeEntry.representedObject];
    } // End of we have a selectedObject

    // Add all of the child applications to the list. We will remove any that are selected in the loop below.
    [treeEntry.children enumerateObjectsUsingBlock:
     ^(AWApplicationListTreeEntry* obj, NSUInteger idx, BOOL * innerStop)
     {
         [self processSelectionForTreeEntry: obj
                        _selectedProductIds: _selectedProductIds];
     }];
}

- (NSSet*) getCurrentlySelectedProductIds
{
    NSIndexSet * selectedRows = [applicationsOutlineView selectedRowIndexes];
    __block NSMutableSet * _selectedProductIds = [NSMutableSet set];

    [selectedRows enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL * stop)
     {
         AWApplicationListTreeEntry * treeEntry = [applicationsOutlineView itemAtRow: index];

         [self processSelectionForTreeEntry: treeEntry
                        _selectedProductIds: _selectedProductIds];
     }];

    return [_selectedProductIds copy];
} // End of outlineViewSelectionDidChange

#pragma mark -
#pragma mark AWIconCollectionProtocol

- (void) receivedIconForApplicationId: (NSNumber *)applicationId
{
    NSLog(@"Got an icon for application with id: %@", applicationId);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSSet * selection = [self preserveApplicationTreeSelection];
        [applicationsOutlineView reloadData];
        [self restoreApplicationTreeSelection: selection];
    });
}

- (void) receivedErrorForApplicationId: (NSNumber*) applicationId
                                 error: (NSError*) error
{
    NSLog(@"Error getting icon for application id: %@", applicationId);
}

#pragma mark -
#pragma mark Misc

- (NSSet*) preserveApplicationTreeSelection
{
    NSMutableSet * selectedItems = [NSMutableSet set];

    @synchronized(applicationsOutlineView)
    {
        [[applicationsOutlineView selectedRowIndexes] enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL * stop)
         {
             AWApplicationListTreeEntry * selectedTreeEntry = [applicationsOutlineView itemAtRow: index];
             [selectedItems addObject: selectedTreeEntry.identifier];
         }];
    }

    return [selectedItems copy];
}

- (void) restoreApplicationTreeSelection: (NSSet*) selectedIdentifiers
{
    // If we had nothing selected, then don't bother doing anything else.
    if(!selectedIdentifiers.count)
    {
        return;
    }
    
    // Enumerate
    NSMutableIndexSet * selectedIndexSets = [NSMutableIndexSet indexSet];
    
    for(NSInteger index = 0; index < applicationsOutlineView.numberOfRows; ++index)
    {
        AWApplicationListTreeEntry * selectedTreeEntry = [applicationsOutlineView itemAtRow: index];

        if([selectedIdentifiers containsObject: selectedTreeEntry.identifier])
        {
            [selectedIndexSets addIndex: index];
        }
    };

    // Get our selectedIndex
    [applicationsOutlineView selectRowIndexes: selectedIndexSets
                         byExtendingSelection: NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
//    NSLog(@"Validate menu item: %@", menuItem.title);

    // Properties is available if we have an entry selected.
    if([@"Preferences" caseInsensitiveCompare: menuItem.title])
    {
        return applicationsOutlineView.selectedRowIndexes.count > 0;
    } // End of properties

    return YES;
}

@end

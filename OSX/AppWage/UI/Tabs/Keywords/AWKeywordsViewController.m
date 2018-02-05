//
//  KeywordsViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import "AWKeywordsViewController.h"
#import "AWApplication.h"
#import "BackgroundView.h"
#import "AWCollectionOperationQueue.h"

@interface AWKeywordsViewController ()
{
    IBOutlet NSProgressIndicator          * keywordLoadingProgressIndicator;
    IBOutlet BackgroundView               * topToolbarView;
    IBOutlet NSTableView                  * keywordTableView;
}
@end

@implementation AWKeywordsViewController
{
    NSSet<NSNumber*>                * currentApplications;
    BOOL                            requiresReload;
}

- (void) awakeFromNib
{
    topToolbarView.image = [NSImage imageNamed: @"Toolbar-Background"];
}

- (void) setIsFocusedTab: (BOOL) isFocusedTab
{
    // If we were not focused, we are now and we require a reload.
    if(!_isFocusedTab && isFocusedTab && requiresReload)
    {
#if todo
        // Start reloading the applications
        [self updateFilters];
        [self reloadRanks];
#endif
        requiresReload = NO;
    } // End of we need to reload the applications.

    _isFocusedTab = isFocusedTab;
} // End of setIsFocusedTab:

- (void) setSelectedApplications: (NSSet*) newApplications
{
    if(nil != newApplications)
    {
        // If our apps have changed then we will deselect the table.
        if(![currentApplications isEqualToSet: newApplications])
        {
            [keywordTableView deselectAll: self];
        }

        currentApplications = newApplications;
    } // End of applications was not nil

    // If we are not focused, then just set a require reload.
    // We will load it once the user focuses.
    if(!_isFocusedTab)
    {
        requiresReload = YES;
        return;
    } // End of we were not focused
#if todo
    // Otherwise, we are the selected tab. Need to reload.
    [self updateFilters];
    [self reloadRanks];
#endif
} // End of setSelectedApplications

- (IBAction) onDownloadKeywordRanks: (id) sender
{
    // Queue our keywordRanks
    [AWCollectionOperationQueue.sharedInstance queueKeywordRankCollectionWithTimeInterval: 0
                                                                          specifiedAppIds: nil];
}

@end

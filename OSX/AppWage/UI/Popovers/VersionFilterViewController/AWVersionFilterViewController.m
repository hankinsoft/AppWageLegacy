//
//  VersionFilterViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWVersionFilterViewController.h"

@interface AWVersionFilterViewController ()<NSTableViewDataSource, NSTableViewDelegate>
@end

@implementation AWVersionFilterViewController
{
    IBOutlet NSTableView        * entriesTableView;
    IBOutlet NSButton           * toggleAllButton;
}

@synthesize didChange, allVersions, selectedVersions;

- (id) init
{
    self = [super initWithNibName: @"AWVersionFilterViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
} // End of init

- (void) setSelectedVersions:(NSArray *) _selectedVersions
{
    selectedVersions = _selectedVersions;
    
    if(nil == selectedVersions || selectedVersions.count == allVersions.count)
    {
        toggleAllButton.state = NSOnState;
        toggleAllButton.allowsMixedState = NO;
    }
    else if(0 == selectedVersions.count)
    {
        toggleAllButton.state            = NSOffState;
        toggleAllButton.allowsMixedState = NO;
    }
    else
    {
        toggleAllButton.allowsMixedState = YES;
        toggleAllButton.state = NSMixedState;
    }
}

- (BOOL) isFiltered
{
    // Nothing selected
    if(nil == selectedVersions)
    {
        return NO;
    }
    
    if(selectedVersions.count == allVersions.count)
    {
        return NO;
    }
    
    return YES;
} // End of isFiltered

#pragma mark -
#pragma mark Actions

- (IBAction) onToggleAll: (id) sender
{
    toggleAllButton.allowsMixedState = NO;

    if(toggleAllButton.state == NSOnState)
    {
        selectedVersions = nil;
    }
    else
    {
        selectedVersions = @[];
    }

    didChange = YES;

    // Reload the table
    dispatch_async(dispatch_get_main_queue(), ^{
        [entriesTableView reloadData];
    });
}

#pragma mark -
#pragma mark NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return allVersions.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * currentEntry = allVersions[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"selected"])
    {
        return [NSNumber numberWithBool: nil == selectedVersions || [selectedVersions containsObject: currentEntry]];
    } // End of RatingSelected
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"title"])
    {
        return currentEntry;
    }

    return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSMutableArray * change = [self.selectedVersions mutableCopy];
    if(nil == self.selectedVersions)
    {
        change = [allVersions mutableCopy];
    } // End of we had no selectedEntries

    NSString * currentEntry = allVersions[row];
    
    if([change containsObject: currentEntry])
    {
        [change removeObject: currentEntry];
    }
    else
    {
        [change addObject: currentEntry];
    }

    // Set our change
    self.selectedVersions = [change copy];
    
    didChange = YES;
}

@end

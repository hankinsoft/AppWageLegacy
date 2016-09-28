//
//  CategoryFilterViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-13.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWCategoryFilterViewController.h"

@implementation CategoryFilterEntry

@end

@interface AWCategoryFilterViewController ()
{
    IBOutlet NSTableView        * entriesTableView;
    IBOutlet NSButton           * toggleAllButton;
}
@end

@implementation AWCategoryFilterViewController

@synthesize allCategories, selectedCategories;

- (id) init
{
    self = [super initWithNibName: @"AWCategoryFilterViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
}

- (BOOL) isFiltered
{
    // Nothing selected
    if(nil == selectedCategories)
    {
        return NO;
    }
    
    if(selectedCategories.count == allCategories.count)
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
        self.selectedCategories = [allCategories copy];
    }
    else
    {
        self.selectedCategories = @[];
    }

    // Reload the table
    dispatch_async(dispatch_get_main_queue(), ^{
        [entriesTableView reloadData];
    });
}

- (void) setSelectedCategories:(NSArray *) _selectedCategories
{
    selectedCategories = _selectedCategories;

    if(nil == selectedCategories || selectedCategories.count == allCategories.count)
    {
        toggleAllButton.state = NSOnState;
        toggleAllButton.allowsMixedState = NO;
    }
    else if(0 == selectedCategories.count)
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

#pragma mark -
#pragma mark NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return allCategories.count;
}

- (id) tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
             row:(NSInteger)row
{
    if(row >= allCategories.count)
    {
        return nil;
    }

    CategoryFilterEntry * entry = allCategories[row];
    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CategoryEnabled"])
    {
        if(nil == selectedCategories)
        {
            return @YES;
        }

        return [NSNumber numberWithBool: [selectedCategories containsObject: entry]];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CategoryName"])
    {
        return NSLocalizedString(entry.categoryName, nil);
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
    
    if(row >= allCategories.count)
    {
        return;
    }

    CategoryFilterEntry * entry = allCategories[row];

    if(nil == selectedCategories)
    {
        selectedCategories = [allCategories copy];
    }

    NSMutableArray * temp = [selectedCategories mutableCopy];
    if([temp containsObject: entry])
    {
        [temp removeObject: entry];
    }
    else
    {
        [temp addObject: entry];
    }

    self.selectedCategories = [temp copy];
} // End of setObjectValue:

@end

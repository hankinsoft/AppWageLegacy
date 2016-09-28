//
//  GenreFilterViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2/20/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWGenreFilterViewController.h"
#import "AWGenre.h"

@interface AWGenreFilterViewController ()<NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView        * entriesTableView;
    IBOutlet NSButton           * toggleAllButton;
}
@end

@implementation AWGenreFilterViewController

@synthesize availableGenres, selectedGeneres;

- (id) init
{
    self = [super initWithNibName: @"AWGenreFilterViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
} // End of init

- (BOOL) isFiltered
{
    // Nothing selected
    if(nil == selectedGeneres)
    {
        return NO;
    }
    
    if(selectedGeneres.count == availableGenres.count)
    {
        return NO;
    }

    return YES;
} // End of isFiltered

- (IBAction) onToggleAll: (id) sender
{
    toggleAllButton.allowsMixedState = NO;

    if(toggleAllButton.state == NSOnState)
    {
        self.selectedGeneres = [NSSet setWithArray: availableGenres];
    }
    else
    {
        self.selectedGeneres = [NSSet set];
    }

    // Reload the table
    dispatch_async(dispatch_get_main_queue(), ^{
        [entriesTableView reloadData];
    });
}

- (void) setSelectedGeneres: (NSSet *) _selectedGeneres
{
    selectedGeneres = _selectedGeneres;

    if(nil == selectedGeneres || selectedGeneres.count == availableGenres.count)
    {
        toggleAllButton.state = NSOnState;
        toggleAllButton.allowsMixedState = NO;
    }
    else if(0 == selectedGeneres.count)
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
    return availableGenres.count;
}

- (id) tableView: (NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
             row: (NSInteger)row
{
    if(row >= availableGenres.count)
    {
        return nil;
    }

    AWGenre * genre = availableGenres[row];
    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"GenreEnabled"])
    {
        if(nil == selectedGeneres)
        {
            return @YES;
        }

        return [NSNumber numberWithBool: [selectedGeneres containsObject: genre]];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"GenreName"])
    {
        return genre.name;
    }

    NSLog(@"Unknown column: %@", tableColumn.identifier);
    return @"";
}

- (void)tableView: (NSTableView *)tableView
   setObjectValue: (id)object
   forTableColumn: (NSTableColumn *)tableColumn
              row: (NSInteger)row
{
    NSLog(@"Want to change column %@.", tableColumn.identifier);

    if(row >= availableGenres.count)
    {
        return;
    }

    AWGenre * genre = availableGenres[row];

    if(nil == selectedGeneres)
    {
        selectedGeneres = [NSSet setWithArray: availableGenres];
    }

    NSMutableSet * temp = [selectedGeneres mutableCopy];
    if([temp containsObject: genre])
    {
        [temp removeObject: genre];
    }
    else
    {
        [temp addObject: genre];
    }

    selectedGeneres = [temp copy];
} // End of setObjectValue:

@end

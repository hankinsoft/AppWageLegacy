//
//  RankFilterViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWRatingFilterViewController.h"

@interface AWRatingFilterViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation AWRatingFilterViewController
{
    IBOutlet NSTableView        * entriesTableView;
    IBOutlet NSButton           * toggleAllButton;
}

@synthesize didChange;

- (id) init
{
    self = [super initWithNibName: @"AWRatingFilterViewController"
                           bundle: nil];

    if (self)
    {
        // Initialization code here.
    }

    return self;
} // End of init

- (BOOL) isFiltered
{
    // If we have five entries then we are not filtered.
    NSUInteger reviewCount = [[AWSystemSettings sharedInstance] ReviewRatingFilter].count;
    if(5 == reviewCount || 0 == reviewCount)
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
        [[AWSystemSettings sharedInstance] setReviewRatingFilter: @[
                                                                  @1, @2, @3, @4, @5
                                                                  ]];
    }
    else
    {
        [[AWSystemSettings sharedInstance] setReviewRatingFilter: @[]];
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
    return 5;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSNumber * currentRating = [NSNumber numberWithInteger: row + 1];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"RatingSelected"])
    {
        return [NSNumber numberWithBool: [[[AWSystemSettings sharedInstance] ReviewRatingFilter] containsObject: currentRating]];
    } // End of RatingSelected
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Rating"])
    {
        return currentRating;
    }

    return @"";
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSMutableArray * change = [[[AWSystemSettings sharedInstance] ReviewRatingFilter] mutableCopy];
    NSNumber * currentRating = [NSNumber numberWithInteger: row + 1];
    
    if([change containsObject: currentRating])
    {
        [change removeObject: currentRating];
    }
    else
    {
        [change addObject: currentRating];
    }

    // Set our change
    [[AWSystemSettings sharedInstance] setReviewRatingFilter: change];

    if(0 == change.count)
    {
        toggleAllButton.allowsMixedState = NO;
        toggleAllButton.state            = NSOffState;
    }
    else if(5 == change.count)
    {
        toggleAllButton.allowsMixedState = NO;
        toggleAllButton.state            = NSOnState;
    }
    else
    {
        toggleAllButton.allowsMixedState = YES;
        toggleAllButton.state            = NSMixedState;
    }

    didChange = YES;
}

@end

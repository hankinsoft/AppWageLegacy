//
//  ApplicationReviewsViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationReviewsViewController.h"
#import "AWApplication.h"
#import "AWApplicationImageHelper.h"
#import "AWCollectionOperationQueue.h"

#import "BackgroundView.h"

#import "AWRankCountryFilterPopoverViewController.h"
#import "AWRatingFilterViewController.h"
#import "AWVersionFilterViewController.h"

#import "MSTranslateAccessTokenRequester.h"
#import "MSTranslateVendor.h"

#import "ImageAndTextCell.h"
#import "AWFilterTableHeaderView.h"
#import "AWFilterTableHeaderCell.h"
#import "AWCountry.h"

@interface CountryLookup : NSObject

@property(nonatomic,copy) NSString * countryCode;
@property(nonatomic,copy) NSString * countryName;
@property(nonatomic,copy) NSNumber * countryId;

@end

@implementation CountryLookup

@end

@implementation ReviewTableDTO

@synthesize reviewId, stars, title, content, reviewer, readByUser, appVersion, lastUpdated;
@synthesize translatedByUser, translatedContent, translatedTitle, translatedLocal;

@synthesize applicationId, applicationName, countryName, countryCode;

@end

@interface AWApplicationReviewsViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSPopoverDelegate, AWFilterTableHeaderViewDelegate>
{
    BOOL                                      requiresReload;
    dispatch_semaphore_t                      reviewLoadSemaphore;

    IBOutlet BackgroundView                   * topToolbarView;

    NSSet                                     * currentlySelectedApplications;
    NSArray                                   * internalReviews;

    NSInteger                                 unreadReviewCount;

    IBOutlet NSTableView                      * reviewTableView;
    IBOutlet NSTextView                       * reviewContentTextView;
    IBOutlet NSTextField                      * reviewCountLabel;
    IBOutlet NSTextField                      * reviewTitleTextField;
    IBOutlet NSSegmentedControl               * reviewTranslateSegmentedControl;
    IBOutlet NSProgressIndicator              * reviewTranslateProgressIndicator;

    // Searching
    IBOutlet NSSearchField                    * reviewSearchField;
    NSTimer                                   * reviewSearchTimer;

    NSArray                                   * selectedVersions;

    // Rank Country Filter
    NSPopover                                 * countryPopover;
    NSArray                                   * filteredCountriesBeforePopover;

    AWRankCountryFilterPopoverViewController  * rankCountryFilterViewController;
    AWRatingFilterViewController              * ratingFilterViewController;
    AWVersionFilterViewController             * versionFilterViewController;

    // Header cells
    AWFilterTableHeaderCell                   * countryHeaderCell;
    AWFilterTableHeaderCell                   * ratingTableHeaderCell;
    AWFilterTableHeaderCell                   * versionTableHeaderCell;
}
@end

@implementation AWApplicationReviewsViewController

@synthesize isFocusedTab = _isFocusedTab;

static NSDateFormatter * reviewTableDateFormatter;

+ (void) initialize
{
    reviewTableDateFormatter = [AWDateHelper dateTimeFormatter];
    [reviewTableDateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
}

- (id) init
{
    self = [super initWithNibName: @"AWApplicationReviewsViewController" bundle: nil];
    if(self)
    {
        reviewLoadSemaphore  = dispatch_semaphore_create(1);
        requiresReload  = YES;
    }

    return self;
}

- (void) setIsFocusedTab: (BOOL) isFocusedTab
{
    // If we were not focused, we are now and we require a reload.
    if(!_isFocusedTab && isFocusedTab && requiresReload)
    {
        // Start reloading the applications
        [self reloadReviewsAndUpdateSelection: YES];
        requiresReload = NO;
    } // End of we need to reload the applications.

    _isFocusedTab = isFocusedTab;
}

- (void) setSelectedApplications: (NSSet*) newApplications
{
    if(nil != newApplications)
    {
        // If our selected application did change, then we will clear the selected versions
        if(![currentlySelectedApplications isEqualToSet: newApplications])
        {
            // Versions are not filtered if the applications changed.
            versionTableHeaderCell.isFiltered = NO;
            selectedVersions = nil;

            // Update our header view
            [reviewTableView.headerView setNeedsDisplay: YES];

            // Make sure the translate buttons are disabled
            [reviewTranslateProgressIndicator stopAnimation: self];
            [reviewTranslateSegmentedControl setSelected: NO
                                              forSegment: 0];
        }

        currentlySelectedApplications = newApplications;
    } // End of applications was not nil

    // If we are not focused, then just set a require reload.
    // We will load it once the user focuses.
    if(!_isFocusedTab)
    {
        requiresReload = YES;
        return;
    } // End of we were not focused

    // Otherwise, we are the selected tab. Need to reload.
    [self reloadReviewsAndUpdateSelection: YES];
} // End of setSelectedApplications

- (void) reloadReviewsAndUpdateSelection: (BOOL) updateSelection
{
    if(0 != dispatch_semaphore_wait(reviewLoadSemaphore, DISPATCH_TIME_NOW))
    {
        // Already locked. Exit.
        return;
    }

    // Set while in main thread
    NSString * reviewSearchString = reviewSearchField.stringValue;

    // Grab our sort descriptors while still in the main thread
    NSArray<NSSortDescriptor*>* sortDescriptors = reviewTableView.sortDescriptors.copy;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSMutableDictionary * applicationLookup = [NSMutableDictionary dictionary];

        NSArray * allApplications = [AWApplication allApplications];
        [allApplications enumerateObjectsUsingBlock:
         ^(AWApplication * application, NSUInteger index, BOOL * stop) {
            [applicationLookup setObject: application.name
                                  forKey: application.applicationId];
        }];

        NSMutableString * reviewClause = [NSMutableString stringWithFormat: @" 1=1 "];

        NSArray * countryCodes = [[NSUserDefaults standardUserDefaults] objectForKey: kReviewFilterCountryUserDefault];

        NSArray * allCountries = [AWCountry allCountries];
        
        NSMutableDictionary<NSNumber*,CountryLookup*> * countryLookup = [NSMutableDictionary dictionary];

        NSMutableArray<NSNumber*> * countryIdFilters = [NSMutableArray array];
        for(AWCountry * country in allCountries)
        {
            CountryLookup * entry = [[CountryLookup alloc] init];
            entry.countryId = country.countryId;
            entry.countryName = country.name;
            entry.countryCode = country.countryCode;
            
            [countryLookup setObject: entry
                              forKey: country.countryId];

            for(NSString * countryCode in countryCodes)
            {
                if(NSOrderedSame == [countryCode caseInsensitiveCompare: country.countryCode])
                {
                    [countryIdFilters addObject: country.countryId];
                }
            } // End of countryCodes lookup
        }

        if(0 != countryIdFilters.count)
        {
            [reviewClause appendFormat: @" AND countryId IN (%@)", [countryIdFilters componentsJoinedByString: @","]];
        } // End of countryIdFilters is not empty

        // If no applications are selected, then we want them all!
        NSSet * applicationsWeCareAbout = currentlySelectedApplications;

        // If we have apps specified
        if(0 != applicationsWeCareAbout.count)
        {
            [reviewClause appendFormat: @" AND applicationId IN (%@)",
             [applicationsWeCareAbout.allObjects componentsJoinedByString: @","]];
        }

        NSUInteger reviewFilterCount = [[AWSystemSettings sharedInstance] ReviewRatingFilter].count;
        if(5 != reviewFilterCount && 0 != reviewFilterCount)
        {
            [reviewClause appendFormat: @" AND stars IN (%@)", [[[AWSystemSettings sharedInstance] ReviewRatingFilter] componentsJoinedByString: @","]];
        }

        // If there is no search string, then just look at the list of apps
        if(0 != reviewSearchString.length)
        {
            NSString * escapedSearch =
                [reviewSearchString stringByReplacingOccurrencesOfString: @"'"
                                                              withString: @"\\'"];
            NSString * searchString =
                [NSString stringWithFormat: @"%%%@%%", escapedSearch];

            // Append to our review clause
            [reviewClause appendFormat: @" AND (content LIKE '%@' OR title LIKE '%@' OR reviewer LIKE '%@')",
             searchString, searchString, searchString];
        } // End of we had a search string.

        // If we have selected versions, then we need to add them in.
        if(nil != selectedVersions)
        {
            if(0 != selectedVersions.count)
            {
                [reviewClause appendFormat: @" AND appVersion IN ('%@')", [selectedVersions componentsJoinedByString: @"','"]];
            }
        } // End of we have selectedVersions

        // Replace our clause
        [reviewClause replaceOccurrencesOfString: @"1=1 AND"
                                      withString: @""
                                         options: 0
                                           range: NSMakeRange(0, reviewClause.length)];

       [reviewClause replaceOccurrencesOfString: @"1=1  AND"
                                     withString: @""
                                        options: 0
                                          range: NSMakeRange(0, reviewClause.length)];

        NSString * reviewQueryString = [NSString stringWithFormat: @"SELECT * FROM review WHERE %@ ORDER BY lastUpdated DESC", reviewClause];

        NSMutableArray * _reviewsTemp = [NSMutableArray array];
        [[AWSQLiteHelper reviewDatabaseQueue] inDatabase:^(FMDatabase * database) {
            FMResultSet * results = [database executeQuery: reviewQueryString];
            while([results next])
            {
                ReviewTableDTO * reviewTableDTO = [ReviewTableDTO new];

                reviewTableDTO.reviewId          = [NSNumber numberWithInt: [results intForColumn: @"reviewId"]];

                reviewTableDTO.stars            = [NSNumber numberWithInt: [results intForColumn: @"stars"]];
                reviewTableDTO.title            = [results stringForColumn: @"title"];
                reviewTableDTO.content          = [results stringForColumn: @"content"];
                reviewTableDTO.reviewer         = [results stringForColumn: @"reviewer"];
                reviewTableDTO.lastUpdated      = [NSDate dateWithTimeIntervalSince1970: [results intForColumn: @"lastUpdated"]];

                reviewTableDTO.readByUser       = [NSNumber numberWithInt: [results intForColumn: @"readByUser"]];

                reviewTableDTO.translatedByUser = [NSNumber numberWithInt: [results intForColumn: @"translatedByUser"]];
                reviewTableDTO.translatedContent= [results stringForColumn: @"translatedContent"];
                reviewTableDTO.translatedTitle  = [results stringForColumn: @"translatedTitle"];
                reviewTableDTO.translatedLocal  = [results stringForColumn: @"translatedLocal"];
                reviewTableDTO.appVersion       = [results stringForColumn: @"appVersion"];

                reviewTableDTO.applicationId    = [NSNumber numberWithInt: [results intForColumn: @"applicationId"]];
                reviewTableDTO.applicationName  =  applicationLookup[reviewTableDTO.applicationId];

                NSNumber * countryId = [NSNumber numberWithInt: [results intForColumn: @"countryId"]];
                reviewTableDTO.countryName      = countryLookup[countryId].countryName;
                reviewTableDTO.countryCode      = countryLookup[countryId].countryCode;

                [_reviewsTemp addObject: reviewTableDTO];
            } // End of while loop
        }];

        // Fix for data race.. only access reviews on main thread. This could be handled better
        // but AppWage is mainly in maintenance at the moment.
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Set our internal reviews
            internalReviews = [_reviewsTemp copy];
        });

        // If we did not have specific versions, then we will set our all versions entry.
        // If we set this on selected versions, then everytime the user changed the filter, our
        // entreies would get smaller and smaller.
        if(nil == selectedVersions)
        {
            versionFilterViewController.allVersions      = [[internalReviews valueForKeyPath: @"@distinctUnionOfObjects.appVersion"] sortedArrayUsingComparator:^NSComparisonResult(NSString * version1, NSString * version2)
                                                            {
                                                                return [version1 compare: version2 options: NSNumericSearch];
                                                            }];
        } // End of we did not have selected versions

        [self updateSorting: sortDescriptors];

        NSLog(@"We have %ld reviews. UpdateSelection: %@.",
              internalReviews.count,
              updateSelection ? @"Yes" : @"No");

        dispatch_async(dispatch_get_main_queue(), ^{
            if(updateSelection)
            {
                [reviewTableView deselectAll: nil];
                [reviewTranslateSegmentedControl setEnabled: NO];
                [self updateDefaultText];

                [reviewTableView scrollToBeginningOfDocument: nil];
            }

            [reviewTableView reloadData];

            NSIndexSet *range0Indexes = [internalReviews indexesOfObjectsPassingTest: ^BOOL(id review, NSUInteger idx, BOOL *stop) {
                return false == [[review readByUser] boolValue];
            }];

            unreadReviewCount = range0Indexes.count;
            [self updateReviewCountLabel];
            
            NSLog(@"ApplicationReviewsViewContoller - Finished updating.");
            dispatch_semaphore_signal(reviewLoadSemaphore);
        }); // End of dispatch_main
    }); // End of dispatch global
}

- (void) awakeFromNib
{
    [reviewTableView setAutosaveName: @"ReviewTableView"];
    [reviewTableView setAutosaveTableColumns: YES];

    topToolbarView.image = [NSImage imageNamed: @"Toolbar-Background"];

    currentlySelectedApplications = [NSSet set];

    [self updateDefaultText];

    // Watch for review changes.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(newReviews:)
                                                 name: [AWCollectionOperationQueue newReviewsNotificationName]
                                               object: nil];

    // Apply our header filters
    [self applyHeaderFilters];

    if(0 == reviewTableView.sortDescriptors.count)
    {
        [reviewTableView setSortDescriptors: @[
                                               [NSSortDescriptor sortDescriptorWithKey: @"Reviewed"
                                                                             ascending: NO]
                                               ]];
    }
}

- (void) applyHeaderFilters
{
    AWFilterTableHeaderView * headerView = [[AWFilterTableHeaderView alloc] init];
    headerView.delegate = self;
    [reviewTableView setHeaderView: headerView];
    
    // Country has a custom icon and image view
    NSTableColumn * countryTableColumn = [reviewTableView tableColumnWithIdentifier: @"Country"];
    ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
    [imageAndTextCell setEditable: NO];
    [countryTableColumn setDataCell: imageAndTextCell];

    countryHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    [countryHeaderCell setEditable: NO];
    countryHeaderCell.stringValue = [countryTableColumn.headerCell stringValue];
    [countryTableColumn setHeaderCell: countryHeaderCell];

    // Custom filter for our rank column
    NSTableColumn * ratingTableColumn = [reviewTableView tableColumnWithIdentifier: @"Rank"];
    ratingTableHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    [ratingTableHeaderCell setEditable: NO];
    ratingTableHeaderCell.stringValue = [ratingTableColumn.headerCell stringValue];
    [ratingTableColumn setHeaderCell: ratingTableHeaderCell];

    NSTableColumn * versionTableColumn = [reviewTableView tableColumnWithIdentifier: @"AppVersion"];
    versionTableHeaderCell = [[AWFilterTableHeaderCell alloc] init];
    versionTableHeaderCell.stringValue = [versionTableColumn.headerCell stringValue];
    versionTableColumn.headerCell = versionTableHeaderCell;


    rankCountryFilterViewController = [[AWRankCountryFilterPopoverViewController alloc] init];
    rankCountryFilterViewController.countryKey = kReviewFilterCountryUserDefault;
    [rankCountryFilterViewController loadView];

    countryHeaderCell.isFiltered = rankCountryFilterViewController.isFiltered;

    ratingFilterViewController = [[AWRatingFilterViewController alloc] init];
    ratingTableHeaderCell.isFiltered = ratingFilterViewController.isFiltered;

    // Our version filter
    versionFilterViewController = [[AWVersionFilterViewController alloc] init];
}

- (void) newReviews: (NSNotification*) aNotification
{
    if(_isFocusedTab)
    {
        NSLog(@"Has new reviews and is focused. Want to reload.");
        [self reloadReviewsAndUpdateSelection: NO];
        requiresReload = NO;
    }
    else
    {
        NSLog(@"Has new reviews but is not focused. Not reloading.");
        requiresReload = YES;
    }
}

- (void) updateReviewCountLabel
{
    [reviewCountLabel setStringValue: [NSString stringWithFormat: @"%ld reviews, %ld unread.",
                                       internalReviews.count, unreadReviewCount]];
}

- (void) updateDefaultText
{
    [reviewTitleTextField setStringValue: NSLocalizedString(@"Select a review to see its details.", nil)];
    [reviewContentTextView setString: @""];
}

- (void) searchReviews
{
    // If the user is searching, then this should be the focused tab. Just go ahead and reload.
    [self reloadReviewsAndUpdateSelection: YES];
} // End of searchReviews

#pragma mark -
#pragma mark Actions

- (IBAction) onSearchReview: (id) sender
{
    [reviewSearchTimer invalidate];
    reviewSearchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                         target: self
                                                       selector: @selector(searchReviews)
                                                       userInfo: nil
                                                        repeats: NO];
} // End of onSearchReview

- (IBAction) onDownloadReviews: (id) sender
{
    // Load our reviews.
    [AWCollectionOperationQueue.sharedInstance queueReviewCollectionWithTimeInterval: 0
                                                                   specifiedAppIds: nil];
}

- (IBAction) markAllCurrentReviewsAsRead: (id) sender
{
    unreadReviewCount = 0;

    [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:^(FMDatabase * database, BOOL *rollback) {
        NSString * updateReviewQuery = [NSString stringWithFormat: @"UPDATE review SET readByUser = 1 WHERE reviewId IN (%@)", [[internalReviews valueForKeyPath: @"reviewId"] componentsJoinedByString: @","]];

        [database executeUpdate: updateReviewQuery];
    }];

    [self reloadReviewsAndUpdateSelection: NO];
} // End of markAllCurrentReviewsAsRead

- (IBAction) onTranslateReview: (id)sender
{
    if(-1 == reviewTableView.selectedRow)
    {
        [self updateDefaultText];
        [reviewTranslateSegmentedControl setEnabled: NO];
        return;
    }

    if(reviewTableView.selectedRow > internalReviews.count)
    {
        [reviewTableView deselectAll: nil];
        [reviewTranslateSegmentedControl setEnabled: NO];
        return;
    }

    // Get our review
    ReviewTableDTO * reviewDTO = internalReviews[reviewTableView.selectedRow];

    // If we are already translated
    if(reviewDTO.translatedByUser.boolValue)
    {
        // Turn off the translation.
        reviewDTO.translatedByUser = [NSNumber numberWithBool: NO];

        dispatch_async(dispatch_get_main_queue(), ^{
            [reviewTranslateSegmentedControl setSelected: NO forSegment: 0];
        });
    } // End of we are already translated
    else
    {
        reviewDTO.translatedByUser = [NSNumber numberWithBool: YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            [reviewTranslateSegmentedControl setSelected: YES
                                              forSegment: 0];
        });
    }

    [[AWSQLiteHelper reviewDatabaseQueue] inDatabase: ^(FMDatabase * database) {
        NSString * updateQuery = [NSString stringWithFormat: @"UPDATE review SET translatedByUser = %hhd WHERE reviewId = %ld",
          reviewDTO.translatedByUser.boolValue,
          reviewDTO.reviewId.unsignedIntegerValue];

        [database executeUpdate: updateQuery];
    }];

    // Refresh the details
    [self handleTableSelectionChanged];
} // End of onTranslateReview

#pragma mark -
#pragma mark NSTableView

- (void)tableView: (NSTableView *)tableView
sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    // Update our sorting
    [self updateSorting: reviewTableView.sortDescriptors.copy];

    // Reload our table
    [tableView reloadData];
}

- (void) updateSorting: (NSArray<NSSortDescriptor*>*) sortDescriptors
{
    if(nil == sortDescriptors || 0 == sortDescriptors.count)
    {
        return;
    } // End of unsorted
    
    // Get our first sort descriptor
    NSSortDescriptor * sortDescriptor = sortDescriptors[0];
    //    NSInteger index = sortDescriptor.key.integerValue;

    // Sort our array
    internalReviews = [internalReviews sortedArrayUsingComparator:^NSComparisonResult(ReviewTableDTO * obj1, ReviewTableDTO * obj2)
                     {
                         if([@"Country" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.countryName compare: obj2.countryName];
                         }
                         else if([@"Version" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.appVersion compare: obj2.appVersion options: NSNumericSearch];
                         }
                         else if([@"Title" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.title compare: obj2.title];
                         }
                         else if([@"Reviewer" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.reviewer compare: obj2.reviewer];
                         }
                         else if([@"Rank" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.stars compare: obj2.stars];
                         }
                         else if([@"Unread" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.readByUser compare: obj2.readByUser];
                         }
                         else if([@"Reviewed" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.lastUpdated compare: obj2.lastUpdated];
                         }
                         else if([@"Application" isEqualToString: sortDescriptor.key])
                         {
                             return [obj1.applicationName compare: obj2.applicationName];
                         }
                         else
                         {
                             NSAssert(true, @"Unknown key for sort descriptor: %@", sortDescriptor.key);
                         }

                         return [obj1.description compare: obj2.description];
                     }];

    // Reverse it.
    if(!sortDescriptor.ascending)
    {
        internalReviews = [internalReviews reversedArray];
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return internalReviews.count;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row >= internalReviews.count)
    {
        return nil;
    }

    ReviewTableDTO * reviewDTO = internalReviews[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Rank"])
    {
        return reviewDTO.stars;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Unread"])
    {
        if(reviewDTO.readByUser.boolValue)
        {
            return nil;
        }

        return [NSImage imageNamed: @"Unread"];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Reviewer"])
    {
        return reviewDTO.reviewer;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"AppVersion"])
    {
        return reviewDTO.appVersion;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Title"])
    {
        if(reviewDTO.translatedByUser.boolValue && reviewDTO.translatedTitle.length > 0)
        {
            return reviewDTO.translatedTitle;
        }

        return reviewDTO.title;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Application"])
    {
        NSImage * appImage = [AWApplicationImageHelper imageForApplicationId: reviewDTO.applicationId];
        return appImage;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return reviewDTO.countryName;
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Reviewed"])
    {
        return [reviewTableDateFormatter stringFromDate: reviewDTO.lastUpdated];
    }
    else
    {
        NSLog(@"Unknown identifier: %@", tableColumn.identifier);
    }

    return nil;
}

- (void)tableView: (NSTableView *)tableView
  willDisplayCell: (id)cell
   forTableColumn: (NSTableColumn *)tableColumn
              row: (NSInteger)row
{
    if(row >= internalReviews.count)
    {
        return;
    }
    
    ReviewTableDTO * reviewDTO = internalReviews[row];

    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        [(ImageAndTextCell*)cell setImage: [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [reviewDTO.countryCode lowercaseString]]]];
    }
}

- (NSString *)tableView:(NSTableView *)aTableView
         toolTipForCell:(NSCell *)aCell
                   rect:(NSRectPointer)rect
            tableColumn:(NSTableColumn *)aTableColumn
                    row:(NSInteger)row
          mouseLocation:(NSPoint)mouseLocation
{
    ReviewTableDTO * reviewDTO = internalReviews[row];
    if(NSOrderedSame == [aTableColumn.identifier caseInsensitiveCompare: @"Application"])
    {
        return reviewDTO.applicationName;
    }
    else if(NSOrderedSame == [aTableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return reviewDTO.countryName;
    }
    else
    {
        id result = [self tableView: aTableView objectValueForTableColumn: aTableColumn row:row];
        if([result isKindOfClass: [NSString class]])
        {
            return result;
        }
        else if([result isKindOfClass: [NSNumber class]])
        {
            return [result stringValue];
        }
        else
        {
            return @"";
        }
    } // End of unhandled
}

- (void) tableViewSelectionDidChange: (NSNotification *)notification
{
    [self handleTableSelectionChanged];
}

- (void) handleTableSelectionChanged
{
    if(-1 == reviewTableView.selectedRow)
    {
        [self updateDefaultText];
        [reviewTranslateSegmentedControl setEnabled: NO];
        return;
    }
    
    if(reviewTableView.selectedRow > internalReviews.count)
    {
        [reviewTableView deselectAll: nil];
        [reviewTranslateSegmentedControl setEnabled: NO];
        return;
    }
    
    // Get our review
    ReviewTableDTO * reviewDTO = internalReviews[reviewTableView.selectedRow];
    [reviewTranslateSegmentedControl setEnabled: YES];
    
    if(!reviewDTO.readByUser.boolValue)
    {
        reviewDTO.readByUser = @YES;
        
        [[AWSQLiteHelper reviewDatabaseQueue] inDatabase: ^(FMDatabase * database) {
            NSString * updateQuery = [NSString stringWithFormat: @"UPDATE review SET readByUser = 1 WHERE reviewId = %ld",
                                      reviewDTO.reviewId.unsignedIntegerValue];
            
            [database executeUpdate: updateQuery];
        }];
        
        // Lower our reviewcount
        --unreadReviewCount;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(reviewDTO.translatedByUser.boolValue)
        {
            [reviewTranslateSegmentedControl setSelected: YES
                                              forSegment: 0];
            
            // We don't actually have the translation. Need to get it.
            if(nil == reviewDTO.translatedTitle ||
               nil == reviewDTO.translatedContent ||
               // Our translation is not the same as the system specifies
               NSOrderedSame != [reviewDTO.translatedLocal caseInsensitiveCompare: [[AWSystemSettings sharedInstance] reviewTranslations]])
            {
                // Make sure the spinner is not going.
                [reviewTranslateProgressIndicator startAnimation: self];
                
                // Default to be the un-translated review. Attempt to load the review.
                [reviewTitleTextField setStringValue: reviewDTO.title];
                [reviewContentTextView setString: reviewDTO.content];
                
                // Translate our review
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self translateReview: reviewDTO];
                });
            } // End of not translated
            else
            {
                [reviewTranslateProgressIndicator stopAnimation: self];
                [reviewTitleTextField setStringValue: reviewDTO.translatedTitle];
                [reviewContentTextView setString: reviewDTO.translatedContent];
            } // End of already translated.
        }
        else
        {
            [reviewTranslateSegmentedControl setSelected: NO
                                              forSegment: 0];
            [reviewTranslateProgressIndicator stopAnimation: self];
            
            [reviewTitleTextField setStringValue: reviewDTO.title];
            [reviewContentTextView setString: reviewDTO.content];
        } // End of not translated
        
        [self updateReviewCountLabel];
        
        // Reload the cell as well.
        [reviewTableView reloadDataForRowIndexes: [NSIndexSet indexSetWithIndex: reviewTableView.selectedRow]
                                   columnIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, 5)]];
    });
}

#pragma mark -
#pragma mark Translation

- (void) translateReview: (ReviewTableDTO*) reviewDTO
{
    MSTranslateVendor *vendor = [[MSTranslateVendor alloc] init];

    NSString * detectString = reviewDTO.content;
    if(nil == detectString || reviewDTO.title.length > detectString.length)
    {
        detectString = reviewDTO.title;
    }

    if(nil == detectString)
    {
        return;
    }

    NSString * content = nil == reviewDTO.content ? @"" : reviewDTO.content;
    NSString * title   = nil == reviewDTO.title   ? @"" : reviewDTO.title;

    NSArray * translateArray = @[content, title];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"Want to translate (on %@ thread): %@.",
              [NSThread isMainThread] ? @"MAIN" : @"BACKGROUND",
              translateArray);

        [vendor requestTranslateArray: translateArray
                               to: [[AWSystemSettings sharedInstance] reviewTranslations]
                 blockWithSuccess: ^(NSArray * translatedTextArray)
        {
            NSAssert1(2 == translateArray.count, @"Translated array is not the proper length. Received %ld results.", translateArray.count);
            NSLog(@"Translated (%ld): %@",
                  translatedTextArray.count,
                  translatedTextArray);

            reviewDTO.translatedContent = translatedTextArray[0];
            reviewDTO.translatedTitle   = translatedTextArray[1];
            reviewDTO.translatedLocal = [[AWSystemSettings sharedInstance] reviewTranslations];

            [[AWSQLiteHelper reviewDatabaseQueue] inDatabase: ^(FMDatabase * reviewDatabase) {
                NSString * updateQuery = [NSString stringWithFormat: @"UPDATE review SET translatedContent = ?, translatedTitle = ?, translatedLocal = ? WHERE reviewId = ?"];

                [reviewDatabase executeUpdate: updateQuery
                         withArgumentsInArray: @[
                                                 reviewDTO.translatedContent,
                                                 reviewDTO.translatedTitle,
                                                 reviewDTO.translatedLocal,
                                                 reviewDTO.reviewId]];
            }];

            [self handleTableSelectionChanged];

            dispatch_async(dispatch_get_main_queue(), ^{
                [reviewTableView reloadData];
            });
        } failure: ^(NSError* error) {
            if([error isKindOfClass: [NSError class]])
            {
                NSLog(@"Translate failed: %@", error.localizedDescription);
            }
            else
            {
                NSLog(@"Translate failed. Error is not an error: %@", error);
            }

            // Update the user state
            reviewDTO.translatedByUser = @NO;
            [[AWSQLiteHelper reviewDatabaseQueue] inTransaction:
             ^(FMDatabase * database, BOOL *rollback) {
                NSString * updateQuery =
                    [NSString stringWithFormat: @"UPDATE review SET translatedByUser = 0 WHERE reviewId = %ld",
                                          reviewDTO.reviewId.unsignedIntegerValue];

                [database executeUpdate: updateQuery];
            }];

            [self handleTableSelectionChanged];
        }];
    });
}

#pragma mark -
#pragma mark NSPopover

- (void)popoverDidClose:(NSNotification *)notification
{
    NSPopover * popover = notification.object;

    // If it was the country popover
    if(popover.contentViewController == rankCountryFilterViewController)
    {
        // Set our is filtered value
        countryHeaderCell.isFiltered = rankCountryFilterViewController.isFiltered;

        // We need to check if we changed anything
        NSArray * newCountryCodes = [[[NSUserDefaults standardUserDefaults] objectForKey: kRankGraphCountryFilterUserDefault] copy];
        
        NSSet * compareSet1 = [NSSet setWithArray: newCountryCodes];
        NSSet * compareSet2 = [NSSet setWithArray: filteredCountriesBeforePopover];

        // If things have changed, then we need to reload.
        if(![compareSet1 isEqualToSet: compareSet2])
        {
            // Countries have changed. Need to reload.
            [self reloadReviewsAndUpdateSelection: YES];
        } // End of our countries have changed
    } // End of it was the countryPopover that changed
    else if(popover.contentViewController == ratingFilterViewController)
    {
        // Set our rating icon
        ratingTableHeaderCell.isFiltered = ratingFilterViewController.isFiltered;

        // Need to reload
        if(ratingFilterViewController.didChange)
        {
            [self reloadReviewsAndUpdateSelection: YES];
        }
    }
    else if(popover.contentViewController == versionFilterViewController)
    {
        // Set our rating icon
        versionTableHeaderCell.isFiltered = versionFilterViewController.isFiltered;
        if(versionFilterViewController.isFiltered)
        {
            selectedVersions = [versionFilterViewController.selectedVersions copy];
        }
        else
        {
            selectedVersions = nil;
        }

        // Need to reload
        if(versionFilterViewController.didChange)
        {
            [self reloadReviewsAndUpdateSelection: YES];
        }
    }

    // Update our header view
    [reviewTableView.headerView setNeedsDisplay: YES];
}

#pragma mark -
#pragma mark FilterTableHeaderViewDelegate

- (void) filterTableHeaderView: (AWFilterTableHeaderView*) headerView
  clickedFilterButtonForColumn: (NSTableColumn*) column
                    filterRect: (NSRect) filterRect
{
    if(nil != countryPopover)
    {
        if([countryPopover isShown])
        {
            [countryPopover close];
            return;
        }
    }

    countryPopover = [[NSPopover alloc] init];
    countryPopover.delegate = self;
    [countryPopover setBehavior: NSPopoverBehaviorSemitransient];
    [countryPopover setContentViewController: nil];

    if(NSOrderedSame == [@"Rank" caseInsensitiveCompare: column.identifier])
    {
        ratingFilterViewController = [[AWRatingFilterViewController alloc] init];

//        rankCountryFilterViewController.countryKey = kReviewFilterCountryUserDefault;
        [countryPopover setContentViewController: ratingFilterViewController];
        ratingFilterViewController.didChange = NO;
    } // End of rank filter
    else if(NSOrderedSame == [@"Country" caseInsensitiveCompare: column.identifier])
    {
        [countryPopover setContentViewController: rankCountryFilterViewController];
        rankCountryFilterViewController.didChange = NO;
    }
    else if(NSOrderedSame == [@"AppVersion" caseInsensitiveCompare: column.identifier])
    {
        [countryPopover setContentViewController: versionFilterViewController];
        versionFilterViewController.didChange = NO;

        versionFilterViewController.selectedVersions = selectedVersions;
    }
    else
    {
        NSLog(@"Unknow filter clicked: %@", column.identifier);
    }

    // If we have a content view controller, then display it.
    if(nil != countryPopover.contentViewController)
    {
        [countryPopover showRelativeToRect: filterRect
                                    ofView: headerView
                             preferredEdge: NSMaxYEdge];
    }
} // End of filterTableHeaderView:clickedFilterButtonForColumn;

@end

//
//  RankCountryFilterPopoverViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/12/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWRankCountryFilterPopoverViewController.h"
#import "AWCountry.h"

@interface AWRankCountryFilterPopoverViewController ()
{
    IBOutlet NSTableView        * countryFilterTableView;
    IBOutlet NSButton           * toggleAllCountriesCheckbox;

    // Searching
    IBOutlet NSSearchField      * countrySearchField;
}
@end

@implementation AWRankCountryFilterPopoverViewController
{
    NSArray                     * allCountries;
    NSArray                     * countries;

    NSString                    * lastSearch;
    NSTimer                     * searchTimer;
}

@synthesize didChange, countryKey;

- (id) init
{
    self = [super initWithNibName: @"AWRankCountryFilterPopoverViewController"
                           bundle: nil];

    if(self)
    {
        
    } // End of self
    
    return self;
} // End of init

- (void) awakeFromNib
{
    [super awakeFromNib];

    didChange = NO;

    @autoreleasepool {
        NSMutableArray * temp = [NSMutableArray array];
        NSArray * tempCountries = [AWCountry allCountries];

        [tempCountries enumerateObjectsUsingBlock:
         ^(AWCountry * country, NSUInteger index, BOOL * stop)
         {
             [temp addObject: @{
                                @"name": country.name,
                                @"countryCode": country.countryCode
                                }];
         }];

        allCountries    = [temp copy];
    } // End of @autoreleasepool

    countries = allCountries;

    [self updateCountryToggle];
}

- (IBAction) onSearchCountries: (id) sender
{
    [searchTimer invalidate];
    searchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.10
                                                   target: self
                                                 selector: @selector(actualSearch:)
                                                 userInfo: nil
                                                  repeats: NO];
}

- (void) actualSearch:(id)sender
{
    if([lastSearch isEqualToString: countrySearchField.stringValue])
    {
        return;
    }

    lastSearch = countrySearchField.stringValue;

    NSLog(@"Want to search for: %@", countrySearchField.stringValue);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(0 == lastSearch.length)
        {
            countries = allCountries;
        }
        else
        {
            // Append wildcard to our search for.
            NSString * searchFor = [NSString stringWithFormat: @"%@*", lastSearch];
            NSPredicate * searchPredicate = [NSPredicate predicateWithFormat: @"name LIKE[cd] %@", searchFor];

            NSLog(@"Country search predicate: %@", searchPredicate.predicateFormat);
            countries = [allCountries filteredArrayUsingPredicate: searchPredicate];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [countryFilterTableView reloadData];
        });
    });
}

- (void) updateCountryToggle
{
    NSArray * selectedCountryCodes = [[NSUserDefaults standardUserDefaults] objectForKey: countryKey];

    if(0 == selectedCountryCodes.count)
    {
        toggleAllCountriesCheckbox.allowsMixedState = NO;
        toggleAllCountriesCheckbox.state = NSOffState;
    }
    else if(selectedCountryCodes.count == countries.count)
    {
        toggleAllCountriesCheckbox.allowsMixedState = NO;
        toggleAllCountriesCheckbox.state = NSOnState;
    }
    else
    {
        toggleAllCountriesCheckbox.allowsMixedState = YES;
        toggleAllCountriesCheckbox.state = NSMixedState;
    }
}

- (IBAction) toggleAllCountries: (id) sender
{
    if(sender == toggleAllCountriesCheckbox)
    {
        didChange = YES;

        __block NSMutableArray * newCountryCodes = [NSMutableArray array];
        
        if(toggleAllCountriesCheckbox.state == NSOnState)
        {
            [countries enumerateObjectsUsingBlock: ^(NSDictionary * country, NSUInteger countryIndex, BOOL * stop)
             {
                 [newCountryCodes addObject: country[@"countryCode"]];
             }];
        }

        [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithArray: newCountryCodes]
                                                  forKey: countryKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the toggle and reload the filter table.
            [self updateCountryToggle];
            [countryFilterTableView reloadData];
        });
    }
}

- (BOOL) isFiltered
{
    NSMutableArray * graphCountryCodes = [NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults] objectForKey: countryKey]];

    // If nothing is selected, then return no
    if(0 == graphCountryCodes.count) return NO;

    // If we have all the countries selected, then we are not filtered.
    if(graphCountryCodes.count == allCountries.count) return NO;

    // At this point, we are filtered
    return YES;
} // End of isFiltered

#pragma mark -
#pragma NSTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(tableView == countryFilterTableView)
    {
        return countries.count;
    }
    
    return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row >= countries.count)
    {
        return nil;
    }
    
    NSDictionary * country = countries[row];
    if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CollectRank"])
    {
        return [NSNumber numberWithBool: [[[NSUserDefaults standardUserDefaults] objectForKey: countryKey] containsObject: country[@"countryCode"]]];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"CountryImage"])
    {
        return [NSImage imageNamed: [NSString stringWithFormat: @"%@.png", [country[@"countryCode"] lowercaseString]]];
    }
    else if(NSOrderedSame == [tableColumn.identifier caseInsensitiveCompare: @"Country"])
    {
        return country[@"name"];
    }

    NSLog(@"Unknown column: %@", tableColumn.identifier);
    return @"";
}


- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row >= countries.count)
    {
        return;
    }

    didChange = YES;

    NSDictionary * country = countries[row];

    NSMutableArray * graphCountryCodes = [NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults] objectForKey: countryKey]];
    
    if([graphCountryCodes containsObject: country[@"countryCode"]])
    {
        [graphCountryCodes removeObject: country[@"countryCode"]];
    }
    else
    {
        [graphCountryCodes addObject: country[@"countryCode"]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSArray arrayWithArray: graphCountryCodes]
                                              forKey: countryKey];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCountryToggle];
    });
}

@end

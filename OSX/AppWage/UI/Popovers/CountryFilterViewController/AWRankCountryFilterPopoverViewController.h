//
//  RankCountryFilterPopoverViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 1/12/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWRankCountryFilterPopoverViewController : NSViewController

- (IBAction) onSearchCountries: (id) sender;
- (IBAction) toggleAllCountries: (id) sender;

- (BOOL) isFiltered;

@property(nonatomic,assign) BOOL didChange;
@property(nonatomic,retain) NSString * countryKey;

@end

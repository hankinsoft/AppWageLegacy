//
//  GenreFilterViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2/20/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWGenreFilterViewController : NSViewController

- (BOOL) isFiltered;
- (IBAction) onToggleAll: (id) sender;

@property(nonatomic,copy)   NSArray * availableGenres;
@property(nonatomic,copy)   NSSet   * selectedGeneres;

@end

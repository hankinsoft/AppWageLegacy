//
//  VersionFilterViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWVersionFilterViewController : NSViewController

- (BOOL) isFiltered;
- (IBAction) onToggleAll: (id) sender;

@property(nonatomic,assign) BOOL didChange;
@property(nonatomic,copy)   NSArray * allVersions;
@property(nonatomic,copy)   NSArray * selectedVersions;

@end

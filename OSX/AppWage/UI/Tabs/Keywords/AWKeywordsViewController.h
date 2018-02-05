//
//  KeywordsViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWKeywordsViewController : NSViewController

- (IBAction) onDownloadKeywordRanks: (id) sender;
- (void) setSelectedApplications: (NSSet*) selectedApplications;

@property(nonatomic,assign) BOOL isFocusedTab;

@end

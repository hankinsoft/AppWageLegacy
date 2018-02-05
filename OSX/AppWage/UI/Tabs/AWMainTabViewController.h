//
//  MainTabViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWMainTabViewController : NSViewController

@property(nonatomic,copy) NSSet * selectedApplications;

- (void) initialize;

- (void) selectDashboard;
- (void) selectReviews;
- (void) selectRankings;
- (void) selectKeywords;

- (void) clearSelectedApplications;

@end

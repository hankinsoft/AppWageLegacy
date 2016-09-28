//
//  MainTabViewController.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWMainTabViewController.h"
#import "AWApplicationDashboardViewController.h"
#import "AWApplicationReviewsViewController.h"
#import "AWApplicationRankViewController.h"

@interface AWMainTabViewController ()
{
    IBOutlet NSTabView                      * mainTabView;

    AWApplicationRankViewController         * applicationRankViewController;
    AWApplicationDashboardViewController    * applicationDashboardViewController;
    AWApplicationReviewsViewController      * applicationReviewsViewController;
}

@end

@implementation AWMainTabViewController

@synthesize selectedApplications;

- (id) init
{
    self = [super initWithNibName: @"AWMainTabViewController" bundle: nil];
    if(self)
    {
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    applicationRankViewController = [[AWApplicationRankViewController alloc] init];
    applicationReviewsViewController = [[AWApplicationReviewsViewController alloc] init];
    applicationDashboardViewController = [[AWApplicationDashboardViewController alloc] init];

    NSTabViewItem *item = [mainTabView tabViewItemAtIndex :0];
    [item setView: applicationDashboardViewController.view];

    item = [mainTabView tabViewItemAtIndex :1];
    [item setView: applicationReviewsViewController.view];
    
    item = [mainTabView tabViewItemAtIndex :2];
    [item setView: applicationRankViewController.view];
} // End of awakeFromNib

- (void) initialize
{
    [applicationDashboardViewController initialize];
}

- (void) setSelectedApplications:(NSSet *) _selectedApplications
{
    selectedApplications = _selectedApplications;

    // Pass to the tabs
    [applicationDashboardViewController setSelectedApplications: selectedApplications];
    [applicationReviewsViewController setSelectedApplications: selectedApplications];
    [applicationRankViewController setSelectedApplications: selectedApplications];
} // End of setSelectedApplications

- (void) selectDashboard
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: NO];
    [applicationRankViewController setIsFocusedTab: NO];
    [applicationDashboardViewController setIsFocusedTab: YES];
    [mainTabView selectTabViewItemAtIndex: 0];
} // End of selectDashboard

- (void) selectReviews
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: YES];
    [applicationRankViewController setIsFocusedTab: NO];
    [applicationDashboardViewController setIsFocusedTab: NO];
    [mainTabView selectTabViewItemAtIndex: 1];
} // End of selectReviews

- (void) selectRankings
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: NO];
    [applicationRankViewController setIsFocusedTab: YES];
    [applicationDashboardViewController setIsFocusedTab: NO];
    [mainTabView selectTabViewItemAtIndex: 2];
} // End of selectRankings

- (void) clearSelectedApplications
{
    [applicationRankViewController setSelectedApplications: nil];
    [applicationDashboardViewController setSelectedApplications: nil];
    [applicationReviewsViewController setSelectedApplications: nil];
} // End of clearSelectedApplications

@end

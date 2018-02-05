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
#import "AWKeywordsViewController.h"

@interface AWMainTabViewController ()
{
    IBOutlet NSTabView                      * mainTabView;

    AWApplicationRankViewController         * applicationRankViewController;
    AWApplicationDashboardViewController    * applicationDashboardViewController;
    AWApplicationReviewsViewController      * applicationReviewsViewController;
    AWKeywordsViewController                * applicationKeywordsViewController;
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
    applicationKeywordsViewController = [[AWKeywordsViewController alloc] init];

    NSTabViewItem *item = [mainTabView tabViewItemAtIndex :0];
    [item setView: applicationDashboardViewController.view];

    item = [mainTabView tabViewItemAtIndex: 1];
    [item setView: applicationReviewsViewController.view];
    
    item = [mainTabView tabViewItemAtIndex: 2];
    [item setView: applicationRankViewController.view];

    item = [mainTabView tabViewItemAtIndex: 3];
    [item setView: applicationKeywordsViewController.view];
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
    [applicationKeywordsViewController setSelectedApplications: selectedApplications];
} // End of setSelectedApplications

- (void) selectDashboard
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: NO];
    [applicationRankViewController setIsFocusedTab: NO];
    [applicationDashboardViewController setIsFocusedTab: YES];
    [applicationKeywordsViewController setIsFocusedTab: NO];
    [mainTabView selectTabViewItemAtIndex: 0];
} // End of selectDashboard

- (void) selectReviews
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: YES];
    [applicationRankViewController setIsFocusedTab: NO];
    [applicationDashboardViewController setIsFocusedTab: NO];
    [applicationKeywordsViewController setIsFocusedTab: NO];
    [mainTabView selectTabViewItemAtIndex: 1];
} // End of selectReviews

- (void) selectRankings
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: NO];
    [applicationRankViewController setIsFocusedTab: YES];
    [applicationDashboardViewController setIsFocusedTab: NO];
    [applicationKeywordsViewController setIsFocusedTab: NO];
    [mainTabView selectTabViewItemAtIndex: 2];
} // End of selectRankings

- (void) selectKeywords
{
    // Let our tabs know who is focused.
    [applicationReviewsViewController setIsFocusedTab: NO];
    [applicationRankViewController setIsFocusedTab: NO];
    [applicationDashboardViewController setIsFocusedTab: NO];
    [applicationKeywordsViewController setIsFocusedTab: YES];
    [mainTabView selectTabViewItemAtIndex: 3];
} // End of selectRankings

- (void) clearSelectedApplications
{
    [applicationRankViewController setSelectedApplications: nil];
    [applicationDashboardViewController setSelectedApplications: nil];
    [applicationReviewsViewController setSelectedApplications: nil];
    [applicationKeywordsViewController setSelectedApplications: nil];
} // End of clearSelectedApplications

@end

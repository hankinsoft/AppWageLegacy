//
//  ApplicationReviewsViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/17/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ReviewTableDTO : NSObject
{
    
}

@property(nonatomic,copy) NSNumber * reviewId;
@property(nonatomic,copy) NSNumber * stars;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * content;
@property(nonatomic,copy) NSString * reviewer;
@property(nonatomic,copy) NSString * appVersion;
@property(nonatomic,copy) NSDate   * lastUpdated;

@property(nonatomic,copy) NSNumber * readByUser;

@property(nonatomic,copy) NSNumber * translatedByUser;
@property(nonatomic,copy) NSString * translatedTitle;
@property(nonatomic,copy) NSString * translatedContent;
@property(nonatomic,copy) NSString * translatedLocal;

@property(nonatomic,copy) NSNumber * applicationId;
@property(nonatomic,copy) NSString * applicationName;
@property(nonatomic,copy) NSString * countryName;
@property(nonatomic,copy) NSString * countryCode;

@end

@interface AWApplicationReviewsViewController : NSViewController

- (IBAction) onDownloadReviews: (id) sender;
- (IBAction) markAllCurrentReviewsAsRead: (id) sender;
- (IBAction) onTranslateReview: (id)sender;
- (IBAction) onSearchReview: (id) sender;

- (void) setSelectedApplications: (NSSet*) selectedApplications;

@property(nonatomic,assign) BOOL isFocusedTab;

@end

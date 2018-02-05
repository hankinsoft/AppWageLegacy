//
//  Application.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AWAccount, AWApplicationCollection, AWGenre, AWProduct, AWApplicationFinderEntry;

@interface AWApplication : NSObject

+ (void) initializeAllApplications;
+ (NSArray<AWApplication*>*) allApplications;
+ (NSArray<AWApplication*>*) applicationsByInternalAccountId: (NSString*) internalAccountId;
+ (AWApplication*) applicationByApplicationId: (NSNumber*) applicationId;
+ (void) addApplication: (AWApplication*) application;

+ (AWApplication*) createFromApplicationEntry: (AWApplicationFinderEntry*) entry;

@property (nonatomic, retain) NSNumber * applicationId;
@property (nonatomic, retain) NSNumber * applicationType;
@property (nonatomic, retain) NSNumber * hiddenByUser;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSNumber * shouldCollectRanks;
@property (nonatomic, retain) NSNumber * shouldCollectReviews;
@property (nonatomic, retain) NSString * internalAccountId;
@property (nonatomic, retain) NSSet * genreIds;

@end

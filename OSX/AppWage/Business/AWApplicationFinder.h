//
//  ApplicationFinder.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/24/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWApplicationFinder;

@interface AWApplicationFinderEntry : NSObject
{
}

@property(nonatomic,retain) NSNumber * applicationId;
@property(nonatomic,copy)   NSString * applicationName;
@property(nonatomic,copy)   NSString * applicationDeveloper;
@property(nonatomic,retain) NSNumber * applicationType;
@property(nonatomic,retain) NSArray  * genreIds;

@end

@protocol ApplicationFinderProtocol <NSObject>

- (void) applicationFinder: (AWApplicationFinder*) applicationFinder
      receivedApplications: (NSArray*) applications;

- (void) applicationFinder: (AWApplicationFinder*) applicationFinder
             receivedError: (NSError*) error;

@end

@interface AWApplicationFinder : NSObject

- (void) beginFindApplications: (NSString*) searchTerm
                    includeIOS: (bool) includeIOS
                    includeOSX: (bool) includeOSX
                  includeIBOOK: (bool) includeIBOOK;

@property(nonatomic,weak) id<ApplicationFinderProtocol> delegate;

@end

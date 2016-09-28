//
//  RankCollectionTask.h
//  AppWage
//
//  Created by Kyle Hankinson on 2013-10-23.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWRankCollectionOperation;

@protocol AWRankCollectionProtocol <NSObject>

- (void) rankCollectionOperationStarted: (AWRankCollectionOperation*) rankCollectionOperation;
- (void) rankCollectionOperationFinished: (AWRankCollectionOperation*) rankCollectionOperation;

@end

@interface AWRankCollectionOperation : NSOperation

- (id) initWithRankUrl: (NSString*) rankUrl
       appsWeCareAbout: (NSArray*) appsWeCareAbout
        countryDetails: (NSDictionary*) countryDetails
         chartObjectId: (id) chartObjectId;

+ (NSArray*) processRankDictionary: (NSDictionary*) rankEntries
                   appsWeCareAbout: (NSArray*) appsWeCareAbout
                         countryId: (NSNumber*) countryId
                           chartId: (NSNumber*) chartId
                           genreId: (NSNumber*) genreId;

@property(nonatomic,weak) id<AWRankCollectionProtocol> delegate;

@end

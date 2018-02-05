//
//  AWApplicationKeyword.h
//  AppWage
//
//  Created by Kyle Hankinson on 2018-02-05.
//  Copyright © 2018 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AWApplicationKeyword : NSObject

+ (NSArray< NSString*>*) keywordsForApplicationId: (NSNumber*) applicationId;
+ (void) setKeywords: (NSArray<NSString*>*) keywords
    forApplicationId: (NSNumber*) applicationId;

@property (nonatomic, copy) NSNumber * applicationId;
@property (nonatomic, copy) NSString * keyword;

@end

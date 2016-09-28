//
//  ApplicationRank.h
//  AppWage
//
//  Created by Kyle Hankinson on 2013-10-24.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Application;

@interface AWApplicationRank : NSObject

@property(nonatomic,copy)   NSDate          * date;
@property(nonatomic,retain) Application     * application;
@property(nonatomic,copy)   NSNumber        * rankInStore;
@property(nonatomic,copy)   NSString        * countryCode;

@end

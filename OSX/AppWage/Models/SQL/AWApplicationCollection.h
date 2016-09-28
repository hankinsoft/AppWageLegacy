//
//  ApplicationCollection.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-10-31.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AWApplication;

@interface AWApplicationCollection : NSObject

@property (nonatomic, copy)   NSString * name;
@property (nonatomic, retain) NSSet *applications;

@end

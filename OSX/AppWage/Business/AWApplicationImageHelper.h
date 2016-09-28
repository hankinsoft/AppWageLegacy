//
//  ApplicationImageHelper.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/18/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWApplication;

@interface AWApplicationImageHelper : NSObject

+ (NSString*) imagePathForApplicationId: (NSNumber*) applicationId;
+ (NSImage*) imageForApplicationId: (NSNumber*) applicationId;
+ (NSImage*) imageForApplicaton: (AWApplication*) application;

+ (void) saveImage: (NSImage*) image forApplicationId: (NSNumber*) applicationId;

@end

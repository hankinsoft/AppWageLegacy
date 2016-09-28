//
//  AWErrors.h
//  AppWage
//
//  Created by Kyle Hankinson on 2016-09-06.
//  Copyright © 2016 Hankinsoft. All rights reserved.
//

#ifndef AWErrors_h
#define AWErrors_h

#import <Cocoa/Cocoa.h>

static NSString * const AWErrorDomain = @"com.hankinsoft.osx.appwage";

typedef NS_ENUM(NSUInteger, AWError) {
    AWErrorVendorLookupFailure = 0
};

#endif /* AWErrors_h */

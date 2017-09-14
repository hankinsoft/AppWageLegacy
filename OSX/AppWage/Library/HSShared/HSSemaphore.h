//
//  HSSemaphore.h
//  HSShared
//
//  Created by Kyle Hankinson on 2016-05-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSSemaphore : NSObject

- (id) initWithIdentifier: (NSString*) identifier
             initialValue: (long) initialValue;

- (long) wait: (dispatch_time_t) timeout;
- (void) signal;

@end

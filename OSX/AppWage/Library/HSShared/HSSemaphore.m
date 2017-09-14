//
//  HSSemaphore.m
//  HSShared
//
//  Created by Kyle Hankinson on 2016-05-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "HSSemaphore.h"

@interface HSSemaphore()

@property(nonatomic,copy) NSString * identifier;

@end

@implementation HSSemaphore
{
    dispatch_semaphore_t semaphore;
}

- (id) initWithIdentifier: (NSString*) identifier
             initialValue: (long) initialValue
{
    self = [super init];
    if(self)
    {
        _identifier = identifier.copy;
        semaphore = dispatch_semaphore_create(initialValue);
    } // End of self

    return self;
} // End of initWithIdentifier:

- (void) dealloc
{
    NSLog(@"HSSemaphore dealloc %@", _identifier);
} // End of dealloc

- (long) wait: (dispatch_time_t) timeout
{
    return dispatch_semaphore_wait(semaphore, timeout);
} // End of wait:

- (void) signal
{
    dispatch_semaphore_signal(semaphore);
} // End of signal

@end

// MachTimer.h
// Based on: http://zpasternack.org/high-resolution-timing-in-cocoa/
#include <mach/mach_time.h>

@interface MachTimer : NSObject
{
    uint64_t timeZero;
}

+ (id) startTimer;

- (void) start;
- (uint64_t) elapsed;
- (float) elapsedSeconds;

- (void) logSlow: (NSString*) logTitle
  ifOverXSeconds: (float) compare;
- (void) logElapsed;
- (void) logElapsedOverAverage: (NSUInteger) average;

@end
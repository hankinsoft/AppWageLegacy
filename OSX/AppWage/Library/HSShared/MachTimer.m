// MachTimer.m
#import "MachTimer.h"

static mach_timebase_info_data_t timeBase;

@implementation MachTimer

+ (void) initialize
{
    (void) mach_timebase_info( &timeBase );
}

+ (id) startTimer
{
    MachTimer * timer =
#if( __has_feature( objc_arc ) )
    [[[self class] alloc] init];
#else
    [[[[self class] alloc] init] autorelease];
#endif
    
    [timer start];
    return timer;
}

- (id) init
{
    if( (self = [super init]) ) {
        timeZero = mach_absolute_time();
    }
    return self;
}

- (void) start
{
    timeZero = mach_absolute_time();
}

- (uint64_t) elapsed
{
    return mach_absolute_time() - timeZero;
}

- (float) elapsedSeconds
{
    return ((float)(mach_absolute_time() - timeZero))
    * ((float)timeBase.numer) / ((float)timeBase.denom) / 1000000000.0f;
}

- (void) logSlow: (NSString*) logTitle
  ifOverXSeconds: (float) compare
{
    if(compare < self.elapsedSeconds)
    {
        NSLog(@"%@ (slow) took %f.", logTitle, self.elapsedSeconds);
    }
}

- (void) logElapsed
{
    NSTimeInterval theTimeInterval = [self elapsedSeconds];
    [self logElapsed: theTimeInterval];
}

- (void) logElapsed: (NSTimeInterval) theTimeInterval
{
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];

    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];

    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];

    if([breakdownInfo hour] > 0)
    {
        NSLog(@"Timer tooks: %ld hours, %ld minutes, %0.0ld seconds.",
              (long)[breakdownInfo hour],
              [breakdownInfo minute],
              [breakdownInfo second]);
    }
    else
    {
        NSLog(@"Timer tooks: %ld minutes, %ld seconds.",
              [breakdownInfo minute],
              [breakdownInfo second]);
    }
}

- (void) logElapsedOverAverage: (NSUInteger) average
{
    NSTimeInterval theTimeInterval = [self elapsedSeconds] / (float)average;
    [self logElapsed: theTimeInterval];
}

@end

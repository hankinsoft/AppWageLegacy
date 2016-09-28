//
//  InvertedNumberFormatter.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-11.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "InvertedNumberFormatter.h"

@implementation InvertedNumberFormatter
{
    NSNumberFormatter * wholeNumberFormatter;
    NSUInteger        maxValue;
}

- (id) initWithMax: (NSUInteger) _maxValue
{
    self = [super init];
    if(self)
    {
        wholeNumberFormatter    = [[NSNumberFormatter alloc] init];
        wholeNumberFormatter.maximumFractionDigits  = 0;

        maxValue = _maxValue;
    }
    
    return self;
}

- (NSString *)stringForObjectValue:(id)value;
{
    if([value isKindOfClass: [NSNumber class]])
    {
        NSNumber * newValue = [NSNumber numberWithInteger: maxValue - [value integerValue]];
        return [wholeNumberFormatter stringFromNumber: newValue];
    } // End of is a number

    return nil;
}

@end

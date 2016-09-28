//
//  ChartColorHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 1/29/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWChartColorHelper.h"

@interface AWChartColorHelper()
{

}
@end

@implementation AWChartColorHelper

static NSArray * colors;

+ (void) initialize
{
    NSMutableArray * _colors = [NSMutableArray array];
    for(NSUInteger colorIndex = 0;  colorIndex < 200; ++colorIndex)
    {
        [_colors addObject:
        [NSColor colorWithCalibratedRed: ((arc4random() % 128) + 127) / 255.0
                                  green: ((arc4random() % 128) + 127) / 255.0
                                   blue: ((arc4random() % 128) + 127) / 255.0
                                  alpha: 1]];
    }

    // Copy our colors array
    colors = [_colors copy];
}

+ (NSColor*) colorForIndex: (NSUInteger) index
{
    if(1 == index)
    {
        return [NSColor colorWithCalibratedRed: 255.0 / 255.0
                                         green: 124.0f / 255.0f
                                          blue: 124.0f / 255.0f
                                         alpha: 1];
    }
    else if(2 == index)
    {
        return [NSColor colorWithCalibratedRed: 128.0f / 255.0
                                         green: 225.0f / 255.0f
                                          blue: 35.0f / 255.0f
                                         alpha: 1];
    }
    else if(0 == index)
    {
        return [NSColor colorWithCalibratedRed: 128.0f / 255.0
                                         green: 200.0f / 255.0f
                                          blue: 255.0f / 255.0f
                                         alpha: 1];
    }
    else if(3 == index)
    {
        return [NSColor colorWithCalibratedRed: 254.0f / 255.0
                                         green: 190.0f / 255.0f
                                          blue: 50.0f / 255.0f
                                         alpha: 1];
    }
    else if(4 == index)
    {
        return [NSColor colorWithCalibratedRed: 228.0f / 255.0
                                         green: 164.0f / 255.0f
                                          blue: 255.0f / 255.0f
                                         alpha: 1];
    }
    else if(5 == index)
    {
        return [NSColor colorWithCalibratedRed: 245.0f / 255.0
                                         green: 230.0f / 255.0f
                                          blue: 50.0f / 255.0f
                                         alpha: 1];
    }

    else if(6 == index)
    {
        return [NSColor colorWithCalibratedRed: 190.0f / 255.0
                                         green: 83.0f / 255.0f
                                          blue: 76.0f / 255.0f
                                         alpha: 1];
    }
    else if(7 == index)
    {
        return [NSColor colorWithCalibratedRed: 157.0  / 255.0
                               green: 187.0f / 255.0f
                                blue: 71.0f  / 255.0f
                               alpha: 1];
    }
    else if(8 == index)
    {
        return [NSColor colorWithCalibratedRed: 79.0f  / 255.0
                               green: 128.0f / 255.0f
                                blue: 192.0f / 255.0f
                               alpha: 1];
    }
    else if(9 == index)
    {
        return [NSColor colorWithCalibratedRed: 149  / 255.0
                               green: 217 / 255.0f
                                blue: 217 / 255.0f
                               alpha: 1];
    }
    else if(10 == index)
    {
        return [NSColor colorWithCalibratedRed: 217  / 255.0
                               green: 149 / 255.0f
                                blue: 217 / 255.0f
                               alpha: 1];
    }
    else if(11 == index)
    {
        return [NSColor colorWithCalibratedRed: 217  / 255.0
                               green: 217 / 255.0f
                                blue: 149 / 255.0f
                               alpha: 1];
    }

    // Lower our index
    index -= 11;

    if(index < colors.count)
    {
        return colors[index];
    }

    return [NSColor colorWithCalibratedRed: ((arc4random() % 128) + 127) / 255.0
                                   green: ((arc4random() % 128) + 127) / 255.0
                                    blue: ((arc4random() % 128) + 127) / 255.0
                                   alpha: 1];
}

@end

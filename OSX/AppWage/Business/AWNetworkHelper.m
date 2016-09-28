//
//  NetworkHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-05.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWNetworkHelper.h"

@implementation AWNetworkHelper

+ (BOOL) checkPort: (NSInteger) portToCheck
{
    NSString * checkUrlString =
        [NSString stringWithFormat: @"http://www.appwage.com/checkPort.php?port=%ld", portToCheck];

    NSURL * portCheckUrl = [NSURL URLWithString: checkUrlString];

    NSString * resultString = [NSString stringWithContentsOfURL: portCheckUrl
                                                   usedEncoding: nil
                                                          error: nil];
    if(0 == resultString.length)
    {
        return NO;
    }

    return [[resultString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString: @"1"];
} // End of checkPort

@end

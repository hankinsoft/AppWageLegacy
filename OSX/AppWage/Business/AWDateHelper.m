//
//  DateHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-14.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWDateHelper.h"

@implementation AWDateHelper

+ (void) initialize
{
    
}

+ (NSDateFormatter*) dateTimeFormatter
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;

    return dateFormatter;
}

+ (NSDateFormatter*) dateFormatter
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    return dateFormatter;
}

@end

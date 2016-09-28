//
//  ChartPopoverDetails.m
//  AppWage
//
//  Created by Kyle Hankinson on 2016-09-01.
//  Copyright © 2016 Hankinsoft. All rights reserved.
//

#import "AWChartPopoverDetails.h"

@implementation AWChartPopoverDetails

- (id) copyWithZone: (NSZone *)zone
{
    AWChartPopoverDetails * result = [[AWChartPopoverDetails alloc] init];
    
    result.date = [self.date copy];
    result.index = self.index.copy;
    result.identifier = [self.identifier copy];
    result.mouseLocation = self.mouseLocation.copy;
    result.edge = self.edge.copy;
    result.ammount = self.ammount.copy;
    result.country = self.country.copy;
    result.details = self.details.copy;
    
    result.percentage = self.percentage.copy;
    result.value = [self.value copy];

    return result;
} // End of copyWithZone:

@end

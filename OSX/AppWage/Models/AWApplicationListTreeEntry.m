//
//  ApplicationListTreeModel.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationListTreeEntry.h"

@implementation AWApplicationListTreeEntry

@synthesize parent, display, subDisplay, children, image, representedObject, representedType, isHidden;

- (NSString*) identifier
{
    switch(representedType)
    {
        case ApplicationListTreeEntryTypeAllProducts:
            return @"AppProducts";
        case ApplicationListTreeEntryTypeUnspecified:
            return display;
        case ApplicationListTreeEntryTypeApplication:
            return [NSString stringWithFormat: @"Application-%@", display];
        case ApplicationListTreeEntryTypeProduct:
            return [NSString stringWithFormat: @"Product-%@", display];
    } // End of switch
} // End of identifier

@end

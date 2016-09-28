//
//  IconCollectorOperation.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/18/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWIconCollectorOperation.h"
#import "AWApplication.h"
#import "AWApplicationImageHelper.h"

@implementation IconCollectorOperation

@synthesize applicationId, delegate, shouldRoundIcon;

+ (NSImage*)roundCorners:(NSImage *)image
{
    
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.width, existingSize.height);
    NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];

    [composedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];

    NSRect imageFrame = NSRectFromCGRect(CGRectMake(0, 0, existingSize.width, existingSize.height));

    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect: imageFrame
                                                             xRadius: 9
                                                             yRadius: 9];

    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
    
    [composedImage unlockFocus];
    
    return composedImage;
}

- (void) main
{
    // Just skip if cancelled.
    if(self.isCancelled)
    {
        return;
    }

    NSError __autoreleasing * error = nil;
    
    if([AWApplicationImageHelper imageForApplicationId: self.applicationId])
    {
        [self cancel];
        return;
    } // End of image already exists

    NSString * urlPath = [NSString stringWithFormat: @"https://appwage.com/appIcons/icon.php?applicationId=%@",
                          applicationId.stringValue];

    NSLog(@"UrlPath: %@", urlPath);
    NSURL * imageUrl = [NSURL URLWithString: urlPath];
    NSImage * tempImage    = [[NSImage alloc] initWithContentsOfURL: imageUrl];

    if(nil == error && nil != tempImage)
    {
        [AWApplicationImageHelper saveImage: tempImage
                         forApplicationId: self.applicationId];

        if(nil != self.delegate)
        {
            [self.delegate receivedIconForApplicationId: self.applicationId];
        }
    } // End of we had an error
    else
    {
        if([self.delegate respondsToSelector: @selector(receivedErrorForApplicationId:error:)])
        {
            [self.delegate receivedErrorForApplicationId: self.applicationId
                                                   error: error];
        } // End of responds to selector
    } // End of we had an error
}

@end

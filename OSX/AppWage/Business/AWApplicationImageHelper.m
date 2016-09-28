//
//  ApplicationImageHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 11/18/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import "AWApplicationImageHelper.h"
#import "AWApplication.h"

@implementation AWApplicationImageHelper

NSString * applicationImagePath = nil;

+ (void) initialize
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);

    NSString *path = [paths objectAtIndex:0];
    applicationImagePath = [path stringByAppendingString: [NSString stringWithFormat: @"/%@", [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]]];
    applicationImagePath = [applicationImagePath stringByAppendingPathComponent:@"/ApplicationImages"];

    // Create our directory
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = false;

    NSError __autoreleasing * error = nil;

    if(![fileManager fileExistsAtPath: applicationImagePath isDirectory: &isDirectory])
    {
        NSLog(@"Want to create path: %@", applicationImagePath);

        [fileManager createDirectoryAtPath: applicationImagePath
               withIntermediateDirectories: YES
                                attributes: nil
                                     error: &error];
        if(nil != error)
        {
            NSLog(@"Error creating directory (%@): %@", applicationImagePath, error.localizedDescription);
        }
    } // End of the file does not already exist.
    
    NSLog(@"Application image path is: %@", applicationImagePath);
} // End of initialize

+ (NSString*) imagePathForApplicationId: (NSNumber*) applicationId
{
    return [NSString stringWithFormat: @"%@/%@.png",
            applicationImagePath, applicationId.stringValue];
} // End of imagePathForApplicationId

+ (NSString*) imagePathForApplication: (AWApplication*) application
{
    return [self imagePathForApplicationId: application.applicationId];
} // End of imagePathForApplication

+ (void) saveImage: (NSImage *) image
  forApplicationId: (NSNumber*) applicationId
{
    NSString * imagePath = [self imagePathForApplicationId: applicationId];

    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];

    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[image size]];   // if you want the same resolution

    NSData *pngData =
        [newRep representationUsingType: NSPNGFileType
                             properties: @{}];

    [pngData writeToFile: imagePath
              atomically: YES];
}

+ (NSImage*) imageForApplicationId: (NSNumber*) applicationId
{
    NSString * imagePath = [self imagePathForApplicationId: applicationId];
    return [[NSImage alloc] initWithContentsOfFile: imagePath];
}

+ (NSImage*) imageForApplicaton: (AWApplication*) application
{
    return [self imageForApplicationId: application.applicationId];
} // End of imageForApplication

@end

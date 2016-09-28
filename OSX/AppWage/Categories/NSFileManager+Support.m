//
//  NSFileManager+Support.m
//  AppWage
//
//  Created by Kyle Hankinson on 2015-01-19.
//  Copyright (c) 2015 Hankinsoft. All rights reserved.
//

#import "NSFileManager+Support.h"

@implementation NSFileManager(Support)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    // Search for the path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(
                                                         searchPathDirectory,
                                                         domainMask,
                                                         YES);
    if ([paths count] == 0)
    {
        // *** creation and return of error object omitted for space
        return nil;
    }
    
    // Normally only need the first path
    NSString *resolvedPath = [paths objectAtIndex:0];
    
    if (appendComponent)
    {
        resolvedPath = [resolvedPath
                        stringByAppendingPathComponent:appendComponent];
    }
    
    // Create the path if it doesn't exist
    NSError *error;
    BOOL success = [self
                    createDirectoryAtPath:resolvedPath
                    withIntermediateDirectories:YES
                    attributes:nil
                    error:&error];
    if (!success) 
    {
        if (errorOut)
        {
            *errorOut = error;
        }
        return nil;
    }
    
    // If we've made it this far, we have a success
    if (errorOut)
    {
        *errorOut = nil;
    }
    return resolvedPath;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName =
        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];

    NSError *error = nil;

    NSString *result =
        [self findOrCreateDirectory:NSApplicationSupportDirectory
                           inDomain:NSUserDomainMask
                appendPathComponent:executableName
                              error:&error];

    if (error)
    {
        NSLog(@"Unable to find or create application support directory:\n%@", error);
    }

    return result;
}

@end

//
//  ReviewImportHelper.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWReportImportHelper.h"
#import "HSProgressWindowController.h"

#import "AWAccountHelper.h"
#import "AWAccount.h"
#import "AWCollectionOperationQueue.h"
#import "AWApplicationListTreeViewController.h"
#import "AWCacheHelper.h"
#import "AWiTunesConnectHelper.h"

@interface AWReportImportHelper()

@property(nonatomic,retain)     NSWindow        * window;

@end

@implementation AWReportImportHelper
{
    HSProgressWindowController            * progressWindowController;
}

@synthesize window;

static NSRegularExpression * accountFileExpression = nil;

+ (void) initialize
{
    NSError * error = nil;
    NSString * regularExpressionString = [NSString stringWithFormat: @"S_([DMWY])_([0-9]{8})_(\\d+)\\."];

    accountFileExpression =
        [NSRegularExpression regularExpressionWithPattern: regularExpressionString
                                                  options: NSRegularExpressionCaseInsensitive
                                                    error: &error];

    NSAssert1(nil == error, @"AccountFileExpression failed. %@.", error.localizedDescription);
} // End of initialize

- (id) initWithWindow: (NSWindow*) _parentWindow
{
    self = [super init];
    if(self)
    {
        self.window = _parentWindow;
    }
    
    return self;
}

- (void) startImportViaDialog
{
    // If we are already running, the exit
    if([AWCollectionOperationQueue sharedInstance].isRunning)
    {
        NSAlert * alert = [NSAlert alertWithMessageText: @"Cannot import"
                                          defaultButton: @"OK"
                                        alternateButton: nil
                                            otherButton: nil
                              informativeTextWithFormat: @"You must wait for all collections to finish."];
        
        [alert beginSheetModalForWindow: self.window
                          modalDelegate: nil
                         didEndSelector: nil
                            contextInfo: NULL];
        
        return;
    } // End of already collecting

    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories    = YES;
    openPanel.canChooseFiles          = YES;
    openPanel.canCreateDirectories    = NO;
    openPanel.allowsMultipleSelection = YES;
    openPanel.title = @"Select files or folders to import";

    [openPanel beginSheetModalForWindow: self.window
                      completionHandler: ^(NSInteger result)
    {
          if (result != NSFileHandlingPanelOKButton)
          {
              return;
          }

          // Import our urls
          [self importWithUrls: openPanel.URLs];
    }]; // End of openPanel
}

- (void) importWithUrls: (NSArray*) urls
{
    // Setup the progressWindowController
    progressWindowController = [[HSProgressWindowController alloc] init];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            progressWindowController.labelString = @"Preparing for import";
            [progressWindowController beginSheetModalForWindow: self.window
                                             completionHandler: nil];
        });

        // Get our files to import
        NSArray * possibleFilesTemp  = [self getFilesToImportForUrls: urls];

        NSLog(@"We had %ld files.", possibleFilesTemp.count);

        NSArray * sortedArray = [possibleFilesTemp sortedArrayUsingComparator:
                                 ^NSComparisonResult(NSDictionary*obj1,NSDictionary*obj2)
                                 {
                                     return [obj1[@"path"] compare: obj2[@"path"]];
                                 }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [progressWindowController endSheetWithReturnCode: 0];
        });

        // Load our reports
        [[AWCollectionOperationQueue sharedInstance] loadReports: sortedArray];
    }); // End of dispatch background
}

- (NSArray*) getFilesToImportForUrls: (NSArray*) urls
{
    NSMutableArray * filesToImport = [NSMutableArray array];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    [urls enumerateObjectsUsingBlock: ^(NSURL * url, NSUInteger urlIndex, BOOL * stop)
     {
         BOOL isDirectory = NO;
         if(![fileManager fileExistsAtPath: url.path isDirectory: &isDirectory])
         {
             // File does not exist. Do nothing.
             return;
         } // End of file does not exist
         
         if(!isDirectory)
         {
             NSDictionary * fileDetails = [AWReportImportHelper detailsForFileAtPath: url.path];
             if(nil != fileDetails)
             {
                 [filesToImport addObject: fileDetails];
             } // End of we have fileDetails

             return;
         } // End of is directory

         NSDirectoryEnumerator *enumerator =
         [fileManager enumeratorAtURL: url
           includingPropertiesForKeys: @[NSURLIsDirectoryKey]
                              options: 0
                         errorHandler: ^(NSURL *url, NSError *error) {
                             NSLog(@"Had error: %@", error.localizedDescription);
                             return YES;
                         }];

         @autoreleasepool
         {
             for (NSURL * directoryEntryUrl in enumerator)
             {
                 NSError *error;
                 NSNumber *isDirectory = nil;
                 
                 if (![url getResourceValue: &isDirectory
                                     forKey: NSURLIsDirectoryKey
                                      error: &error])
                 {
                     continue;
                 }

                 NSDictionary * fileDetails =
                    [AWReportImportHelper detailsForFileAtPath: directoryEntryUrl.path];

                 if(nil != fileDetails)
                 {
                     [filesToImport addObject: fileDetails];
                 } // End of we have fileDetails

             } // End of directoryUrl enumerate
         } // End of autoreleasepool
     }]; // End of URL enumeration

    // Return the files we want to import
    return filesToImport.copy;
}

+ (NSDictionary*) detailsForFileAtPath: (NSString*) filePath
{
    NSTextCheckingResult * match =
        [accountFileExpression firstMatchInString: filePath
                                          options: 0
                                            range: NSMakeRange(0, filePath.length)];

    // No match. Blargh.
    if(nil == match)
    {
        return nil;
    } // End of no match

    NSNumber * reportType = nil;

    NSString * reportTypeString = [filePath substringWithRange: [match rangeAtIndex: 1]];
    if(NSOrderedSame == [reportTypeString caseInsensitiveCompare: @"Y"])
    {
        reportType = @(SalesReportYearly);
    }
    else if(NSOrderedSame == [reportTypeString caseInsensitiveCompare: @"M"])
    {
        reportType = @(SalesReportMonthly);
    }
    else if(NSOrderedSame == [reportTypeString caseInsensitiveCompare: @"W"])
    {
        reportType = @(SalesReportWeekly);
    }
    else if(NSOrderedSame == [reportTypeString caseInsensitiveCompare: @"D"])
    {
        reportType = @(SalesReportDaily);
    }
    else
    {
        return nil;
    }

    // Get our account id
    NSString * vendorIdString = [filePath substringWithRange: [match rangeAtIndex: 2]];
    NSNumber * vendorId       = [NSNumber numberWithInteger: vendorIdString.integerValue];

    return @{
        @"path": filePath,
        @"vendorId": vendorId,
        @"reportType": reportType
    };
}

- (NSString*) vendorNameForReportPath: (NSString*) reportPath
{
    NSLog(@"Want to get vendor name for report path: %@", reportPath);
    
    NSError * error = nil;
    
    NSString * fileContents = [NSString stringWithContentsOfURL: [NSURL fileURLWithPath: reportPath]
                                                   usedEncoding: nil
                                                          error: &error];
    
    if(nil != error)
    {
        return @"";
    }
    
    NSMutableArray * lines = [NSMutableArray arrayWithArray: [[fileContents stringByReplacingOccurrencesOfString: @"\r" withString: @""] componentsSeparatedByString: @"\n"]];
    
    // Get our header.
    NSArray * header = [lines[0] componentsSeparatedByString: @"\t"];
    
    // Remove that line
    [lines removeObjectAtIndex: 0];
    
    NSInteger developerIndex   = [header indexOfObject: @"Developer"];
    NSAssert(NSNotFound != developerIndex, @"Developer column was not found.");
    
    NSArray * entries = [lines[0] componentsSeparatedByString: @"\t"];

    __block NSString * developerEntry = @"";
    [lines enumerateObjectsUsingBlock: ^(NSString * line, NSUInteger lineIndex, BOOL * stop)
     {
         developerEntry = [[entries objectAtIndex: developerIndex] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
         
         if(developerEntry.length > 0)
         {
             *stop = YES;
         }
     }];

    return developerEntry;
}

@end

//
//  AWWindowAllowDrop.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWWindowAllowDrop.h"
#import "AWReportImportHelper.h"
#import "AWCollectionOperationQueue.h"

@implementation AWWindowAllowDrop

@synthesize fileDropDelegate;

-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    NSLog(@"Dragging enetered");

    NSPasteboard * pasteboard = [sender draggingPasteboard];

    if ( [[pasteboard types] containsObject: NSFilenamesPboardType] )
    {
        return NSDragOperationCopy;
    }

    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    NSLog(@"Window prepareForDragOperation");

    NSPasteboard * pasteboard = [sender draggingPasteboard];

    // parameter view type
    if ( [[pasteboard types] containsObject: NSFilenamesPboardType] )
    {
        NSMutableArray * urls = [NSMutableArray array];

        // Get our files
        NSArray *files = [pasteboard propertyListForType: NSFilenamesPboardType];
        for ( NSString * file in files )
        {
            NSString * tempFile = [file stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if(tempFile.length > 0)
            {
                [urls addObject: [NSURL fileURLWithPath: tempFile]];
            }
        } // End of directory validation

        if(nil != self.fileDropDelegate && [self.fileDropDelegate respondsToSelector: @selector(droppedURLS:)])
        {
            return [self.fileDropDelegate droppedURLS: [urls copy]];
        }
    }

    return NO;
}

@end

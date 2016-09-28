//
//  FilterTableHeaderCell.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWFilterTableHeaderCell.h"

@implementation AWFilterTableHeaderCell

@synthesize isFiltered;

static NSImage * tableFilterImage = nil;
static NSImage * tableFilterIsFilteredImage = nil;

+ (void) initialize
{
    tableFilterImage = [NSImage imageNamed: @"Table-Header-Filter"];
    tableFilterIsFilteredImage = [NSImage imageNamed: @"Table-Header-Filter-Highlight"];
}

// -------------------------------------------------------------------------------
//  copyWithZone:zone
// -------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone
{
    AWFilterTableHeaderCell *cell = (AWFilterTableHeaderCell *)[super copyWithZone:zone];
    return cell;
}

- (id) init
{
    self = [super init];
    if(self)
    {
    }

    return self;
}
/*
- (void)drawWithFrame:(CGRect)cellFrame
          highlighted:(BOOL)isHighlighted
               inView:(NSView *)view
{
    [super drawWithFrame: cellFrame inView: view];

    CGRect fillRect, borderRect;
    CGRectDivide(cellFrame, &borderRect, &fillRect, 1.0, CGRectMaxYEdge);

    NSGradient *gradient = [[NSGradient alloc]
                            initWithStartingColor:[NSColor whiteColor]
                            endingColor:[NSColor colorWithDeviceWhite:0.9 alpha:1.0]];

    [gradient drawInRect:fillRect angle:90.0];

    if (isHighlighted)
    {
        [[NSColor colorWithDeviceWhite:0.0 alpha:0.1] set];
        NSRectFillUsingOperation(fillRect, NSCompositeSourceOver);
    }
    
    [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] set];
    NSRectFill(borderRect);
    
    [self drawInteriorWithFrame:CGRectInset(fillRect, 0.0, 1.0) inView:view];
}
*/

- (void)drawWithFrame: (CGRect)cellFrame
               inView: (NSView *)view
{
    NSString * tempString = self.stringValue;

    if(cellFrame.size.width > 40)
    {
        self.stringValue = [NSString stringWithFormat: @"     %@", self.stringValue];
    }
    else
    {
        self.stringValue = @"";
    }

    // Draw it
    [super drawWithFrame: cellFrame
                  inView: view];

    NSImage * targetImage = isFiltered ? tableFilterIsFilteredImage : tableFilterImage;

    NSRect newCellFrame = cellFrame;
    NSSize  imageSize;
    NSRect  imageFrame;

    imageSize = NSMakeSize(16,16);
    NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);

    imageFrame.origin.y += 1;
    imageFrame.size = imageSize;

    [targetImage drawInRect: imageFrame
                   fromRect: NSZeroRect
                  operation: NSCompositeSourceOver
                   fraction: 1.0
             respectFlipped: YES
                      hints: nil];

    newCellFrame.origin.x += 3;
    newCellFrame.origin.y += 1;

    self.stringValue = tempString;
}
/*
- (void)highlight:(BOOL)isHighlighted
        withFrame:(NSRect)cellFrame
           inView:(NSView *)view
{
    [self drawWithFrame:cellFrame highlighted:isHighlighted inView:view];
}
*/
@end

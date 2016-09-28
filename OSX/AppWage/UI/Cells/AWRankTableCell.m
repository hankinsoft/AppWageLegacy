//
//  RankTableCell.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-14.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWRankTableCell.h"

@implementation AWRankTableCell

static NSImage * downRankImage;
static NSImage * upRankImage;
static NSImage * equalRankImage;

+ (void) initialize
{
    downRankImage       = [NSImage imageNamed: @"Rank-Down"];
    upRankImage         = [NSImage imageNamed: @"Rank-Up"];
    equalRankImage      = [NSImage imageNamed: @"Rank-Equal"];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)view
{
    NSString * previousStringValue = self.stringValue;
    self.stringValue = @"";

    // Draw it
    [super drawWithFrame: cellFrame
                  inView: view];
    
    self.stringValue = previousStringValue;

    NSRect newCellFrame = cellFrame;
    NSSize  imageSize;
    NSRect  imageFrame;

    imageSize = NSMakeSize(16,16);
    NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);

    imageFrame.origin.y += 1;
    imageFrame.origin.x += 1;
    imageFrame.size = imageSize;

    // Only draw the arrow if we have room
    if(cellFrame.size.width > 16)
    {
        NSImage * targetImage = nil;
        if([self.objectValue integerValue] > 0)
        {
            targetImage = upRankImage;
        }
        else if([self.objectValue integerValue] < 0)
        {
            targetImage = downRankImage;
        }
        else
        {
            targetImage = equalRankImage;
        }

        if(nil != targetImage)
        {
            [targetImage drawInRect: imageFrame
                             fromRect: NSZeroRect
                            operation: NSCompositeSourceOver
                             fraction: 1.0
                       respectFlipped: YES
                                hints: nil];
        }

        // Also draw our change
        NSRect newFrame = cellFrame;

        newFrame.size.width -= 20;
        newFrame.origin.x   += 20;

        NSString * previous = self.stringValue;
        self.stringValue = [NSString stringWithFormat: @"%ld", ABS([self.objectValue integerValue])];

        [super drawWithFrame: newFrame
                      inView: view];

        self.stringValue = previous;
    }
}

@end

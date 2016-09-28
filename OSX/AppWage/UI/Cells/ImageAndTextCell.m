/*
 File: ImageAndTextCell.m
 Abstract: Subclass of NSTextFieldCell which can display text and an image simultaneously.
 
 Version: 1.4
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "ImageAndTextCell.h"

#define kImageOriginXOffset     3
#define kImageOriginYOffset     3

#define kTextOriginXOffset      3
#define kTextOriginYOffset      2
#define kTextHeightAdjust       4

@interface ImageAndTextCell ()

@end

@implementation ImageAndTextCell

// -------------------------------------------------------------------------------
//  init
// -------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self)
    {
          self.lineBreakMode = NSLineBreakByTruncatingTail;
        // we want a smaller font
//        [self setFont: [NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    }
    return self;
}

// -------------------------------------------------------------------------------
//  copyWithZone:zone
// -------------------------------------------------------------------------------
- (id)copyWithZone:(NSZone *)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
    cell.image = self.image;
    return cell;
}
/*
// -------------------------------------------------------------------------------
//  isGroupCell:
// -------------------------------------------------------------------------------
- (BOOL)isGroupCell
{
    return ([self image] == nil && [[self title] length] > 0);
}

// -------------------------------------------------------------------------------
//  editWithFrame:inView:editor:delegate:event
// -------------------------------------------------------------------------------
- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
    NSRect textFrame = [self titleRectForBounds:aRect];
    [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

// -------------------------------------------------------------------------------
//  selectWithFrame:inView:editor:delegate:event:start:length
// -------------------------------------------------------------------------------
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
    NSRect textFrame = [self titleRectForBounds:aRect];
    [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
*/
// -------------------------------------------------------------------------------
//  drawWithFrame:cellFrame:controlView
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect newCellFrame = cellFrame;

    if (self.image != nil)
    {
        NSSize  imageSize;
        NSRect  imageFrame;
        
        imageSize = [self.image size];
        NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
        if ([self drawsBackground])
        {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }

        imageFrame.origin.y += kImageOriginYOffset;
        imageFrame.size = imageSize;

        [self.image drawInRect:imageFrame
                      fromRect:NSZeroRect
                     operation:NSCompositeSourceOver
                      fraction:1.0
                respectFlipped:YES
                         hints:nil];

        newCellFrame.origin.x += 3;
        newCellFrame.origin.y += 1;
//        newCellFrame.size.width -= 3;
    }

    [super drawWithFrame: newCellFrame
                  inView: controlView];
}
/*
// -------------------------------------------------------------------------------
//  cellSize
// -------------------------------------------------------------------------------
- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (self.image ? [self.image size].width + 3 : 0) + 3;
    return cellSize;
}
*/
@end
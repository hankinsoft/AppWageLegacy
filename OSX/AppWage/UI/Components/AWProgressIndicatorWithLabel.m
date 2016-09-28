//
//  AWProgressIndicatorWithLabel.m
//  AppWage
//
//  Created by Kyle Hankinson on 2/3/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWProgressIndicatorWithLabel.h"

@interface AWProgressIndicatorWithLabel()
{
    
}

@property (retain) NSImage*	stripes;
@property (retain) NSColor* stripesPattern;

@end

@implementation AWProgressIndicatorWithLabel

@synthesize doubleValue, stripes, stripesPattern;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.stripes = [NSImage imageNamed: @"stripes"];
		self.stripesPattern = [NSColor colorWithPatternImage: self.stripes];
    }
    
    return self;
}

- (void)awakeFromNib
{
	//// Image Declarations
	self.stripes = [NSImage imageNamed: @"stripes"];
	self.stripesPattern = [NSColor colorWithPatternImage: self.stripes];
}

-(void)setDoubleValue:(double)aValue
{
	doubleValue = aValue;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //// Color Declarations
    NSColor* highlight = [NSColor colorWithCalibratedRed: 0.438 green: 0.438 blue: 0.438 alpha: 0.63];
    NSColor* topColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* bottomColor = [topColor shadowWithLevel: 0.143];
    NSColor* whiteEdgeColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.53];
    NSColor* progressColor = [NSColor colorWithCalibratedRed: 0.824 green: 0.855 blue: 0.902 alpha: 1];
    NSColor* fontColor = [NSColor colorWithCalibratedRed: 0.216 green: 0.216 blue: 0.216 alpha: 1];
    NSColor* progressBackgroundColor = [NSColor colorWithCalibratedRed: 0.922 green: 0.937 blue: 0.957 alpha: 1];
    
    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
                            topColor, 0.0,
                            [NSColor colorWithCalibratedRed: 0.929 green: 0.929 blue: 0.929 alpha: 1], 0.42,
                            bottomColor, 1.0, nil];
    
    //// Shadow Declarations
    NSShadow* whiteEdgeShadow = [[NSShadow alloc] init];
    [whiteEdgeShadow setShadowColor: whiteEdgeColor];
    [whiteEdgeShadow setShadowOffset: NSMakeSize(0.1, 1.1)];
    [whiteEdgeShadow setShadowBlurRadius: 1];
    
    //// Frames
    NSRect progressIndicatorFrame = self.bounds;
    
    //// Subframes
    NSRect activeProgressFrame = NSMakeRect(NSMinX(progressIndicatorFrame) + 6,
                                            NSMinY(progressIndicatorFrame) + 1,
                                            (self.bounds.size.width - 13) * self.doubleValue,
                                            31);

    //// Abstracted Attributes
    NSString* textContent = self.progressString;
    
    
    //// progressBarSheet
    {
        //// ProgressBar
        {
            //// Rounded Rectangle Drawing
            NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(progressIndicatorFrame) + 7.5, NSMinY(progressIndicatorFrame) + 2, NSWidth(progressIndicatorFrame) - 15, NSHeight(progressIndicatorFrame) - 4) xRadius: 4 yRadius: 4];
            [gradient drawInBezierPath: roundedRectanglePath angle: -90];
            
            ////// Rounded Rectangle Inner Shadow
            NSRect roundedRectangleBorderRect = NSInsetRect([roundedRectanglePath bounds], -whiteEdgeShadow.shadowBlurRadius, -whiteEdgeShadow.shadowBlurRadius);
            roundedRectangleBorderRect = NSOffsetRect(roundedRectangleBorderRect, -whiteEdgeShadow.shadowOffset.width, -whiteEdgeShadow.shadowOffset.height);
            roundedRectangleBorderRect = NSInsetRect(NSUnionRect(roundedRectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
            
            NSBezierPath* roundedRectangleNegativePath = [NSBezierPath bezierPathWithRect: roundedRectangleBorderRect];
            [roundedRectangleNegativePath appendBezierPath: roundedRectanglePath];
            [roundedRectangleNegativePath setWindingRule: NSEvenOddWindingRule];
            
            [NSGraphicsContext saveGraphicsState];
            {
                NSShadow* whiteEdgeShadowWithOffset = [whiteEdgeShadow copy];
                CGFloat xOffset = whiteEdgeShadowWithOffset.shadowOffset.width + round(roundedRectangleBorderRect.size.width);
                CGFloat yOffset = whiteEdgeShadowWithOffset.shadowOffset.height;
                whiteEdgeShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
                [whiteEdgeShadowWithOffset set];
                [[NSColor grayColor] setFill];
                [roundedRectanglePath addClip];
                NSAffineTransform* transform = [NSAffineTransform transform];
                [transform translateXBy: -round(roundedRectangleBorderRect.size.width) yBy: 0];
                [[transform transformBezierPath: roundedRectangleNegativePath] fill];
            }
            [NSGraphicsContext restoreGraphicsState];
            
            
            
            //// progreessTrack Drawing
            NSBezierPath* progreessTrackPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(progressIndicatorFrame) + 7.5, NSMinY(progressIndicatorFrame) + 2.5, NSWidth(progressIndicatorFrame) - 15, NSHeight(progressIndicatorFrame) - 4) xRadius: 3.5 yRadius: 3.5];
            [NSGraphicsContext saveGraphicsState];
            [whiteEdgeShadow set];
            [progressBackgroundColor setFill];
            [progreessTrackPath fill];
            [NSGraphicsContext restoreGraphicsState];
            
            [highlight setStroke];
            [progreessTrackPath setLineWidth: 1];
            [progreessTrackPath stroke];
            
            
            //// ProgressActive
            {
                //// progreessTrackActive Drawing
                NSBezierPath* progreessTrackActivePath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(activeProgressFrame) + 2, NSMinY(activeProgressFrame) + 2, NSWidth(activeProgressFrame) - 3, NSHeight(activeProgressFrame) - 4) xRadius: 3.5 yRadius: 3.5];
                [progressColor setFill];
                [progreessTrackActivePath fill];
                
                
                //// trackColorizer Drawing
                NSBezierPath* trackColorizerPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(activeProgressFrame) + 2, NSMinY(activeProgressFrame) + 2, NSWidth(activeProgressFrame) - 3, NSHeight(activeProgressFrame) - 4) xRadius: 3.5 yRadius: 3.5];
                [progressColor setFill];
                [trackColorizerPath fill];
            }
            
            
            //// Text Drawing
            NSRect textRect = NSMakeRect(NSMinX(progressIndicatorFrame) + 7, NSMinY(progressIndicatorFrame) + NSHeight(progressIndicatorFrame) - 23, NSWidth(progressIndicatorFrame) - 15, 14);
            NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [textStyle setAlignment: NSCenterTextAlignment];
            
            NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys: 
                                                [NSFont fontWithName: @"Helvetica" size: 12], NSFontAttributeName,
                                                fontColor, NSForegroundColorAttributeName,
                                                textStyle, NSParagraphStyleAttributeName, nil];
            
            [textContent drawInRect: NSInsetRect(NSOffsetRect(textRect, 0, 1), 8, 0) withAttributes: textFontAttributes];
        }
    }
}

@end

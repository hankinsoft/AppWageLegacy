//
//  NSImage+CGImage.m
//  AppWage
//
//  Created by Kyle Hankinson on 2/5/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "NSImage+CGImage.h"

@implementation NSImage (CGImage)

- (CGImageRef)CGImage
{
	NSSize size = [self size];
	CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
												   size.width,
												   size.height,
												   8 /*bitsPerComponent*/,
												   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
												   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
												   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
	[self drawInRect:NSMakeRect(0,0, size.width, size.height) fromRect:NSZeroRect/*sentinel, means "the whole thing*/ operation:NSCompositeCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
    
	CGImageRef cgImage = CGBitmapContextCreateImage(bitmapCtx);
	CGContextRelease(bitmapCtx);
	return cgImage;
}

@end

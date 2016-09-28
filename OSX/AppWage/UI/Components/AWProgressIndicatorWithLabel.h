//
//  AWProgressIndicatorWithLabel.h
//  AppWage
//
//  Created by Kyle Hankinson on 2/3/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWProgressIndicatorWithLabel : NSView

@property (nonatomic,copy)    NSString * progressString;
@property (nonatomic,assign)  CGFloat doubleValue;

@end

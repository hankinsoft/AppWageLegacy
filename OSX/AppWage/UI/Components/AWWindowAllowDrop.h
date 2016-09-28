//
//  AWWindowAllowDrop.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-17.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AWWindowAllowDropDelegate <NSObject>

- (BOOL) droppedURLS: (NSArray*) urls;

@end

@interface AWWindowAllowDrop : NSWindow

@property(nonatomic,weak) IBOutlet id<AWWindowAllowDropDelegate> fileDropDelegate;

@end

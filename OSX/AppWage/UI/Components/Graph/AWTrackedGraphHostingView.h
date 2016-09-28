//
//  AWTrackedGraphHostingView
//  AppWage
//
//  Created by Kyle Hankinson on 1/7/2014.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "CPTGraphHostingView.h"

@class AWTrackedGraphHostingView;

@protocol AWTrackedGraphHostingViewProtocol <NSObject>

- (void) trackedGraphHostingView: (AWTrackedGraphHostingView*) trackedGraphHostingView
                    mouseMovedTo: (NSPoint) mousePoint;

@end

@interface AWTrackedGraphHostingView : CPTGraphHostingView

@property(nonatomic,weak) id<AWTrackedGraphHostingViewProtocol> mouseDelegate;

@end

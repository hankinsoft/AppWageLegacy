//
//  HSOutlineView.h
//  OutlineView
//
//  Created by Kyle Hankinson on 2014-06-24.
//  Copyright (c) 2014 com.hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSTableRowView.h"
#import "HSOutlineViewWithMenu.h"

@class HSOutlineView;

@protocol HSOutlineViewDelegate <NSOutlineViewDelegate>

- (void) outlineViewSelectionWillChange: (HSOutlineView*) outlineView;
- (void) outlineViewCmdDown: (HSOutlineView*) outlineView;
- (void) outlineViewCmdRight: (HSOutlineView*) outlineView;

@end

@interface HSOutlineView : HSOutlineViewWithMenu

- (NSColor*) outlineViewColor;
- (NSColor*) mainTextColor;
- (NSColor*) detailTextColor: (BOOL) isSelected;

@property(nonatomic,assign) BOOL   isDark;
@property(nonatomic,weak)   IBOutlet id<HSOutlineViewDelegate> hsOutlineViewDelegate;

@end

//
//  FilterTableHeaderView.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AWFilterTableHeaderView;

@protocol AWFilterTableHeaderViewDelegate <NSObject>

- (void) filterTableHeaderView: (AWFilterTableHeaderView*) headerView
  clickedFilterButtonForColumn: (NSTableColumn*) column
                    filterRect: (NSRect) filterRect;

@end

@interface AWFilterTableHeaderView : NSTableHeaderView

@property(nonatomic,weak) id<AWFilterTableHeaderViewDelegate> delegate;

@end

//
//  OutlineViewWithMenu.h
//  SQL Server Professional
//
//  Created by Kyle Hankinson on 6/13/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol OutlineViewWithMenuDelegate<NSObject>
@required
-(NSMenu*) menuForEvent:(NSEvent*)evt;
@optional
- (void)tableViewDidRecieveDeleteKey: (NSTableView*) aTableView;
- (void)tableDidRecieveEnterOrSpaceKey: (NSTableView*) aTableView;
@end

@interface HSOutlineViewWithMenu : NSOutlineView
{
    
}

@property(nonatomic,assign) id <OutlineViewWithMenuDelegate> menuDelegate;

@end

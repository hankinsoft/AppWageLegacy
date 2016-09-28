//
//  FilterTableHeaderView.m
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import "AWFilterTableHeaderView.h"
#import "AWFilterTableHeaderCell.h"

@implementation AWFilterTableHeaderView

@synthesize delegate;

-(void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];

	NSInteger clickedColumn = [self columnAtPoint:location];
    if(-1 == clickedColumn) return;

    NSTableColumn * targetColumn = self.tableView.tableColumns[clickedColumn];
    if([targetColumn.headerCell isKindOfClass: [AWFilterTableHeaderCell class]])
    {
        NSRect headerRect = [self headerRectOfColumn: clickedColumn];

        float mouseOffset = location.x - headerRect.origin.x;
        if(mouseOffset <= 16)
        {
            NSRect filterRect = NSMakeRect(headerRect.origin.x,
                                           headerRect.origin.y,
                                           headerRect.size.height,
                                           16);

            [self.delegate filterTableHeaderView: self
                    clickedFilterButtonForColumn: targetColumn
                                      filterRect: filterRect];

            return;
        } // End of we clicked on the filter icon
    } // End of target class was a filterTableHeaderCell

    [super mouseDown: theEvent];
} // End of mouseDown

@end

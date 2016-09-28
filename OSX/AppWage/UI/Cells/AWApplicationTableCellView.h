//
//  ApplicationTableCellView.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/25/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWApplicationTableCellView : NSTableCellView
{
    
}

@property(nonatomic,retain) IBOutlet NSTextField         * appNameTextView;
@property(nonatomic,retain) IBOutlet NSTextField         * appDetailsTextView;
@property(nonatomic,retain) IBOutlet NSTextField         * unreadReviewsTextView;

@end

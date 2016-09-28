//
//  RankFilterViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-12.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AWRatingFilterViewController : NSViewController

- (BOOL) isFiltered;

@property(nonatomic,assign) BOOL didChange;

@end

//
//  ApplicationListTreeModel.h
//  AppWage
//
//  Created by Kyle Hankinson on 11/16/2013.
//  Copyright (c) 2013 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ApplicationListTreeEntryTypeUnspecified            = 0,
    ApplicationListTreeEntryTypeApplication            = 1,
    ApplicationListTreeEntryTypeProduct                = 2,

    ApplicationListTreeEntryTypeAllProducts            = 10
} ApplicationListTreeEntryType;


@interface AWApplicationListTreeEntry : NSObject

@property (nonatomic,retain) AWApplicationListTreeEntry         * parent;
@property (nonatomic,copy)   NSString                           * display;
@property (nonatomic,copy)   NSString                           * subDisplay;
@property (nonatomic,retain) NSArray                            * children;
@property (nonatomic,retain) NSImage                            * image;
@property (nonatomic,retain) id                                 representedObject;
@property (nonatomic,assign) ApplicationListTreeEntryType       representedType;
@property (nonatomic,assign) BOOL                               isHidden;

- (NSString*) identifier;

@end

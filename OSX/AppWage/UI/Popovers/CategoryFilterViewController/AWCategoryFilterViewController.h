//
//  CategoryFilterViewController.h
//  AppWage
//
//  Created by Kyle Hankinson on 2014-03-13.
//  Copyright (c) 2014 Hankinsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CategoryFilterEntry : NSObject

@property(nonatomic,copy) NSString * categoryName;
@property(nonatomic,copy) NSSet    * categoryIds;

@end

@interface AWCategoryFilterViewController : NSViewController

- (BOOL) isFiltered;
- (IBAction) onToggleAll: (id) sender;

@property(nonatomic,copy) NSArray * allCategories;
@property(nonatomic,copy) NSArray * selectedCategories;

@end

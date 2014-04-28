/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBKit.h"
#import <UIKit/UIKit.h>
#import "DBUITableViewDelegate.h"

@interface DBUITableViewDataSource : DBSelect <UITableViewDataSource>

@property (strong) id<DBUITableViewDelegate> delegate;

@property (strong) NSString * sectionName;

// Sections from Core Data results.
@property (readonly) NSArray * groups;

// Fetch a specific object via index path.
- (NSManagedObject *) fetchAtIndexPath: (NSIndexPath *) indexPath;

// Refresh an object changed in another context.
- (void) refresh: (NSManagedObject *) object;

@end

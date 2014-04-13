/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBStatement.h"

// Select operation.
@interface DBSelect : DBStatement

// Control structures for select operation.
@property (assign) NSUInteger batchSize;

@property (assign) NSRange range;

// Array of NSSortDescriptor.
@property (strong) NSArray * orderBy;

// Section in Core Data.
@property (strong) NSString * groupBy;

// Sections from Core Data results.
@property (readonly) NSArray * groups;

// A delegate for asynchronous updates to the fetch controller.
@property (strong) id<NSFetchedResultsControllerDelegate> fetchDelegate;

// Fetch a single object from the results.
- (NSManagedObject *) fetch;

// Fetch all objects from the results.
- (NSArray *) fetchAll;

// Fetch a specific object via index path.
- (NSManagedObject *) fetchAtIndexPath: (NSIndexPath *) indexPath;

// Refresh an object changed in another context.
- (void) refresh: (NSManagedObject *) object;

// Return the number of objects that would be returned by a fetchAll.
- (NSUInteger) count;

@end


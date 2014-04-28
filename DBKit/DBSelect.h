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

// Distinct results?
@property (assign) BOOL distinct;

// Columns to fetch.
@property (strong) NSArray * columns;

// Exclude children.
@property (assign) BOOL excludeChildren;

// Array of NSSortDescriptor.
@property (strong) NSArray * orderBy;

// Range results.
@property (assign) NSRange range;

// Results of the select.
@property (readonly) NSArray * objects;

// Enumerate the fetched results.
@property (readonly) NSEnumerator * objectEnumerator;

// Return the number of objects that would be returned by a fetchAll.
- (NSUInteger) count;

// Fetch a single object from the results.
- (NSManagedObject *) fetch;

// Fetch all objects from the results.
- (NSArray *) fetchAll;

@end


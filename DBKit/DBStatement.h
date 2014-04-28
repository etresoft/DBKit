/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

// Lightweight statement class to be used as a base class for operations.
@interface DBStatement : NSObject

@property (strong, nonatomic)
  NSManagedObjectContext * managedObjectContext;

// Map entity names to table.
@property (strong) NSString * table;

// Predicate for selecting matching objects.
@property (strong) NSPredicate * where;

// Predicate may need to be created in two steps.
@property (strong) NSString * whereString;

// Constructor.
- (id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

// Execute the statement.
- (BOOL) execute;
- (BOOL) execute: (NSError **) error;

@end


/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

// Lightweight statement class to be used as a base class for operations.
@interface DBStatement : NSObject

@property (strong, nonatomic)
  NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic)
  NSFetchedResultsController * fetchedResultsController;

// Map entity names to table.
@property (strong) NSString * table;

// Predicate for selecting matching objects.
@property (strong) NSPredicate * where;

// Parameters that can be bound.
@property (strong) NSDictionary * parameters;

// Constructor.
- (id) initWithManagedObjectContext: (NSManagedObjectContext *) context;

// Bind parameters for later execution.
- (void) bindParameters: (NSDictionary *) parameters;

// Execute the statement.
- (BOOL) execute;
- (BOOL) execute: (NSError **) error;

@end


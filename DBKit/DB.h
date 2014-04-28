/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import <CoreData/CoreData.h>

@class DBStatement;
@class DBSelect;
@class DBInsert;
@class DBUpdate;
@class DBDelete;

// Top-level database class. One per database.
@interface DB : NSObject

// Allow access to Core Data structures if necessary.
@property (readonly, strong)
  NSManagedObjectContext * persistentObjectContext;
@property (readonly, strong)
  NSManagedObjectContext * managedObjectContext;
@property (readonly, strong)
  NSManagedObjectModel * managedObjectModel;
@property (readonly, strong)
  NSPersistentStoreCoordinator * persistentStoreCoordinator;

// A higher-level interface.
@property (strong) NSString * name;

// Factory constructor.
+ (DB *) databaseWithName: (NSString *) name;

// The current database.
+ (DB *) current;

// Constructor.
- (id) initWithName: (NSString *) databaseName;

// Set the current database.
- (void) use;

// Create statements.
- (DBSelect *) prepareSelectFrom: (NSString *) table;
- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where;
- (DBSelect *) prepareSelectFrom: (NSString *) table
  orderBy: (NSArray *) orderBy;
- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  orderBy: (NSArray *) orderBy;

- (DBInsert *) prepareInsertInto: (NSString *) table;

- (DBUpdate *) prepareUpdate;
- (DBUpdate *) prepareUpdate: (NSString *) table;
- (DBUpdate *) prepareUpdate: (NSString *) table
  where: (NSPredicate *) where;

- (DBDelete *) prepareDelete;
- (DBDelete *) prepareDeleteFrom: (NSString *) table;
- (DBDelete *) prepareDeleteFrom: (NSString *) table
  where: (NSPredicate *) where;

- (DBStatement *) prepare: (NSString *) sql;
  
@end


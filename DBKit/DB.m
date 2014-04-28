/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DB.h"
#import "DBStatement.h"
#import "DBSelect.h"
#import "DBInsert.h"
#import "DBUpdate.h"
#import "DBDelete.h"

// Hack to work on either iOS or OSX.
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define kApplicationWillTerminate UIApplicationWillTerminateNotification
#else
#import <Cocoa/Cocoa.h>
#define kApplicationWillTerminate NSApplicationWillTerminateNotification
#endif

// The current database.
static DB * current = nil;

// Top-level database class. One per database.

@implementation DB

#pragma mark - Properties

// Allow access to Core Data structures if necessary.
@synthesize persistentObjectContext;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

// A higher-level interface.
@synthesize name;

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the
// persistent store coordinator for the application.
- (NSManagedObjectContext *) managedObjectContext
  {
  if(managedObjectContext)
    return managedObjectContext;
  
  NSPersistentStoreCoordinator * coordinator =
    [self persistentStoreCoordinator];
    
  if(coordinator)
    {
    // Do my persistence in the background.
    persistentObjectContext = 
      [[NSManagedObjectContext alloc]
        initWithConcurrencyType: NSPrivateQueueConcurrencyType];

    if(persistentObjectContext)
      {
      [persistentObjectContext setPersistentStoreCoordinator: coordinator];
      
      // Set my main managed object context to be a child of the
      // persistent object context.
      managedObjectContext =
        [[NSManagedObjectContext alloc]
          initWithConcurrencyType: NSMainQueueConcurrencyType];

      if(managedObjectContext)
        {
        [managedObjectContext setParentContext: persistentObjectContext];
        
        // Persist on exit from either iOS or OSX.
        [[NSNotificationCenter defaultCenter]
          addObserver: self
          selector: @selector(applicationWillTerminate)
          name: kApplicationWillTerminate
          object: nil];

        // Push any saves to the persistent object context.
        [[NSNotificationCenter defaultCenter]
          addObserver: self
          selector: @selector(savedContext:)
          name: NSManagedObjectContextDidSaveNotification
          object: managedObjectContext];
        }
      }
    }
  
  return managedObjectContext;
  }

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's
// model.
- (NSManagedObjectModel *) managedObjectModel
  {
  if(managedObjectModel)
    return managedObjectModel;

  NSURL * modelURL =
    [[NSBundle mainBundle]
      URLForResource: name withExtension: @"momd"];
    
  managedObjectModel =
    [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    
  return managedObjectModel;
  }

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the
// application's store added to it.
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
  {
  if(persistentStoreCoordinator)
    return persistentStoreCoordinator;
    
  NSURL * storeURL =
    [[self applicationDocumentsDirectory]
      URLByAppendingPathComponent:
        [NSString stringWithFormat: @"%@.sqlite", name]];
    
  NSError * error = nil;
  
  persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc]
      initWithManagedObjectModel: [self managedObjectModel]];
    
  NSPersistentStore * store =
    [persistentStoreCoordinator
      addPersistentStoreWithType: NSSQLiteStoreType
      configuration: nil
      URL: storeURL
      options: nil
      error: & error];
    
  if(!store)
    {
    /* Replace this implementation with code to handle the error
       appropriately.
     
       abort() causes the application to generate a crash log and terminate.
       You should not use this function in a shipping application, although
       it may be useful during development.
     
       Typical reasons for an error here include:
       * The persistent store is not accessible;
       * The schema for the persistent store is incompatible with current
         managed object model.
       Check the error message to determine what the actual problem was.
     
     
       If the persistent store is not accessible, there is typically
       something wrong with the file path. Often, a file URL is pointing 
       into the application's resources directory instead of a writeable 
       directory.
     
       If you encounter schema incompatibility errors during development, 
       you can reduce their frequency by:
       * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
       * Performing automatic lightweight migration by passing the following 
         dictionary as the options parameter:
         @{
           NSMigratePersistentStoresAutomaticallyOption: @YES, 
           NSInferMappingModelAutomaticallyOption: @YES
         }
     
       Lightweight migration will only work for a limited set of schema
       changes; consult "Core Data Model Versioning and Data Migration
       Programming Guide" for details. */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
    }
    
  return persistentStoreCoordinator;
  }

#pragma mark - Housekeeping

// Factory constructor.
+ (DB *) databaseWithName: (NSString *) name
  {
  static NSMutableDictionary * databases = nil;
  
  static dispatch_once_t onceToken;
  
  dispatch_once(
    & onceToken,
    ^{
      databases = [[NSMutableDictionary alloc] init];
    });
    
  DB * database = nil;
  
  @synchronized(databases)
    {
    database = databases[name];
    
    if(!database)
      {
      database = [[DB alloc] initWithName: name];
      
      databases[name] = database;
      }
    }
    
  return database;
  }

// The current database.
+ (DB *) current
  {
  return current;
  }

// Constructor
- (id) initWithName: (NSString *) databaseName
  {
  self = [super init];
  
  if(self)
    name = databaseName;
    
  return self;
  }

// Set the current database.
- (void) use
  {
  current = self;
  }

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *) applicationDocumentsDirectory
  {
  return
    [[[NSFileManager defaultManager]
      URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask]
      lastObject];
  }

#pragma mark - Notifications

- (void) applicationWillTerminate
  {
  if(self.managedObjectContext)
    [[NSNotificationCenter defaultCenter]
      removeObserver: self
      name: NSManagedObjectContextDidSaveNotification
      object: self.managedObjectContext];
  
  // Saves changes in the application's managed object context before the
  // application terminates.
  [self saveContext: YES];
  }

#pragma mark - Saving.

- (void) saveContext: (BOOL) wait
  {
  if(!self.managedObjectContext)
    return;
    
  if([self.managedObjectContext hasChanges])
    {
    NSError * error = nil;

    if(![self.managedObjectContext save: & error])
      {
      // Replace this implementation with code to handle the error
      // appropriately.
      // abort() causes the application to generate a crash log and
      // terminate. You should not use this function in a shipping
      // application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      }
    }

  void (^savePersistent)(void) =
    ^{
      NSError * error = nil;

      if(![self.persistentObjectContext save: & error])
        {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    };
    
  if([self.persistentObjectContext hasChanges])
    {
    if(wait)
      [self.persistentObjectContext performBlockAndWait: savePersistent];
    else
      [self.persistentObjectContext performBlock: savePersistent];
    }
  }

- (void) savedContext: (NSNotification *) notification
  {
  [self saveContext: NO];
  }

#pragma mark - Create statements

// Create statements.
- (DBSelect *) prepareSelectFrom: (NSString *) table
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  orderBy: (NSArray *) orderBy
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.orderBy = orderBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  orderBy: (NSArray *) orderBy
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  select.orderBy = orderBy;
  
  return select;
  }

- (DBInsert *) prepareInsertInto: (NSString *) table
  {
  DBInsert * insert =
    [[DBInsert alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  insert.table = table;
  
  return insert;
  }

- (DBUpdate *) prepareUpdate
  {
  DBUpdate * update =
    [[DBUpdate alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  return update;
  }

- (DBUpdate *) prepareUpdate: (NSString *) table
  {
  DBUpdate * update =
    [[DBUpdate alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  update.table = table;
  
  return update;
  }

- (DBUpdate *) prepareUpdate: (NSString *) table
  where: (NSPredicate *) where;
  {
  DBUpdate * update =
    [[DBUpdate alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  update.table = table;
  update.where = where;
  
  return update;
  }

- (DBDelete *) prepareDelete
  {
  DBDelete * deleteStatement =
    [[DBDelete alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  return deleteStatement;
  }

- (DBDelete *) prepareDeleteFrom: (NSString *) table
  {
  DBDelete * deleteStatement =
    [[DBDelete alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  deleteStatement.table = table;
  
  return deleteStatement;
  }

- (DBDelete *) prepareDeleteFrom: (NSString *) table
  where: (NSPredicate *) where;
  {
  DBDelete * deleteStatement =
    [[DBDelete alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  deleteStatement.table = table;
  deleteStatement.where = where;
  
  return deleteStatement;
  }

// Create a statement from SQL.
- (DBStatement *) prepare: (NSString *) sql
  {
  NSScanner * scanner = [NSScanner scannerWithString: sql];
  
  // Look at the first word to choose what statement to create.
  if([scanner scanString: @"select" intoString: NULL])
    return [self parseSelect: scanner];
  
  if([scanner scanString: @"insert" intoString: NULL])
    return [self parseInsert: scanner];

  if([scanner scanString: @"update" intoString: NULL])
    return [self parseUpdate: scanner];

  if([scanner scanString: @"delete" intoString: NULL])
    return [self parseDelete: scanner];

  return nil;
  }

// Parse a select statement.
- (DBSelect *) parseSelect: (NSScanner *) scanner
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];

  // Handle distinct.
  if([scanner scanString: @"distinct" intoString: NULL])
    select.distinct = YES;
    
  // All columens - the default.
  if([scanner scanString: @"*" intoString: NULL])
    {
    }
    
  // Specific columns.
  else if([scanner scanString: @"(" intoString: NULL])
    {
    NSString * columnNames = nil;
    
    if([scanner scanUpToString: @")" intoString: & columnNames])
      select.columns = [columnNames componentsSeparatedByString: @","];
    else
      return nil;
    }
    
  else
    return nil;

  // Get the table.
  if(![scanner scanString: @"from" intoString: NULL])
    return nil;
    
  NSString * table;
  
  BOOL hasTable =
    [scanner
      scanUpToCharactersFromSet:
        [NSCharacterSet whitespaceAndNewlineCharacterSet]
      intoString: & table];
    
  if(!hasTable)
    return nil;
    
  select.table = table;
  
  // All related tables are joined by default.
  
  // Get clauses.
  NSArray * clauses =
    @[
      @"where",
      @"group by",
      @"order by",
      @"limit",
      @"offset"
    ];
  
  NSMutableDictionary * clauseRanges = [NSMutableDictionary dictionary];
  
  // Find each clause in the string, possibly in any order.
  NSUInteger location = [scanner scanLocation];
  NSUInteger length = [[scanner string] length];
  
  // Find each clause start location.
  for(NSString * clause in clauses)
    {
    [scanner setScanLocation: location];
    
    if([scanner scanString: clause intoString: NULL])
      {
      NSRange range =
        NSMakeRange(location, length - [scanner scanLocation]);
        
      clauseRanges[clause] = [NSValue valueWithRange: range];
      }
    }
  
  // Now find each clause end location.
  for(NSString * clause in clauseRanges)
    {
    NSRange range = [clauseRanges[clause] rangeValue];
    
    for(NSString * otherClause in clauseRanges)
      {
      NSRange otherRange =
        [clauseRanges[otherClause] rangeValue];
      
      if((otherRange.location > range.location) &&
        (otherRange.length < range.length))
        range.length = otherRange.length;
      }
    }
    
  // Parse the clauses.
  for(NSString * clause in clauseRanges)
    {
    NSRange range = [clauseRanges[clause] rangeValue];

    NSString * string = [[scanner string] substringWithRange: range];
    
    if([clause isEqualToString: @"where"])
      [self parseWhere: string statement: select];
    
    else if([clause isEqualToString: @"order by" ])
      [self parseOrderBy: string select: select];

    else if([clause isEqualToString: @"limit"])
      [self parseLimit: string select: select];

    else if([clause isEqualToString: @"offset"])
      [self parseOffset: string select: select];
    }
    
  return select;
  }

- (void) parseWhere: (NSString *) string
  statement: (DBStatement *) statement
  {
  statement.where = [NSPredicate predicateWithFormat: string];
  }

- (void) parseOrderBy: (NSString *) string select: (DBSelect *) select
  {
  select.orderBy = [string componentsSeparatedByString: @","];
  }

- (void) parseLimit: (NSString *) string select: (DBSelect *) select
  {
  NSString * number = [string lowercaseString];
  
  if([number isEqualToString: @"all"])
    return;
    
  NSInteger value = [number integerValue];
  
  if(value > 0)
    {
    NSRange range = select.range;
    
    range.length = value;
    
    select.range = range;
    }
  }

- (void) parseOffset: (NSString *) string select: (DBSelect *) select
  {
  NSInteger value = [string integerValue];
  
  if(value > 0)
    {
    NSRange range = select.range;
    
    range.location = value;
    
    select.range = range;
    }
  }

// Parse an insert statement.
- (DBInsert *) parseInsert: (NSScanner *) scanner
  {
  return nil;
  }

// Parse an update statement.
- (DBUpdate *) parseUpdate: (NSScanner *) scanner
  {
  return nil;
  }

// Parse a delete statement.
- (DBDelete *) parseDelete: (NSScanner *) scanner
  {
  return nil;
  }

@end

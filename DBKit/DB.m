/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <NSApplication/NSApplication.h>
#endif

#import "DB.h"
#import "DBStatement.h"
#import "DBSelect.h"
#import "DBInsert.h"
#import "DBUpdate.h"
#import "DBDelete.h"

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
    persistentObjectContext = 
      [[NSManagedObjectContext alloc]
        initWithConcurrencyType: NSPrivateQueueConcurrencyType];

    if(persistentObjectContext)
      {
      [persistentObjectContext setPersistentStoreCoordinator: coordinator];
      
      managedObjectContext =
        [[NSManagedObjectContext alloc]
          initWithConcurrencyType: NSMainQueueConcurrencyType];

      if(managedObjectContext)
        {
        [managedObjectContext setParentContext: persistentObjectContext];
        
        [[NSNotificationCenter defaultCenter]
          addObserver: self
          selector: @selector(applicationWillTerminate)
          name: UIApplicationWillTerminateNotification
          object: nil];

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

// Constructor
- (id) initWithName: (NSString *) databaseName
  {
  self = [super init];
  
  if(self)
    name = databaseName;
    
  return self;
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
  where: (NSPredicate *) where;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  orderBy: (NSArray *) orderBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.orderBy = orderBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  groupBy: (NSString *) groupBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.groupBy = groupBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  groupBy: (NSString *) groupBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  select.groupBy = groupBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  orderBy: (NSArray *) orderBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  select.orderBy = orderBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  where: (NSPredicate *) where
  groupBy: (NSString *) groupBy
  orderBy: (NSArray *) orderBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.where = where;
  select.groupBy = groupBy;
  select.orderBy = orderBy;
  
  return select;
  }

- (DBSelect *) prepareSelectFrom: (NSString *) table
  groupBy: (NSString *) groupBy
  orderBy: (NSArray *) orderBy;
  {
  DBSelect * select =
    [[DBSelect alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  select.table = table;
  select.groupBy = groupBy;
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

- (DBUpdate *) prepareUpdateTo: (NSArray *) objects
  {
  DBUpdate * update =
    [[DBUpdate alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  for(NSManagedObject * object in objects)
    [update addObject: object];
  
  return update;
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

- (DBDelete *) prepareDeleteOf: (NSArray *) objects
  {
  DBDelete * deleteStatement =
    [[DBDelete alloc]
      initWithManagedObjectContext: self.managedObjectContext];
    
  for(NSManagedObject * object in objects)
    [deleteStatement addObject: object];
  
  return deleteStatement;
  }

/* - (DBStatement *) prepare: (NSString *) sql
  {
  NSScanner * scanner = [NSScanner scannerWithString: sql];
  
  NSString * sqlStatement = [sql lowercaseString];
  
  // Required statements.
  BOOL found;
  
  if([sqlStatement hasPrefix: @"select"])
    {
    found = [scanner scanString: @"select" intoString: NULL];
    found = [scanner scanString: @"*" intoString: NULL];
  
    if(!found)
      return nil;

    found = [scanner scanString: @"from" intoString: NULL];
  
    if(!found)
      return nil;
    }
  else if([[operation lowercaseString] isEqualToString: @"insert"])
    {
    found = [scanner scanString: @"into" intoString: NULL];
  
    if(!found)
      return nil;
    }
  else if([[operation lowercaseString] isEqualToString: @"delete"])
    {
    found = [scanner scanString: @"from" intoString: NULL];
  
    if(!found)
      return nil;
    }
  
  NSString * table = nil;
  
  found =
    [scanner
      scanUpToCharactersFromSet:
        [NSCharacterSet whitespaceAndNewlineCharacterSet]
      intoString: & table];
  
  if(!found)
    return nil;

  // Optional clauses.
  if([[operation lowercaseString] isEqualToString: @"select"])
    {
    [scanner scanUpToString: @"where" intoString: NULL];
    }
  else if([[operation lowercaseString] isEqualToString: @"update"])
    {
    found = [scanner scanString: @"values (*)" intoString: NULL];
  
    NSMutableArray * propertiesToSet =
      found
        ? nil
        : [NSMutableArray array];
    
    if(!found)
      {
      found = [scanner scanString: @"set" intoString: NULL];

      if(!found)
        return nil;
        
      NSString * properties = NULL;
      
      [scanner scanUpToString: @"where" intoString: & properties];
      
      NSArray * propertyList =
        [properties componentsSeparatedByString: @","];
        
      for(NSString * property in propertyList)
        {
        NSArray * keyValuePair =
          [property componentsSeparatedByString: @"="];
          
        if([keyValuePair count] < 2)
          return nil;
          
        NSString * propertyName =
          [keyValuePair[0]
            stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString * placeholder =
          [keyValuePair[1]
            stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
          
        if(![placeholder isEqualToString: @"?"])
          return nil;
          
        [propertiesToSet addObject: propertyName];
        }
      }
      
    DBUpdate * updateStatement = [[DBUpdate alloc] init];
    
    updateStatement.properties = [propertiesToSet copy];
    
    return updateStatement;
    }
  else if([[operation lowercaseString] isEqualToString: @"delete"])
    {
    [scanner scanUpToString: @"where" intoString: NULL];
    }

  return nil;
  } */

@end

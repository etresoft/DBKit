/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBSelect.h"

@interface DBSelect ()

@property (readonly) NSEnumerator * enumerator;

@end

// Select operation.
@implementation DBSelect

// Control structures for select operations.
@synthesize orderBy;
@synthesize groupBy;

@dynamic groups;

@synthesize enumerator;

- (NSArray *) groups
  {
  return self.fetchedResultsController.sections;
  }

- (NSEnumerator *) enumerator
  {
  if(!enumerator)
    enumerator =
      [self.fetchedResultsController.fetchedObjects objectEnumerator];
    
  return enumerator;
  }

// Execute the select.
- (BOOL) execute: (NSError **) error
  {
  NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
  
  // Fetch all Articles.
  NSEntityDescription * entity =
    [NSEntityDescription
      entityForName: self.table
      inManagedObjectContext: self.managedObjectContext];
    
  [fetchRequest setEntity: entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize: self.batchSize];
  [fetchRequest setFetchOffset: self.range.location];
  [fetchRequest setFetchLimit: self.range.length];
  
  if(self.orderBy)
    [fetchRequest setSortDescriptors: self.orderBy];
    
  if(self.where)
    [fetchRequest setPredicate: self.where];
    
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  self.fetchedResultsController =
    [[NSFetchedResultsController alloc]
      initWithFetchRequest: fetchRequest
      managedObjectContext: self.managedObjectContext
      sectionNameKeyPath: self.groupBy
      cacheName: nil];
    
  self.fetchedResultsController.delegate = self.fetchDelegate;
  
  if(![self.fetchedResultsController performFetch: error])
    {
    // Replace this implementation with code to handle the error
    // appropriately.
    // abort() causes the application to generate a crash log and
    // terminate. You should not use this function in a shipping
    // application, although it may be useful during development.
    if(*error)
      NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    
    return NO;
    }
    
  return YES;
  }

// Fetch a single object from the results.
- (NSManagedObject *) fetch
  {
  return [self.enumerator nextObject];
  }

// Fetch all objects from the results.
- (NSArray *) fetchAll
  {
  return self.fetchedResultsController.fetchedObjects;
  }

// Fetch a specific object via index path.
- (NSManagedObject *) fetchAtIndexPath: (NSIndexPath *) indexPath
  {
  return [self.fetchedResultsController objectAtIndexPath: indexPath];
  }

// Refresh an object changed in another context.
- (void) refresh: (NSManagedObject *) object
  {
  [self.managedObjectContext refreshObject: object mergeChanges: YES];
  }

// Return the number of objects that would be returned by a fetchAll.
- (NSUInteger) count
  {
  NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];

  NSEntityDescription * entity =
    [NSEntityDescription entityForName: self.table
      inManagedObjectContext: self.managedObjectContext];

  [fetchRequest setEntity: entity];

  // Omit subentities. Default is YES (i.e. include subentities)
  [fetchRequest setIncludesSubentities: NO];

  [fetchRequest setEntity: entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize: self.batchSize];
  [fetchRequest setFetchOffset: self.range.location];
  [fetchRequest setFetchLimit: self.range.length];
  
  if(self.orderBy)
    [fetchRequest setSortDescriptors: self.orderBy];
    
  if(self.where)
    [fetchRequest setPredicate: self.where];

  NSError * error;

  return
    [self.managedObjectContext
      countForFetchRequest: fetchRequest error: & error];
  }

@end

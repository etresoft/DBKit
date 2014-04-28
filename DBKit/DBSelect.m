/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBSelect.h"

// Select operation.
@implementation DBSelect
  {
  NSArray * objects;
  }

@dynamic objects;

@synthesize objectEnumerator;

- (NSArray *) objects
  {
  return objects;
  }

- (NSEnumerator *) objectEnumerator
  {
  if(!objectEnumerator)
    objectEnumerator =
      [self.objects objectEnumerator];
    
  return objectEnumerator;
  }

// Execute the select.
- (BOOL) execute: (NSError **) error
  {
  NSFetchRequest * fetchRequest = [self setupFetchRequest];
    
  objects =
    [self.managedObjectContext
      executeFetchRequest: fetchRequest error: error];

  return self.objects != nil;
  }

// Return the number of objects that would be returned by a fetchAll.
- (NSUInteger) count
  {
  NSFetchRequest * fetchRequest = [self setupFetchRequest];

  // Omit subentities. Default is YES (i.e. include subentities)
  [fetchRequest setIncludesSubentities: NO];

  NSError * error;

  return
    [self.managedObjectContext
      countForFetchRequest: fetchRequest error: & error];
  }

// Fetch a single object from the results.
- (NSManagedObject *) fetch
  {
  return [self.objectEnumerator nextObject];
  }

// Fetch all objects from the results.
- (NSArray *) fetchAll
  {
  return [self.objects copy];
  }

- (NSFetchRequest *) setupFetchRequest
  {
  NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];

  NSEntityDescription * entity =
    [NSEntityDescription
      entityForName: self.table
      inManagedObjectContext: self.managedObjectContext];

  [fetchRequest setEntity: entity];
  
  // Set the batch size to a suitable number.
  [fetchRequest setFetchBatchSize: self.batchSize];
  
  if(self.distinct)
    [fetchRequest setReturnsDistinctResults: self.distinct];
    
  if(self.columns)
    [fetchRequest setPropertiesToFetch: self.columns];
    
  if(self.excludeChildren)
    [fetchRequest setIncludesSubentities: NO];
    
  if(self.orderBy)
    [fetchRequest setSortDescriptors: self.orderBy];
    
  if(self.where)
    [fetchRequest setPredicate: self.where];
    
  if(self.range.location)
    [fetchRequest setFetchOffset: self.range.location];
  
  if(self.range.length)
    [fetchRequest setFetchLimit: self.range.length];

  return fetchRequest;
  }

@end

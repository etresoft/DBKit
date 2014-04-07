/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBUpdate.h"

@implementation DBUpdate

// Execute the insert with previously bound parameters.
- (BOOL) execute
  {
  return [self executeParameters: self.parameters error: NULL];
  }

// Execute the insert with previously bound parameters.
- (BOOL) execute: (NSError **) error
  {
  return [self executeParameters: self.parameters error: error];
  }

// Execute against a specific object.
- (BOOL) executeAgainst: (NSArray *) objectsToUpdate
  {
  // Make sure these are faulted into the mutating context.
  for(NSManagedObject * object in objectsToUpdate)
    [self addObject: object];
   
  return YES;
  }

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  error: (NSError **) error
  {
  if([self.objects count])
    return YES;
    
  NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
  
  // Fetch all Articles.
  NSEntityDescription * entity =
    [NSEntityDescription
      entityForName: self.table
      inManagedObjectContext: self.managedObjectContext];
    
  [fetchRequest setEntity: entity];
  
  if(self.where)
    [fetchRequest setPredicate: self.where];
    
  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  self.fetchedResultsController =
    [[NSFetchedResultsController alloc]
      initWithFetchRequest: fetchRequest
      managedObjectContext: self.managedObjectContext
      sectionNameKeyPath: nil
      cacheName: nil];
    
  if(![self.fetchedResultsController performFetch: error])
    {
    // Replace this implementation with code to handle the error
    // appropriately.
    // abort() causes the application to generate a crash log and
    // terminate. You should not use this function in a shipping
    // application, although it may be useful during development.
    if(error)
      NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    
    return NO;
    }
    
  for(
    NSManagedObject * object
    in
    self.fetchedResultsController.fetchedObjects)
    {
    [self.objects addObject: object];
    
    for(NSString * key in parameters)
      [object setPrimitiveValue: parameters[key] forKey: key];    
    }
    
  return YES;
  }

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  {
  return [self executeParameters: parameters error: NULL];
  }

@end

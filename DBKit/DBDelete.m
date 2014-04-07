/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBDelete.h"

@implementation DBDelete

// Execute the select.
- (BOOL) execute: (NSError **) error
  {
  if([self.objects count])
    {
    for(NSManagedObject * object in self.objects)
      [self.managedObjectContext deleteObject: object];
    
    return YES;
    }
    
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
    NSManagedObject * fetchedObject
    in
    self.fetchedResultsController.fetchedObjects)
    {
    [self.objects addObject: fetchedObject];
    
    [self.managedObjectContext deleteObject: fetchedObject];
    }
    
  return YES;
  }

// Execute against a specific object.
- (BOOL) executeAgainst: (NSArray *) objectsToDelete
  {
  // Make sure these are faulted into the mutating context.
  for(NSManagedObject * object in objectsToDelete)
    [self addObject: object];
   
  return YES;
  }

@end

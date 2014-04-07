/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBInsert.h"

@implementation DBInsert

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

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  error: (NSError **) error
  {
  NSManagedObject * insertedObject =
    [NSEntityDescription
      insertNewObjectForEntityForName: self.table
      inManagedObjectContext: self.managedObjectContext];
    
  for(NSString * key in parameters)
    [insertedObject setPrimitiveValue: parameters[key] forKey: key];
    
  [self.objects addObject: insertedObject];
  
  return YES;
  }

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  {
  return [self executeParameters: parameters error: NULL];
  }

@end

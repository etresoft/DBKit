/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@implementation DBMutatingStatement

// Constructor.
- (id) initWithManagedObjectContext: (NSManagedObjectContext *) context
  {
  // Create a new managed object context for the scratch pad; set its
  // parent to the passed in context.
  NSManagedObjectContext * editingContext =
    [[NSManagedObjectContext alloc]
      initWithConcurrencyType: NSPrivateQueueConcurrencyType];
    
  [editingContext setParentContext: context];

  self = [super initWithManagedObjectContext: editingContext];
  
  return self;
  }

// Commit changes.
- (BOOL) commit
  {
  return [self commit: NULL];
  }

- (BOOL) commit: (NSError **) error
  {
  if(![self.managedObjectContext save: error])
    {
    if(error && *error)
      NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);

    return NO;
    }
    
  if(![self.managedObjectContext.parentContext save: error])
    {
    if(error && *error)
      NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);

    return NO;
    }

  return YES;
  }

@end

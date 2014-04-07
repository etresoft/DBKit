/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@implementation DBMutatingStatement

@synthesize objects;

- (NSMutableArray *) objects
  {
  if(!objects)
    objects = [[NSMutableArray alloc] init];
    
  return objects;
  }

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

// Add an object. This will fault the object into the mutating context
// so return the mutable object as well as adding it to the internal set.
- (NSManagedObject *) addObject: (NSManagedObject *) objectToAdd
  {
  NSManagedObject * object =
    [self.managedObjectContext objectWithID: objectToAdd.objectID];
    
  [self.objects addObject: object];
  
  return object;
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

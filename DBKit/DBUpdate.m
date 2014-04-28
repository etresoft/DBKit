/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBUpdate.h"

@implementation DBUpdate

// Update an object by faulting into the updating context.
- (NSManagedObject *) update: (NSManagedObject *) object;
  {
  return [self.managedObjectContext objectWithID:[object objectID]];
  }

@end

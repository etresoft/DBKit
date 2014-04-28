/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBDelete.h"

@implementation DBDelete

// Delete an object.
- (void) delete: (NSManagedObject *) object;
  {
  [self.managedObjectContext deleteObject: object];
  }

@end

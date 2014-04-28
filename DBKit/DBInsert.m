/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBInsert.h"

@implementation DBInsert

// Insert an object into the inserting context.
- (NSManagedObject *) insert
  {
  return
    [NSEntityDescription
      insertNewObjectForEntityForName: self.table
      inManagedObjectContext: self.managedObjectContext];
  }

@end

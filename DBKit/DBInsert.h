/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@interface DBInsert : DBMutatingStatement

// Insert an object into the inserting context.
- (NSManagedObject *) insert;

@end

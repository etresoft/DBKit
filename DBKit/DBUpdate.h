/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@interface DBUpdate : DBMutatingStatement

// Update an object by faulting into the updating context.
- (NSManagedObject *) update: (NSManagedObject *) object;

@end


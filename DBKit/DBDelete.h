/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@interface DBDelete : DBMutatingStatement

// Delete an object.
- (void) delete: (NSManagedObject *) object;

@end

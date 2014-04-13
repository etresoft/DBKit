/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@interface DBDelete : DBMutatingStatement

// Execute against specific objects.
- (BOOL) executeAgainst: (NSArray *) objectsToDelete;

@end

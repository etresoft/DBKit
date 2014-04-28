/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBStatement.h"

@interface DBMutatingStatement : DBStatement

// Commit changes.
- (BOOL) commit;
- (BOOL) commit: (NSError **) error;

@end

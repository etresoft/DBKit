/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBMutatingStatement.h"

@interface DBUpdate : DBMutatingStatement

// Execute against specific objects.
- (BOOL) executeAgainst: (NSArray *) objectsToUpdate;

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters;

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  error: (NSError **) error;

@end


/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import <Foundation/Foundation.h>

#import "DBMutatingStatement.h"

@interface DBInsert : DBMutatingStatement

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters;

// Execute the insert against a set of parameters.
- (BOOL) executeParameters: (NSDictionary *) parameters
  error: (NSError **) error;

@end

/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import <Foundation/Foundation.h>

#import "DBStatement.h"

@interface DBMutatingStatement : DBStatement

// The objects being mutated.
@property (readonly) NSMutableArray * objects;

// Add an object. This will fault the object into the mutating context
// so return the mutable object as well as adding it to the internal array.
- (NSManagedObject *) addObject: (NSManagedObject *) objectToAdd;

// Commit changes.
- (BOOL) commit;
- (BOOL) commit: (NSError **) error;

@end

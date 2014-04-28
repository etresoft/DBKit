/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBStatement.h"

// Lightweight statement class to be used as a base class for operations.
@implementation DBStatement

#pragma mark - Properties

// Allow access to Core Data structures if necessary.
@synthesize managedObjectContext;

#pragma mark - Housekeeping

// Constructor.
- (id) initWithManagedObjectContext: (NSManagedObjectContext *) context
  {
  self = [super init];
  
  if(self)
    managedObjectContext = context;
    
  return self;
  }

// Execute.
- (BOOL) execute
  {
  return [self execute: NULL];
  }

// Execute the statement.
- (BOOL) execute: (NSError **) error
  {
  return NO;
  }

@end

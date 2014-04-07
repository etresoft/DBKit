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
@synthesize fetchedResultsController;

- (NSFetchedResultsController *) fetchedResultsController
  {
  if(!fetchedResultsController)
    [self execute];
    
  return fetchedResultsController;
  }

#pragma mark - Housekeeping

// Constructor.
- (id) initWithManagedObjectContext: (NSManagedObjectContext *) context
  {
  self = [super init];
  
  if(self)
    managedObjectContext = context;
    
  return self;
  }

// Bind parameters for later execution.
- (void) bindParameters: (NSDictionary *) parameters
  {
  self.parameters = parameters;
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

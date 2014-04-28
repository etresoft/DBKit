/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import "DBUITableViewDataSource.h"
#import "DBUITableViewDelegate.h"
#import "DBKit.h"

@interface DBSelect ()

- (NSFetchRequest *) setupFetchRequest;

@end

@interface DBUITableViewDataSource ()

@property (strong, nonatomic)
  NSFetchedResultsController * fetchedResultsController;

@end

@implementation DBUITableViewDataSource

- (NSArray *) objects
  {
  return self.fetchedResultsController.fetchedObjects;
  }

- (NSArray *) groups
  {
  return self.fetchedResultsController.sections;
  }

// Execute the select.
- (BOOL) execute: (NSError **) error
  {
  NSFetchRequest * fetchRequest = [self setupFetchRequest];

  // Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
  self.fetchedResultsController =
    [[NSFetchedResultsController alloc]
      initWithFetchRequest: fetchRequest
      managedObjectContext: self.managedObjectContext
      sectionNameKeyPath: self.sectionName
      cacheName: nil];
    
  self.fetchedResultsController.delegate = self.delegate;
  
  if(![self.fetchedResultsController performFetch: error])
    {
    // Replace this implementation with code to handle the error
    // appropriately.
    // abort() causes the application to generate a crash log and
    // terminate. You should not use this function in a shipping
    // application, although it may be useful during development.
    if(*error)
      NSLog(@"Unresolved error %@, %@", *error, [*error userInfo]);
    
    return NO;
    }
    
  return YES;
  }

#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
  {
  return [self.fetchedResultsController.sections count];
  }

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
  {
  id <NSFetchedResultsSectionInfo> sectionInfo =
    self.fetchedResultsController.sections[section];
  
  return [sectionInfo numberOfObjects];
  }

- (UITableViewCell *) tableView: (UITableView *) tableView
  cellForRowAtIndexPath: (NSIndexPath *) indexPath
  {
  return
    [self.delegate
      tableView: tableView
      configureObject: [self fetchAtIndexPath: indexPath]
      atIndexPath: indexPath];
  }

// Fetch a specific object via index path.
- (NSManagedObject *) fetchAtIndexPath: (NSIndexPath *) indexPath
  {
  return [self.fetchedResultsController objectAtIndexPath: indexPath];
  }

// Refresh an object changed in another context.
- (void) refresh: (NSManagedObject *) object
  {
  [self.managedObjectContext refreshObject: object mergeChanges: YES];
  }

@end
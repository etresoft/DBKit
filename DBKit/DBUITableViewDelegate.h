/***********************************************************************
 ** Etresoft
 ** John Daniel
 ** Copyright (c) 2014. All rights reserved.
 **********************************************************************/

#import <Foundation/Foundation.h>

@protocol DBUITableViewDelegate <NSFetchedResultsControllerDelegate>

- (UITableViewCell *) tableView: (UITableView *) tableView
  configureObject: (NSManagedObject *) object
  atIndexPath: (NSIndexPath *) path;

@end

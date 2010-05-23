//
//  RootViewController.h
//  Hacker News
//
//  Created by Mark Fayngersh on 4/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@class DetailViewController;

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {	
    DetailViewController *detailViewController;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	UIBarButtonItem *editButton;
	NSMutableArray *rowsToDelete;
}
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (retain) NSFetchedResultsController *fetchedResultsController;
@property (retain) NSManagedObjectContext *managedObjectContext;

- (NSArray *) fetchCurrentObjects;
- (void)insertNewObject:(NSDictionary *)articles favorite:(NSNumber *)isFavorite;
- (void)editMode:(id)sender;

@end

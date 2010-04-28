//
//  DetailViewController.h
//  Hacker News
//
//  Created by Mark Fayngersh on 4/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    NSManagedObject *detailItem;
    UILabel *articleTitleLabel;
	UILabel *articleLinkLabel;
    UILabel *articleAuthorLabel;
    UIButton *discussionButton;
    UIButton *favoriteButton;
    UIActivityIndicatorView *indicator;
	UIScrollView *scrollView;
    NSMutableData *payload;
    RootViewController *rootViewController;
    BOOL instapaperIsLoggedIn;
    NSString *iUsername;
    NSString *iPassword;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) IBOutlet UILabel *articleTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *articleLinkLabel;
@property (nonatomic, retain) IBOutlet UILabel *articleAuthorLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UIButton *discussionButton;
@property (nonatomic, retain) IBOutlet UIButton *favoriteButton;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)openArticle:(id)sender;
- (IBAction)instapaperButtonDidClick:(id)sender;
- (IBAction)setFavorite:(id)sender;

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)conn;
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;
@end
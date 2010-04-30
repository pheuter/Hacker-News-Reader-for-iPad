//
//  DetailViewController.m
//  Hacker News
//
//  Created by Mark Fayngersh on 4/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "WebViewController.h"

#import "JSON.h";

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize toolbar, popoverController, detailItem, articleTitleLabel, articleLinkLabel, articleAuthorLabel, discussionButton, favoriteButton, indicator, scrollView, rootViewController;

#pragma mark -
#pragma mark Object insertion

- (IBAction)insertNewObject:(id)sender {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hnscraper.heroku.com/"]];;
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        payload = [[NSMutableData data] autorelease];
        [indicator startAnimating];
        HNLog(@"Connection starting: %@", connection);
    } else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't fetch" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

- (IBAction)openArticle:(id)sender {
	WebViewController *webViewController = [[WebViewController alloc] init];
	NSString *urlAddress;

	if ([[sender currentTitle] isEqualToString:@"View"]) {
		webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		urlAddress = [detailItem valueForKey:@"url"];
	} else {
		webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
		urlAddress = [detailItem valueForKey:@"discuss"];
	}

	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	[self presentModalViewController:webViewController animated:YES];
	[webViewController.webView loadRequest:requestObj];
	
	[webViewController release];
}

- (IBAction) instapaperButtonDidClick:(id)sender {
    if (!instapaperIsLoggedIn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instapaper credentials" message:@" " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login",nil];

        UITextField *username = [[[UITextField alloc] initWithFrame:CGRectMake(14, 45, 255, 23)] autorelease];
        username.keyboardType = UIKeyboardTypeEmailAddress;
        username.keyboardAppearance = UIKeyboardAppearanceAlert;
        username.returnKeyType = UIReturnKeyDone;
        username.font = [UIFont systemFontOfSize:20.0];
        username.backgroundColor = [UIColor whiteColor];
        username.placeholder = @"email";
		username.tag = 5;

        [alert addSubview:username];

        UITextField *password = [[[UITextField alloc] initWithFrame:CGRectMake(14, 45, 255, 23)] autorelease];
		password.frame = CGRectMake(14, 75, 255, 23);
        password.keyboardType = UIKeyboardTypeAlphabet;
        password.keyboardAppearance = UIKeyboardAppearanceAlert;
        password.returnKeyType = UIReturnKeyDone;
        password.font = [UIFont systemFontOfSize:20.0];
        password.backgroundColor = [UIColor whiteColor];
        password.placeholder = @"password";
        password.secureTextEntry = YES;
		password.tag = 6;

        [alert addSubview:password];

        [alert show];
		[alert release];
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.instapaper.com/api/add?url=%@&auto-title=1&username=%@&password=%@", [[detailItem valueForKey:@"url"] substringFromIndex:7], iUsername, iPassword]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		UIAlertView *alert = nil;
        if ([response statusCode] == 201) {
			alert = [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Article added to your inbox" delegate:nil cancelButtonTitle:@"Great" otherButtonTitles:nil] autorelease];
        } else {
			alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't add article to your inbox" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        }

		[alert show];
        [request release];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    [[alertView viewWithTag:1] setFrame:CGRectMake(14, 110, 100, 40)];
    [[alertView viewWithTag:2] setFrame:CGRectMake(160, 110, 100, 40)];
    
    alertView.frame = CGRectMake(400, 300, 500, 170);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.instapaper.com/api/authenticate?username=%@&password=%@",((UITextField *)[alertView viewWithTag:5]).text,((UITextField *)[alertView viewWithTag:6]).text]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSHTTPURLResponse *response;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [request release];

		UIAlertView *alert = nil;
		if ([response statusCode] == 403) {
			alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong username and/or password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
       } else if ([response statusCode] == 200) {
            alert = [[[UIAlertView alloc] initWithTitle:@"Success" message:@"You have logged in" delegate:nil cancelButtonTitle:@"Great" otherButtonTitles:nil] autorelease];
            instapaperIsLoggedIn = YES;
            iUsername = [[NSString alloc] initWithString:((UITextField *)[alertView viewWithTag:5]).text];
            iPassword = [[NSString alloc] initWithString:((UITextField *)[alertView viewWithTag:6]).text];
       }
		[alert show];
	}
}

- (IBAction)setFavorite:(id)sender {
    if ([[sender currentTitle] isEqualToString:@"Favorite"]) {
        [detailItem setValue:[NSNumber numberWithBool:YES] forKey:@"favorite"];
    } else {
        [detailItem setValue:[NSNumber numberWithBool:NO] forKey:@"favorite"];
    }
    [self configureView];
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(NSManagedObject *)managedObject {
    
	if (detailItem != managedObject) {
		[detailItem release];
		detailItem = [managedObject retain];
		
        // Update the view.
        [self configureView];
	}
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }		
}


- (void)configureView {
	// Update the user interface for the detail item.
	articleTitleLabel.text = [detailItem valueForKey:@"title"];
	articleLinkLabel.text = [detailItem valueForKey:@"url"];
    articleAuthorLabel.text = [detailItem valueForKey:@"author"];
    [discussionButton setTitle:[NSString stringWithFormat:@"Comments (%@)", [detailItem valueForKey:@"comments"]] forState:UIControlStateNormal];
    if ([[detailItem valueForKey:@"favorite"] boolValue]) {
        [favoriteButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
    } else {
        [favoriteButton setTitle:@"Favorite" forState:UIControlStateNormal];
    }

	scrollView.hidden = NO;
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = @"Articles";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
	
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
			
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
}

- (void)viewDidUnload {
	self.popoverController = nil;
}

#pragma mark -
#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	HNLog(@"Recieved response with expected length: %i", [response expectedContentLength]);
    [payload setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    HNLog(@"Recieving data. Incoming Size: %i  Total Size: %i", [data length], [payload length]);
    [payload appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {    
	[conn release];
    
    NSString *data = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
    NSDictionary *rspData = [data JSONValue];
    [rootViewController insertNewObject:[rspData objectForKey:@"results"] favorite:[detailItem valueForKey:@"favorite"]];
    [indicator stopAnimating];
    
    [data release];

	HNLog(@"Connection finished: %@", conn);
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    [indicator stopAnimating];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't fetch" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
	[alert show];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [popoverController release];
    [toolbar release];
	
	[detailItem release];
	[articleTitleLabel release];
    
	[super dealloc];
}
@end

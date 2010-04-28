//
//  WebViewController.h
//  Hacker News
//
//  Created by Mark Fayngersh on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface WebViewController : UIViewController {
	UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction)dismissView:(id)sender;

@end

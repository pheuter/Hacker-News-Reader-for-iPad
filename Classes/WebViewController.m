    //
//  WebViewController.m
//  Hacker News
//
//  Created by Mark Fayngersh on 4/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "DetailViewController.h"

@implementation WebViewController

@synthesize webView;

- (IBAction)dismissView:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
@end

//
//  WebAuthController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 25/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "WebAuthController.h"

@interface WebAuthController ()

@end

@implementation WebAuthController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Authorize App";
    // Create a URLRequest
    NSURLRequest* request = [NSURLRequest requestWithURL:self.urlToLoad];
    // Load the URL
    self.webView.delegate = self;
    [self.webView loadRequest:request];
    //
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Extract the request parameters from request
    NSString* strURL = [NSString stringWithFormat: @"%@", [request URL]];
    if ([strURL hasPrefix:@"flickrpublish://"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return YES;
    }
    else
    {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        self.progressContainer.hidden = YES;
    });
}

@end

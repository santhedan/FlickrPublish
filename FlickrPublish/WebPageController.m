//
//  WebPageController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 02/09/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "WebPageController.h"

@interface WebPageController ()

@end

@implementation WebPageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.titleOfWebCtrl;
    //
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlToLoad]]];
    self.webView.delegate = self;
    //
    self.progressViewContainer.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressViewContainer.hidden = YES;
        [self.activityIndicator stopAnimating];
    });
}

@end

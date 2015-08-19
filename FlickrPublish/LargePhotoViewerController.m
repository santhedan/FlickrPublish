//
//  LargePhotoViewerController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 12/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "LargePhotoViewerController.h"

@interface LargePhotoViewerController ()

@end

@implementation LargePhotoViewerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.photo.name;
    self.automaticallyAdjustsScrollViewInsets = YES;
    // Load the large image in webview
    NSString* largeImageUrl = [self.photo.smallImageURL stringByReplacingOccurrencesOfString:@"_q.jpg" withString:@"_b.jpg"];
    // Create NSURL
    NSURL* url = [NSURL URLWithString:largeImageUrl];
    // Create NSURLRequest
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    // Load
    self.webView.scrollView.bounces = NO;
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

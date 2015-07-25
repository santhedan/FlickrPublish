//
//  WebAuthController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 25/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebAuthController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSURL* urlToLoad;

@end

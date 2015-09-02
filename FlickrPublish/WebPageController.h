//
//  WebPageController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 02/09/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIView *progressViewContainer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString* urlToLoad;

@property (nonatomic, strong) NSString* titleOfWebCtrl;


@end

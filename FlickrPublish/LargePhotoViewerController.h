//
//  LargePhotoViewerController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 12/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface LargePhotoViewerController : UIViewController

@property (nonatomic, strong) Photo* photo;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

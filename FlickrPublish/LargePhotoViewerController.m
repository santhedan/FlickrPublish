//
//  LargePhotoViewerController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 12/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "LargePhotoViewerController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PeopleGetInfo.h"

@interface LargePhotoViewerController ()
{
    Person* storedPerson;
    NSInteger counter;
}
@property (weak, nonatomic) IBOutlet UIView *progressViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation LargePhotoViewerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.photo.name;
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Load the large image in webview
    NSString* largeImageUrl = [self.photo.smallImageURL stringByReplacingOccurrencesOfString:@"_q.jpg" withString:@"_b.jpg"];
    // Create NSURL
    NSURL* url = [NSURL URLWithString:largeImageUrl];
    // Create NSURLRequest
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    // Load
    self.webView.scrollView.bounces = NO;
    [self.webView loadRequest:request];
    //
    if (self.showProfile)
    {
        self.progressViewContainer.hidden = NO;
        [self.activityIndicator startAnimating];
        counter = 2;
        //
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create request and operation and execute
        PeopleGetInfo* request = [[PeopleGetInfo alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:self.photo.ownerId];
        // Create operation
        PeopleGetInfoOperation* op = [[PeopleGetInfoOperation alloc] initWithRequest:request Delegate:self];
        // Queue for execution
        [delegate enqueueOperation:op];
    }
    else
    {
        self.progressViewContainer.hidden = NO;
        [self.activityIndicator startAnimating];
        counter = 1;
    }
}

- (void)viewWillLayoutSubviews
{
    if (self.showProfile == NO)
    {
        self.profileContainerHeightConstraint.constant = 0;
        self.webViewVerticalSpaceConstraint.constant = 0;
        [self.view setNeedsLayout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark EventHandler

- (IBAction)handlePhotos:(id)sender
{
}

- (IBAction)handleComment:(id)sender
{
}

- (IBAction)handleFavorite:(id)sender
{
}

#pragma mark PeopleGetInfoOperationHandler

- (void) receivedInfo: (Person *) person
{
    storedPerson = person;
    counter--;
    NSLog(@"person.realName -> %@", person.realName);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (storedPerson.realName != nil && storedPerson.realName.length > 0)
        {
            self.realName.text = storedPerson.realName;
        }
        else
        {
            self.realName.text = storedPerson.userName;
        }
        self.locationAndPhotos.text = [NSString stringWithFormat:@"%@ %@ photos", storedPerson.location, storedPerson.photoCount];
        self.profileImage.image = storedPerson.buddyIcon;
        if (counter == 0)
        {
            self.progressViewContainer.hidden = YES;
            [self.activityIndicator stopAnimating];
        }
    });
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    counter--;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (counter == 0)
        {
            self.progressViewContainer.hidden = YES;
            [self.activityIndicator stopAnimating];
        }
    });
}

@end

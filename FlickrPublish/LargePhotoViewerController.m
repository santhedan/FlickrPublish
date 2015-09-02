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
#import "GroupPoolPhotoDisplayController.h"
#import "WebPageController.h"

@interface LargePhotoViewerController ()
{
    Person* storedPerson;
    NSInteger counter;
    NSString* urlToLoad;
    NSString* titleOfWebCtrl;
    BOOL navigateAway;
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
    //
    self.commentCmd.enabled = NO;
    self.photosCmd.enabled = NO;
    self.faceCmd.enabled = NO;
    self.blockUserCmd.enabled = NO;
    self.flagPhotoCmd.enabled = NO;
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
        self.profileContainerView.hidden = YES;
        [self.view setNeedsLayout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowUserPhotos"])
    {
        GroupPoolPhotoDisplayController* ctrl = (GroupPoolPhotoDisplayController *)segue.destinationViewController;
        ctrl.userId = storedPerson.id;
        ctrl.showGroupPhotos = NO;
        if (storedPerson.realName != nil && storedPerson.realName.length > 0)
        {
            ctrl.userName = storedPerson.realName;
        }
        else
        {
            ctrl.userName = storedPerson.userName;
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowWebPage"])
    {
        WebPageController* ctrl = (WebPageController *)segue.destinationViewController;
        ctrl.urlToLoad = urlToLoad;
        ctrl.titleOfWebCtrl = titleOfWebCtrl;
    }
}

#pragma mark EventHandler

- (IBAction)handlePhotos:(id)sender
{
    [self performSegueWithIdentifier:@"ShowUserPhotos" sender:self];
}

- (IBAction)handleBlockUser:(id)sender
{
    urlToLoad = storedPerson.profileUrl;
    navigateAway = YES;
    titleOfWebCtrl = @"Block User";
    // Show message to block user
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Block User" message:@"The application will show user's profile page on Flickr. You may need to login using your Flickr credentials to block the user." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    [alertView show];
}

- (IBAction)handleFlagPhoto:(id)sender
{
    NSString* urlFormat = @"https://www.flickr.com/photos/%@/%@";
    NSString* url = [NSString stringWithFormat:urlFormat, storedPerson.id, self.photo.id];
    urlToLoad = url;
    titleOfWebCtrl = @"Flag Photo / Report Abuse";
    navigateAway = YES;
    // Show message to flag photo
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Flag Content" message:@"The application will show photo page on Flickr. You may need to login using your Flickr credentials to report abuse / flag content." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    [alertView show];
}

- (IBAction)handleComment:(id)sender
{
    navigateAway = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment" message:@"Enter your comment" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)handleFavorite:(id)sender
{
    //
    self.commentCmd.enabled = NO;
    self.photosCmd.enabled = NO;
    self.faceCmd.enabled = NO;
    // Get app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create operation
    FavoritesAddOperation* op = [[FavoritesAddOperation alloc] initWithPhotoIds:[NSArray arrayWithObjects:self.photo.id, nil] Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
    [delegate enqueueOperation:op];
    self.progressViewContainer.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && navigateAway == YES)
    {
        [self performSegueWithIdentifier:@"ShowWebPage" sender:self];
    }
    else if (buttonIndex == 1 && navigateAway == NO)
    {
        //
        self.commentCmd.enabled = NO;
        self.photosCmd.enabled = NO;
        self.faceCmd.enabled = NO;
        self.blockUserCmd.enabled = NO;
        self.flagPhotoCmd.enabled = NO;
        //
        UITextField *commentField = [alertView textFieldAtIndex:0];
        //
        // Get app delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create operation
        PhotosCommentsAddCommentOperation* op = [[PhotosCommentsAddCommentOperation alloc] initWithPhotoId:self.photo.id Comment:commentField.text Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        self.progressViewContainer.hidden = NO;
        [self.activityIndicator startAnimating];
    }
}

#pragma mark PeopleGetInfoOperationHandler

- (void) receivedInfo: (Person *) person
{
    storedPerson = person;
    counter--;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (storedPerson.realName != nil && storedPerson.realName.length > 0)
        {
            self.realName.text = storedPerson.realName;
        }
        else
        {
            self.realName.text = storedPerson.userName;
        }
        if (storedPerson.location.length > 0 && storedPerson.photoCount.length > 0)
        {
            self.locationAndPhotos.text = [NSString stringWithFormat:@"%@ %@ photos", storedPerson.location, storedPerson.photoCount];
        }
        else if (storedPerson.photoCount.length > 0)
        {
            self.locationAndPhotos.text = [NSString stringWithFormat:@"%@ photos", storedPerson.photoCount];
        }
        self.profileImage.image = storedPerson.buddyIcon;
        if (counter == 0)
        {
            self.progressViewContainer.hidden = YES;
            [self.activityIndicator stopAnimating];
            //
            self.commentCmd.enabled = YES;
            self.photosCmd.enabled = YES;
            self.faceCmd.enabled = YES;
            self.blockUserCmd.enabled = YES;
            self.flagPhotoCmd.enabled = YES;
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
            //
            self.commentCmd.enabled = YES;
            self.photosCmd.enabled = YES;
            self.faceCmd.enabled = YES;
            self.blockUserCmd.enabled = YES;
            self.flagPhotoCmd.enabled = YES;
        }
    });
}

#pragma mark PhotosCommentsAddCommentOperationDelegate

- (void) commentsAdded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressViewContainer.hidden = YES;
        [self.activityIndicator stopAnimating];
        //
        self.commentCmd.enabled = YES;
        self.photosCmd.enabled = YES;
        self.faceCmd.enabled = YES;
        self.blockUserCmd.enabled = YES;
        self.flagPhotoCmd.enabled = YES;
    });
}

#pragma mark FavoritesAddOperationDelegate

- (void) favoritesAdded
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressViewContainer.hidden = YES;
        [self.activityIndicator stopAnimating];
        //
        self.commentCmd.enabled = YES;
        self.photosCmd.enabled = YES;
        self.faceCmd.enabled = YES;
        self.blockUserCmd.enabled = YES;
        self.flagPhotoCmd.enabled = YES;
    });
}

@end

//
//  OAuthController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "OAuthController.h"
#import "RequestToken.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "AccessToken.h"
#import "WebAuthController.h"

@interface OAuthController()

@property (nonatomic, strong) NSURL* urlToLoad;

@end

@implementation OAuthController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Authorize App";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleAuthClick:(id)sender {
    // Start activity indicator
    [self.activityIndicator startAnimating];
    RequestToken* request = [[RequestToken alloc] initWithKey:API_KEY Secret: SECRET CallbackUrl:CALLBACK_URL];
    // Now create operation
    RequestTokenOperation* op = [[RequestTokenOperation alloc] initWithRequest:request Handler:self];
    // Get application delegate and queue the operation
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate enqueueOperation:op];
}

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret
{
    // Save the secret and token in app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.secret = secret;
    delegate.token = token;
    
    self.urlToLoad = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.flickr.com/services/oauth/authorize?oauth_token=%@", token]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"WebAuth" sender:self];
    });
}

- (void) handleKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Verifier: (NSString *) verifier
{
    // Now create an access token request and execute it
    AccessToken* request = [[AccessToken alloc] initWithKey:API_KEY Secret:secret Token:token Verifier:verifier];
    // Create operation
    AccessTokenOperation* op = [[AccessTokenOperation alloc] initWithRequest:request Handler:self];
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate enqueueOperation:op];

}

- (void) receivedRequestToken: (NSString *) token Secret: (NSString *) secret FullName: (NSString *) fullName UserNSID: (NSString *) userNSID UserName: (NSString *) userName
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:AUTHTOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:secret forKey:SECRET_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:FULLNAME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:userNSID forKey:NSID_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //
    // Get stored data if any
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.token = [[NSUserDefaults standardUserDefaults] objectForKey:AUTHTOKEN_KEY];
    delegate.secret = [[NSUserDefaults standardUserDefaults] objectForKey:SECRET_KEY];
    delegate.fullName = [[NSUserDefaults standardUserDefaults] objectForKey:FULLNAME_KEY];
    delegate.userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
    delegate.nsid = [[NSUserDefaults standardUserDefaults] objectForKey:NSID_KEY];
    //
    delegate.hmacsha1Key = [NSString stringWithFormat:@"%@&%@", SECRET, delegate.secret];
    //
    if (delegate.token != nil && delegate.secret != nil)
    {
        delegate.isAuthenticated = YES;
    }
    else
    {
        delegate.isAuthenticated = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        //
        [self performSegueWithIdentifier:@"AfterAuth" sender:self];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"WebAuth"])
    {
        WebAuthController* ctrl = (WebAuthController *)segue.destinationViewController;
        ctrl.urlToLoad = self.urlToLoad;
    }
}

@end

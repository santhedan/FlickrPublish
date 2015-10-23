//
//  AppDelegate.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "OFUtilities.h"
#import "AccessToken.h"
#import "AccessTokenOperation.h"
#import "OAuthController.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSOperationQueue* queue;

@property (nonatomic, strong) NSMutableDictionary* groupComments;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 5;
    // Get stored dats if any
    self.token = [[NSUserDefaults standardUserDefaults] objectForKey:AUTHTOKEN_KEY];
    self.secret = [[NSUserDefaults standardUserDefaults] objectForKey:SECRET_KEY];
    self.fullName = [[NSUserDefaults standardUserDefaults] objectForKey:FULLNAME_KEY];
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
    self.nsid = [[NSUserDefaults standardUserDefaults] objectForKey:NSID_KEY];
    //
    self.hmacsha1Key = [NSString stringWithFormat:@"%@&%@", SECRET, self.secret];
    //
    if (self.token != nil && self.secret != nil)
    {
        self.isAuthenticated = YES;
    }
    else
    {
        self.isAuthenticated = NO;
    }
    LoadGroupComments* op = [[LoadGroupComments alloc] initWithHandler:self];
    [self enqueueOperation:op];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.groupComments != nil)
    {
        SaveGroupComments* op = [[SaveGroupComments alloc] initWithGroupComments:self.groupComments Handler:self];
        [self enqueueOperation:op];
    }
    else
    {
        [self destroyQueue];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Create Load operation and execute
    LoadGroupComments* op = [[LoadGroupComments alloc] initWithHandler:self];
    [self enqueueOperation:op];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.groupComments != nil)
    {
        SaveGroupComments* op = [[SaveGroupComments alloc] initWithGroupComments:self.groupComments Handler:self];
        [self enqueueOperation:op];
    }
    else
    {
        [self destroyQueue];
    }
}

- (void) performSaveComment
{
    if (self.groupComments != nil)
    {
        SaveGroupComments* op = [[SaveGroupComments alloc] initWithGroupComments:self.groupComments Handler:nil];
        [self enqueueOperation:op];
    }
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *token = nil;
    NSString *verifier = nil;
    BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:CALLBACK_URL], &token, &verifier);
    if (!result)
    {
        return NO;
    }
    // Create secret
    NSString* secret = [NSString stringWithFormat:@"%@&%@", SECRET, self.secret];
    // Get the topmost controller
    UINavigationController* navCtrl = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    OAuthController* ctrl = (OAuthController*)navCtrl.topViewController;
    // Now create an access token request and execute it
    [ctrl handleKey:API_KEY Secret:secret Token:token Verifier:verifier];
    return YES;
}

- (void) enqueueOperation: (NSOperation *) op
{
    if (self.queue == nil)
    {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 5;
    }
    [self.queue addOperation:op];
}

- (void) destroyQueue
{
    if (self.queue)
    {
        [self.queue cancelAllOperations];
        self.queue = nil;
    }
}

- (void) cancelAllOperation
{
    if (self.queue)
    {
        NSLog(@"Cancelling all operations");
        [self.queue cancelAllOperations];
    }
}

- (void) loadedGroupComments: (NSDictionary*) groupComments
{
    if (groupComments != nil)
    {
        self.groupComments = [[NSMutableDictionary alloc] initWithDictionary:groupComments];
    }
}

- (void) didSaveGroupComments
{
    [self destroyQueue];
}

- (void) addComment: (NSString *) comment forGroup: (NSString *) groupId
{
    if (self.groupComments == nil)
    {
        self.groupComments = [[NSMutableDictionary alloc] init];
    }
    [self.groupComments setObject:comment forKey:groupId];
}

- (void) removeCommentForGroup: (NSString *) groupId
{
    if (self.groupComments != nil)
    {
        [self.groupComments removeObjectForKey:groupId];
    }
}

- (NSString *) getCommentForGroup: (NSString *) groupId
{
    if (self.groupComments != nil)
    {
        return [self.groupComments objectForKey:groupId];
    }
    return nil;
}

@end

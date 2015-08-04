//
//  GroupDetailController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupDetailController.h"
#import "AppDelegate.h"

@interface GroupDetailController ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *albumName;
@property (weak, nonatomic) IBOutlet UILabel *membershipType;
@property (weak, nonatomic) IBOutlet UILabel *remainingCount;
@property (weak, nonatomic) IBOutlet UILabel *memberCount;
@property (weak, nonatomic) IBOutlet UILabel *photoCount;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *comment;
- (IBAction)saveComment:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation GroupDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Group Detail";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //
    self.albumName.text = self.group.name;
    self.remainingCount.text = [NSString stringWithFormat:@"Remaining: %ld (%ld / %@)", (long)self.group.remaining, (long)self.group.throttleCount, self.group.throttleMode];
    self.memberCount.text = [NSString stringWithFormat:@"%@ members", self.group.members];
    self.photoCount.text = [NSString stringWithFormat:@"%@ photos", self.group.poolPhotoCount];
    if (self.group.memType == ADMIN)
    {
        self.membershipType.text = @"Admin";
    }
    else if (self.group.memType == MODERATOR)
    {
        self.membershipType.text = @"Moderator";
    }
    else
    {
        self.membershipType.text = @"Member";
    }
    self.thumbnail.image = [UIImage imageWithData:self.group.imageData];
    self.thumbnail.layer.borderWidth = 3.0f;
    self.thumbnail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width / 2;;
    self.thumbnail.clipsToBounds = YES;
    //
    self.comment.text = [self.group getDefaultComment];
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get group description
    GroupsGetInfo* request = [[GroupsGetInfo alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token GroupId:self.group.id];
    GroupsGetInfoOperation* op = [[GroupsGetInfoOperation alloc] initWithRequest:request Delegate:self];
    [delegate enqueueOperation:op];
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveComment:(id)sender
{
    NSString* comment = self.comment.text;
    if (comment != nil && comment.length > 0)
    {
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate addComment:comment forGroup:self.group.id];
    }
}

- (void) receivedGroupInformation: (Group *) group
{
    self.group.groupDescription = group.groupDescription;
    dispatch_async(dispatch_get_main_queue(), ^{
        // Load the description in webview
        [self.webView loadHTMLString:self.group.groupDescription baseURL:nil];
        [self.activityIndicator stopAnimating];
    });
}

@end

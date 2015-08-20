//
//  LargePhotoViewerController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 12/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "PeopleGetInfoOperation.h"
#import "PhotosCommentsAddCommentOperation.h"
#import "FavoritesAddOperation.h"

@interface LargePhotoViewerController : UIViewController <PeopleGetInfoOperationHandler, UIWebViewDelegate, PhotosCommentsAddCommentOperationDelegate, FavoritesAddOperationDelegate>

@property (nonatomic, strong) Photo* photo;
@property (nonatomic, assign) BOOL showProfile;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *profileContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *realName;
@property (weak, nonatomic) IBOutlet UILabel *locationAndPhotos;
@property (weak, nonatomic) IBOutlet UIView *profileContainerView;
@property (weak, nonatomic) IBOutlet UIButton *commentCmd;
@property (weak, nonatomic) IBOutlet UIButton *photosCmd;
@property (weak, nonatomic) IBOutlet UIButton *faceCmd;

- (IBAction)handlePhotos:(id)sender;
- (IBAction)handleComment:(id)sender;
- (IBAction)handleFavorite:(id)sender;

- (void) commentsAdded;

- (void) favoritesAdded;

- (void) receivedInfo: (Person *) person;

@end

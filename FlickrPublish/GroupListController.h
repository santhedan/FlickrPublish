//
//  GroupListController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "PhotosGetAllContextsOperation.h"
#import "PeopleGetGroupsOperation.h"
#import "GroupsPoolsAddOperation.h"

@interface GroupListController : UIViewController <UITableViewDataSource, UITableViewDelegate, PhotosGetAllContextsHandler, PeopleGetGroupsOperationHandler, GroupsPoolsAddOperationHandler>

@property (weak, nonatomic) IBOutlet UIImageView *imageToAdd;

@property (nonatomic, strong) Photo* photo;

- (void) receivedGroups: (NSArray *) groups;

- (void) receivedPhotoGroups: (NSArray *) groups;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)handleAdd:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void) addedToGroups: (NSArray *) groups;

@end

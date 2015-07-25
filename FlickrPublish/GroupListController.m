//
//  GroupListController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupListController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PhotosGetAllContexts.h"
#import "PeopleGetGroupsOperation.h"
#import "PhotosGetAllContexts.h"
#import "PeopleGetGroups.h"
#import "Group.h"
#import "GroupCell.h"
#import "GroupsPoolsAddOperation.h"

@interface GroupListController ()

@property (nonatomic, strong) NSArray* groupsToExclude;

@property (nonatomic, strong) NSArray* groups;

@property (nonatomic, strong) PhotoInfo *info;

@end

@implementation GroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.photo.name;
    //
    self.imageToAdd.image = [UIImage imageWithData:self.photo.imageData];
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosGetAllContexts* request = [[PhotosGetAllContexts alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token PhotoId:self.photo.id];
    // Create operation
    PhotosGetAllContextsOperation* op = [[PhotosGetAllContextsOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
    //
    [self.activityIndicator startAnimating];
    //
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    Group* g = [self.groups objectAtIndex:indexPath.item];
    cell.groupName.text = g.name;
    cell.remainingCount.text = [NSString stringWithFormat:@"Remaining: %ld", (long)g.remaining];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Group* g = [self.groups objectAtIndex:indexPath.item];
    g.selected = !(g.selected);
}

- (void) receivedGroups: (NSArray *) groups
{
    self.groups = groups;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        //
        self.faveCount.text = [NSString stringWithFormat:@"%ld", (long)self.info.faves];
        self.commentCount.text = [NSString stringWithFormat:@"%ld", (long)self.info.comments];
        self.viewCount.text = [NSString stringWithFormat:@"%ld", (long)self.photo.views];
        if (self.info.isPublic)
        {
            self.publicState.text = @"Public";
        }
        else
        {
            self.publicState.text = @"Private";
        }
        //
        [self.tableView reloadData];
    });
}

- (void) receivedPhotoGroups: (NSArray *) groups Info: (PhotoInfo *) info
{
    self.groupsToExclude = groups;
    self.info = info;
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PeopleGetGroups* request = [[PeopleGetGroups alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid];
    // Create operation
    PeopleGetGroupsOperation* op = [[PeopleGetGroupsOperation alloc] initWithRequest:request ExcludeGroups:self.groupsToExclude Delegate:self];
    //
    [delegate enqueueOperation:op];
}

- (IBAction)handleAdd:(id)sender
{
    // Create an array of selected groups
    NSMutableArray* gArr = [[NSMutableArray alloc] init];
    for (Group* g in self.groups)
    {
        if (g.selected)
        {
            [gArr addObject:g];
        }
    }
    if (gArr.count > 0)
    {
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create request
        GroupsPoolsAddOperation* op = [[GroupsPoolsAddOperation alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token PhotoId:self.photo.id Groups:gArr Delegate:self];
        //
        [delegate enqueueOperation:op];
        //
        [self.activityIndicator startAnimating];
    }
}

- (void) addedToGroups: (NSArray *) groups
{
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosGetAllContexts* request = [[PhotosGetAllContexts alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token PhotoId:self.photo.id];
    // Create operation
    PhotosGetAllContextsOperation* op = [[PhotosGetAllContextsOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
}

@end

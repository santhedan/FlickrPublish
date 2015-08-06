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
    [self.collectionView setLayoutMargins:UIEdgeInsetsZero];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.groups.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell" forIndexPath:indexPath];
    Group* g = [self.groups objectAtIndex:indexPath.item];
    cell.groupName.text = g.name;
    cell.remainingCount.text = [NSString stringWithFormat:@"Remaining: %ld (%ld / %@)", (long)g.remaining, (long)g.throttleCount, g.throttleMode];
    cell.members.text = [NSString stringWithFormat:@"%@ members", g.members];
    cell.photos.text = [NSString stringWithFormat:@"%@ photos", g.poolPhotoCount];
    if (g.memType == ADMIN)
    {
        cell.membershipType.text = @"Admin";
    }
    else if (g.memType == MODERATOR)
    {
        cell.membershipType.text = @"Moderator";
    }
    else
    {
        cell.membershipType.text = @"Member";
    }
    cell.thumbnail.image = [UIImage imageWithData:g.imageData];
    cell.thumbnail.layer.borderWidth = 3.0f;
    cell.thumbnail.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.thumbnail.layer.cornerRadius = cell.thumbnail.frame.size.width / 2;;
    cell.thumbnail.clipsToBounds = YES;
    //
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [cell tintColor].CGColor;
    //
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Group* g = [self.groups objectAtIndex:indexPath.item];
    g.selected = !(g.selected);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 20;
    
    // Divide this with the minimum desired width of the cell
    int itemsInRow = collectionViewWidth / 240;
    
    // So we can fit "itemsInRow"
    int desiredItemWidth = (collectionViewWidth - (itemsInRow - 1) * 10) / itemsInRow;
    
    // Height is fixed
    int desiredItemHeight = 125;
    
    // Create size object from above and return
    CGSize itemSize = CGSizeMake(desiredItemWidth, desiredItemHeight);
    
    return itemSize;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
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
        [self.collectionView reloadData];
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

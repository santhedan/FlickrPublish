//
//  GroupManagementController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupManagementController.h"
#import "AppDelegate.h"
#import "PeopleGetGroups.h"
#import "PeopleGetGroupsOperation.h"
#import "Constants.h"
#import "GroupCell.h"
#import "Group.h"
#import "GroupDetailController.h"
#import "GroupPoolPhotoDisplayController.h"

@interface GroupManagementController ()

@property (nonatomic, strong) NSArray* groups;
@property (nonatomic, strong) Group* selGroup;

@end

@implementation GroupManagementController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Your Groups";
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PeopleGetGroups* request = [[PeopleGetGroups alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid];
    // Create operation
    PeopleGetGroupsOperation* op = [[PeopleGetGroupsOperation alloc] initWithRequest:request ExcludeGroups:nil Delegate:self];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowGroupDetail"])
    {
        GroupDetailController* ctrl = (GroupDetailController*)segue.destinationViewController;
        ctrl.group = self.selGroup;
    }
    else if ([segue.identifier isEqualToString:@"ShowGroupPhotos"])
    {
        GroupPoolPhotoDisplayController* ctrl = (GroupPoolPhotoDisplayController*)segue.destinationViewController;
        ctrl.group = self.selGroup;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.groups count];
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
    cell.showPhotosBtn.layer.borderWidth = 0.5f;
    cell.showPhotosBtn.layer.borderColor = [cell.showPhotosBtn tintColor].CGColor;
    cell.showPhotosBtn.tag = indexPath.item;
    cell.configureCommentsBtn.layer.borderWidth = 0.5f;
    cell.configureCommentsBtn.layer.borderColor = [cell.configureCommentsBtn tintColor].CGColor;
    cell.configureCommentsBtn.tag = indexPath.item;
    //
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [cell tintColor].CGColor;
    //
    return cell;
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 20;
    
    // Divide this with the minimum desired width of the cell
    int itemsInRow = collectionViewWidth / 240;
    
    // So we can fit "itemsInRow"
    int desiredItemWidth = (collectionViewWidth - (itemsInRow - 1) * 10) / itemsInRow;
    
    // Height is fixed
    int desiredItemHeight = 150;
    
    // Create size object from above and return
    CGSize itemSize = CGSizeMake(desiredItemWidth, desiredItemHeight);
    
    return itemSize;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
}

#pragma mark PeopleGetGroupsOperationHandler

- (void) receivedGroups: (NSArray *) groups
{
    self.groups = groups;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
    });
}

- (IBAction)handleShowPhotos:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    NSLog(@"btn.tag -> %ld", (long)btn.tag);
    self.selGroup = [self.groups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupPhotos" sender:self];
}

- (IBAction)handleConfigureComments:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    NSLog(@"btn.tag -> %ld", (long)btn.tag);
    self.selGroup = [self.groups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupDetail" sender:self];
}


@end

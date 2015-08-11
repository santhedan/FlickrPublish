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
@property (nonatomic, strong) NSArray* filteredGroups;

@property (nonatomic, strong) Group* selGroup;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL visible;

@end

@implementation GroupManagementController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.visible = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.visible = NO;
    [super viewWillDisappear:animated];
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
    return [self.filteredGroups count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell" forIndexPath:indexPath];
    Group* g = [self.filteredGroups objectAtIndex:indexPath.item];
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
    if (g.imageData != nil)
    {
        cell.thumbnail.image = [UIImage imageWithData:g.imageData];
    }
    else
    {
        cell.thumbnail.image = [UIImage imageNamed:@"small_placeholder"];
    }
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
    NSArray* sortedGroups = [groups sortedArrayUsingSelector:@selector(compare:)];
    self.groups = sortedGroups;
    self.filteredGroups = sortedGroups;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
    });
    if ([self.groups count] > 0)
    {
        // Get the first group
        Group* g = [self.groups objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:g.groupImagePath Directory:g.id Delegate:self];
        // Get delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Schedule operation
        [delegate enqueueOperation:op];
    }
}

- (IBAction)handleShowPhotos:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    NSLog(@"btn.tag -> %ld", (long)btn.tag);
    self.selGroup = [self.filteredGroups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupPhotos" sender:self];
}

- (IBAction)handleConfigureComments:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    NSLog(@"btn.tag -> %ld", (long)btn.tag);
    self.selGroup = [self.filteredGroups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupDetail" sender:self];
}

- (void) receivedFileData: (NSData *) imageData
{
    // Get handle to group
    Group* g = [self.groups objectAtIndex:self.currentIndex];
    // Assign image data
    g.imageData = imageData;
    // Create index path
    NSIndexPath* path = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (path.item < self.filteredGroups.count)
        {
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
        }
    });
    self.currentIndex = self.currentIndex + 1;
    if (self.currentIndex < [self.groups count] && self.visible)
    {
        // Start loading images
        g = [self.groups objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:g.groupImagePath Directory:g.id Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@", searchText];
        NSArray *filteredGroups = [self.groups filteredArrayUsingPredicate:predicate];
        self.filteredGroups = filteredGroups;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    else
    {
        self.filteredGroups = self.groups;
        dispatch_async(dispatch_get_main_queue(), ^{
            [searchBar setText:@""];
            [self.collectionView reloadData];
        });
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.filteredGroups = self.groups;
    dispatch_async(dispatch_get_main_queue(), ^{
        [searchBar setText:@""];
        [self.collectionView reloadData];
    });
}

- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue
{
    
}

@end

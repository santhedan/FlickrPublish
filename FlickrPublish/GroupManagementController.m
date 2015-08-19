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
{
    UIBarButtonItem* sortItem;
    UIImage* placeHolderImage;
}

@property (nonatomic, strong) NSArray* groups;
@property (nonatomic, strong) NSArray* filteredGroups;

@property (nonatomic, strong) Group* selGroup;
@property (nonatomic, assign) NSInteger currentIndex;

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
    // Do any additional setup after loading the view.
    sortItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortOption)];
    self.navigationItem.rightBarButtonItem = sortItem;
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

#pragma mark UIBarButtonItemHandler

- (void) showSortOption
{
    UIAlertController* ctrl = [UIAlertController alertControllerWithTitle:@"Sort photos by" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    // Sort by views
    UIAlertAction* membersAction = [UIAlertAction actionWithTitle:@"Members" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){[self sortByMembers];}];
    UIAlertAction* photosAction = [UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){[self sortByPhotos];}];
    UIAlertAction* nameAction = [UIAlertAction actionWithTitle:@"Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){[self sortByName];}];
    // Sort by views
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){[self dismissViewControllerAnimated:YES completion:nil];}];
    // Add the action to controller
    [ctrl addAction: membersAction];
    [ctrl addAction: photosAction];
    [ctrl addAction: nameAction];
    [ctrl addAction: cancelAction];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        ctrl.popoverPresentationController.barButtonItem = sortItem;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else
    {
        // Now show the alert
        [self presentViewController:ctrl animated:YES completion:nil];
    }
}

- (void) sortByName
{
    @synchronized (self.filteredGroups) {
        NSArray* sortedArray = [self.filteredGroups sortedArrayUsingSelector:@selector(compare:)];
        self.filteredGroups = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void) sortByMembers
{
    @synchronized (self.filteredGroups) {
        NSArray* sortedArray = [self.filteredGroups sortedArrayUsingSelector:@selector(compareMembers:)];
        self.filteredGroups = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void) sortByPhotos
{
    @synchronized (self.filteredGroups) {
        NSArray* sortedArray = [self.filteredGroups sortedArrayUsingSelector:@selector(comparePhotos:)];
        self.filteredGroups = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
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

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    @synchronized (self.filteredGroups) {
        return [self.filteredGroups count];
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell" forIndexPath:indexPath];
    Group* g = nil;
    @synchronized (self.filteredGroups) {
        g = [self.filteredGroups objectAtIndex:indexPath.item];
    }

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
        cell.thumbnail.image = g.imageData;
    }
    else
    {
        if (placeHolderImage == nil)
        {
            placeHolderImage = [UIImage imageNamed:@"small_placeholder"];
        }
        cell.thumbnail.image = placeHolderImage;
        // Request image download - Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:g.groupImagePath Directory:g.id FileId:g.id Delegate:self];
        // Get delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Schedule operation
        [delegate enqueueOperation:op];
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
}

#pragma mark EventHandler

- (IBAction)handleShowPhotos:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    self.selGroup = [self.filteredGroups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupPhotos" sender:self];
}

- (IBAction)handleConfigureComments:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    self.selGroup = [self.filteredGroups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupDetail" sender:self];
}

#pragma mark DownloadFileOperationDelegate

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId
{
    if (imageData != nil)
    {
        @synchronized (self.groups) {
            // We have to find a photo with id fileId - so first create a filter predicate
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", fileId];
            NSArray *tempGroups = [self.groups filteredArrayUsingPredicate:predicate];
            if (tempGroups.count == 1)
            {
                Group* g = [tempGroups objectAtIndex:0];
                g.imageData = [UIImage imageWithData: imageData];
                // get index of g in filtered group
                dispatch_async(dispatch_get_main_queue(), ^{
                    @synchronized (self.filteredGroups) {
                        NSInteger index = [self.filteredGroups indexOfObject:g];
                        if (index >= 0)
                        {
                            // Create indexPath
                            NSIndexPath* path = [NSIndexPath indexPathForItem:index inSection:0];
                            // Reload the cell
                            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
                        }
                    }
                });
            }
        }
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        @synchronized (self.filteredGroups) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@", searchText];
            NSArray *filteredGroups = [self.groups filteredArrayUsingPredicate:predicate];
            self.filteredGroups = filteredGroups;
            dispatch_async(dispatch_get_main_queue(), ^{
                @synchronized (self.filteredGroups) {
                    [self.collectionView reloadData];
                }
            });
        }
    }
    else
    {
        @synchronized (self.filteredGroups) {
            self.filteredGroups = self.groups;
            dispatch_async(dispatch_get_main_queue(), ^{
                [searchBar setText:@""];
                [searchBar resignFirstResponder];
                [self.collectionView reloadData];
            });
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    @synchronized (self.filteredGroups) {
        self.filteredGroups = self.groups;
        dispatch_async(dispatch_get_main_queue(), ^{
            [searchBar setText:@""];
            [searchBar resignFirstResponder];
            [self.collectionView reloadData];
        });
    }
}

#pragma mark UnwindSegueHandler

- (IBAction)unwindToContainerVC:(UIStoryboardSegue *)segue
{
    // Get delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Start save operation
    [delegate performSaveComment];
}

@end

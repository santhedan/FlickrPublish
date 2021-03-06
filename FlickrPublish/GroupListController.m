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
#import "GroupPoolPhotoDisplayController.h"

@interface GroupListController ()
{
    NSInteger selectedCount;
    UIBarButtonItem* addItem;
    Group* selGroup;
    UIImage* placeHolderImage;
}

@property (nonatomic, strong) NSArray* groupsToExclude;

@property (nonatomic, strong) NSArray* groups;

@property (nonatomic, strong) PhotoInfo *info;

@property (nonatomic, assign) NSInteger currentIndex;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation GroupListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.photo.name;
    //
    self.progressContainer.layer.cornerRadius = 3.0f;
    self.progressContainer.layer.borderWidth = 0.5f;
    self.progressContainer.layer.cornerRadius = 3.0f;
    self.progressContainer.layer.borderColor = [self.progressLabel tintColor].CGColor;
    self.progressLabel.text = @"Fetching groups";
    //
    addItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(handleAdd)];
    self.navigationItem.rightBarButtonItem = addItem;
    //
    self.currentIndex = 0;
    self.imageToAdd.image = self.photo.imageData;
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
    //
    [addItem setEnabled:NO];
    selectedCount = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        // Cancel all operations
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate cancelAllOperation];
        // Do your stuff here
        self.groups = nil;
        self.groupsToExclude = nil;
    }
    [super viewWillDisappear:animated];
}

#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowGroupPhotos"])
    {
        GroupPoolPhotoDisplayController* ctrl = (GroupPoolPhotoDisplayController *) segue.destinationViewController;
        ctrl.group = selGroup;
        ctrl.photoListType = GROUP;
    }
}

#pragma mark UICollectionViewDataSource

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
        // Request download of image - Create download operation
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
    cell.showPhotosBtn.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
    cell.showPhotosBtn.tag = indexPath.item;
    //
    cell.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    //
    if (g.selected)
    {
        cell.selectedImg.hidden = NO;
        cell.selectedImg.image = [UIImage imageNamed:@"selectedState"];
    }
    else
    {
        cell.selectedImg.hidden = YES;
    }
    //
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Group* g = [self.groups objectAtIndex:indexPath.item];
    g.selected = !(g.selected);
    if (g.selected)
    {
        selectedCount++;
    }
    else
    {
        selectedCount--;
    }
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectedCount > 0)
        {
            [addItem setEnabled:YES];
        }
        else
        {
            [addItem setEnabled:NO];
        }
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 28;
    
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
        //
        self.progressContainer.hidden = YES;
        self.progressLabel.hidden = YES;
        [addItem setEnabled:YES];
    });
}

#pragma mark PhotosGetAllContextsHandler

- (void) receivedPhotoGroups: (NSArray *) groups Info: (PhotoInfo *) info
{
    self.groupsToExclude = groups;
    self.info = info;
    self.currentIndex = 0;
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PeopleGetGroups* request = [[PeopleGetGroups alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid];
    // Create operation
    PeopleGetGroupsOperation* op = [[PeopleGetGroupsOperation alloc] initWithRequest:request ExcludeGroups:self.groupsToExclude Delegate:self];
    //
    [delegate enqueueOperation:op];
}

#pragma mark UIBarButtonHandler

- (void) handleAdd
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
        // DIsable Add
        [addItem setEnabled:NO];
        self.progressContainer.hidden = NO;
        self.progressLabel.hidden = NO;
        self.progressContainer.layer.backgroundColor = [UIColor grayColor].CGColor;
        self.progressContainer.layer.cornerRadius = 3.0f;
        self.progressContainer.layer.borderColor = [self.progressLabel tintColor].CGColor;
        self.progressLabel.backgroundColor = [UIColor grayColor];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.text = @"Adding photo to selected groups";
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create request
        GroupsPoolsAddOperation* op = [[GroupsPoolsAddOperation alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token PhotoId:self.photo.id Groups:gArr Delegate:self];
        //
        [delegate enqueueOperation:op];
        //
        [self.activityIndicator startAnimating];
    }
}

#pragma mark GroupsPoolsAddOperationHandler

- (void) addedToGroups: (NSArray *) groups
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text = @"Updating groups";
    });
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosGetAllContexts* request = [[PhotosGetAllContexts alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token PhotoId:self.photo.id];
    // Create operation
    PhotosGetAllContextsOperation* op = [[PhotosGetAllContextsOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
}

- (void) showProgressMessage: (NSString *) progressMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text = progressMessage;
    });
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
                    NSInteger index = [self.groups indexOfObject:g];
                    if (index >= 0)
                    {
                        // Create indexPath
                        NSIndexPath* path = [NSIndexPath indexPathForItem:index inSection:0];
                        // Reload the cell
                        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
                    }
                });
            }
        }
    }
}

#pragma mark EventHandler

- (IBAction)handleShowPhotos:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    selGroup = [self.groups objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowGroupPhotos" sender:self];
}

@end

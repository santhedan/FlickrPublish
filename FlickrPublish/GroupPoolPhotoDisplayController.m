//
//  GroupPoolPhotoDisplayController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupPoolPhotoDisplayController.h"
#import "AppDelegate.h"
#import "GroupsPoolsGetPhotos.h"
#import "GroupsPoolsGetPhotosOperation.h"
#import "PhotoCell.h"
#import "Photo.h"
#import "LargePhotoViewerController.h"

@interface GroupPoolPhotoDisplayController ()
{
    UIBarButtonItem* sortItem;
    NSInteger selectedCount;
    Photo* selPhoto;
    BOOL commentsAndFavs;
    UIImage* placeHolderImage;
}

@property (nonatomic, strong) NSArray* photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation GroupPoolPhotoDisplayController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;
    commentsAndFavs = NO;
    // Do any additional setup after loading the view.
    self.title = self.group.name;
    //
    sortItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortOption)];
    self.navigationItem.rightBarButtonItem = sortItem;
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get group description
    GroupsPoolsGetPhotos* request = [[GroupsPoolsGetPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token GroupId:self.group.id];
    GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithRequest:request Delegate:self];
    [delegate enqueueOperation:op];
    [self.activityIndicator startAnimating];
    //
    selectedCount = 0;
    [self.addCommentCmd setEnabled:NO];
    [self.commentAndFavCmd setEnabled:NO];
    [self.faveCmd setEnabled:NO];
    //
    if (self.currentIndex < [self.photos count])
    {
        // Start loading images
        Photo* p = [self.photos objectAtIndex:self.currentIndex];
        // Create download operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:nil Delegate:self];
        // Delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate enqueueOperation:op];
    }
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
    UIAlertAction* viewAction = [UIAlertAction actionWithTitle:@"Views" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){[self sortByViews];}];
    // Sort by views
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){[self dismissViewControllerAnimated:YES completion:nil];}];
    // Add the action to controller
    [ctrl addAction: viewAction];
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

- (void) sortByViews
{
    @synchronized (self.photos) {
        NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareViews:)];
        self.photos = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

#pragma mark EventHandler

- (IBAction)addComments:(id)sender
{
    commentsAndFavs = NO;
    NSMutableArray* photoIds = [[NSMutableArray alloc] init];
    for (Photo* p in self.photos) {
        if (p.selected)
        {
            [photoIds addObject:p.id];
        }
    }
    // Get app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get comment for the group
    NSString* comment = [delegate getCommentForGroup:self.group.id];
    if (comment == nil)
    {
        comment = [self.group getDefaultComment];
        [delegate addComment:comment forGroup:self.group.id];
    }
    //
    if (photoIds.count > 0)
    {
        // Disable add comment button
        [self.addCommentCmd setEnabled:NO];
        [self.commentAndFavCmd setEnabled:NO];
        [self.faveCmd setEnabled:NO];
        // Create operation
        PhotosCommentsAddCommentOperation* op = [[PhotosCommentsAddCommentOperation alloc] initWithPhotoIds:photoIds GroupId:self.group.id Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        [self.activityIndicator startAnimating];
    }
}

- (IBAction)addFaves:(id)sender
{
    commentsAndFavs = NO;
    NSMutableArray* photoIds = [[NSMutableArray alloc] init];
    for (Photo* p in self.photos) {
        if (p.selected)
        {
            [photoIds addObject:p.id];
        }
    }
    // Get app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //
    if (photoIds.count > 0)
    {
        // Disable add comment button
        [self.addCommentCmd setEnabled:NO];
        [self.commentAndFavCmd setEnabled:NO];
        [self.faveCmd setEnabled:NO];
        // Create operation
        FavoritesAddOperation* op = [[FavoritesAddOperation alloc] initWithPhotoIds:photoIds GroupId:self.group.id Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        [self.activityIndicator startAnimating];
    }
}

- (IBAction)addCommentsAndFaves:(id)sender
{
    commentsAndFavs = YES;
    NSMutableArray* photoIds = [[NSMutableArray alloc] init];
    for (Photo* p in self.photos) {
        if (p.selected)
        {
            [photoIds addObject:p.id];
        }
    }
    // Get app delegate
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get comment for the group
    NSString* comment = [delegate getCommentForGroup:self.group.id];
    if (comment == nil)
    {
        comment = [self.group getDefaultComment];
        [delegate addComment:comment forGroup:self.group.id];
    }
    //
    if (photoIds.count > 0)
    {
        // Disable add comment button
        [self.addCommentCmd setEnabled:NO];
        [self.commentAndFavCmd setEnabled:NO];
        [self.faveCmd setEnabled:NO];
        // Create operation
        PhotosCommentsAddCommentOperation* op = [[PhotosCommentsAddCommentOperation alloc] initWithPhotoIds:photoIds GroupId:self.group.id Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        [self.activityIndicator startAnimating];
    }
}

- (IBAction)handleViewPhoto:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    selPhoto = [self.photos objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowLargeImageInNewScreen" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    LargePhotoViewerController* ctrl = (LargePhotoViewerController *)segue.destinationViewController;
    ctrl.photo = selPhoto;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    // Configure the cell
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    cell.imageTitle.text = p.name;
    cell.imageViews.text = [NSString stringWithFormat:@"%ld", (long)p.views];
    //
    cell.viewButton.layer.borderWidth = 1.0f;
    cell.viewButton.layer.borderColor = [cell.viewButton tintColor].CGColor;
    cell.viewButton.tag = indexPath.item;
    //
    if (p.imageData != nil)
    {
        cell.thumbnailSmall.image = p.imageData;
    }
    else
    {
        if (placeHolderImage == nil)
        {
            placeHolderImage = [UIImage imageNamed:@"large_placeholder"];
        }
        cell.thumbnailSmall.image = placeHolderImage;
        // Request download of image
        // Get app delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:nil FileId:p.id Delegate:self];
        // Start download
        [delegate enqueueOperation:op];
    }
    if (p.selected)
    {
        [cell.selState setHidden:NO];
    }
    else
    {
        [cell.selState setHidden:YES];
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    p.selected = !(p.selected);
    if (p.selected)
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
            [self.addCommentCmd setEnabled:YES];
            [self.commentAndFavCmd setEnabled:YES];
            [self.faveCmd setEnabled:YES];
        }
        else
        {
            [self.addCommentCmd setEnabled:NO];
            [self.commentAndFavCmd setEnabled:NO];
            [self.faveCmd setEnabled:NO];
        }
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 20;
    
    // Divide this with the minimum desired width of the cell
    int itemsInRow = collectionViewWidth / 150;
    
    // So we can fit "itemsInRow"
    int desiredItemWidth = (collectionViewWidth - (itemsInRow - 1) * 10) / itemsInRow;
    
    // Now calculate the height of the item
    int desiredItemHeight = desiredItemWidth;
    
    // Create size object from above and return
    CGSize itemSize = CGSizeMake(desiredItemWidth, desiredItemHeight);
    
    return itemSize;
}

- (void) willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.collectionView reloadData];
}

#pragma mark GroupsPoolsGetPhotosOperationDelegate

- (void) receivedGroupPhotos: (NSArray *) photos
{
    self.photos = photos;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
    });
}

#pragma mark PhotosCommentsAddCommentOperationDelegate

- (void) commentsAdded
{
    if (commentsAndFavs)
    {
        [self addFaves:nil];
    }
    else
    {
        // Index counter
        int i = 0;
        // IndexPath collection
        NSMutableArray* indexes = [[NSMutableArray alloc] init];
        for (Photo* p in self.photos) {
            if (p.selected)
            {
                p.selected = NO;
                NSIndexPath* path = [NSIndexPath indexPathForItem:i inSection:0];
                [indexes addObject:path];
            }
            i++;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadItemsAtIndexPaths:indexes];
            [self.activityIndicator stopAnimating];
            [self.addCommentCmd setEnabled:NO];
            [self.commentAndFavCmd setEnabled:NO];
            [self.faveCmd setEnabled:NO];
        });
    }
}

#pragma mark FavoritesAddOperationDelegate

- (void) favoritesAdded
{
    commentsAndFavs = NO;
    // Index counter
    int i = 0;
    // IndexPath collection
    NSMutableArray* indexes = [[NSMutableArray alloc] init];
    for (Photo* p in self.photos) {
        if (p.selected)
        {
            p.selected = NO;
            NSIndexPath* path = [NSIndexPath indexPathForItem:i inSection:0];
            [indexes addObject:path];
        }
        i++;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadItemsAtIndexPaths:indexes];
        [self.activityIndicator stopAnimating];
        [self.addCommentCmd setEnabled:NO];
        [self.commentAndFavCmd setEnabled:NO];
        [self.faveCmd setEnabled:NO];
    });
}

#pragma mark DownloadFileOperationDelegate

- (void) receivedFileData: (NSData *) imageData FileId: (NSString *) fileId
{
    @synchronized (self.photos) {
        // We have to find a photo with id fileId - so first create a filter predicate
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.id == %@", fileId];
        NSArray *filteredPhotos = [self.photos filteredArrayUsingPredicate:predicate];
        if (filteredPhotos.count == 1)
        {
            Photo* p = [filteredPhotos objectAtIndex:0];
            p.imageData = [UIImage imageWithData: imageData];
            // get index of p
            NSInteger index = [self.photos indexOfObject:p];
            // Create indexPath
            NSIndexPath* path = [NSIndexPath indexPathForItem:index inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Reload the cell
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:path, nil]];
            });
        }
    }
}

@end

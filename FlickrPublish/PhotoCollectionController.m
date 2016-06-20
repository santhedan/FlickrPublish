//
//  PhotoCollectionController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 14/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotoCollectionController.h"
#import "PhotoCell.h"
#import "Photo.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PhotosetGetPhotosOperation.h"
#import "GroupListController.h"
#import "LargePhotoViewerController.h"

@interface PhotoCollectionController ()
{
    UIBarButtonItem* sortItem;
    Photo* selPhoto;
    UIImage* placeHolderImage;
}

@property (nonatomic, strong) NSArray* photos;

@property (nonatomic, strong) Photo* selectedPhoto;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation PhotoCollectionController

static NSString * const reuseIdentifier = @"PhotoCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentIndex = 0;
    self.title = self.set.name;
    
    // Do any additional setup after loading the view.
    sortItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortOption)];
    self.navigationItem.rightBarButtonItem = sortItem;
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosetGetPhotos* request = [[PhotosetGetPhotos alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid PhotosetId:self.set.id];
    // Create operation
    PhotosetGetPhotosOperation* op = [[PhotosetGetPhotosOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
    //
    [self.activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    self.photos = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate cancelAllOperation];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        // Do your stuff here
        self.photos = nil;
    }
    [super viewWillDisappear:animated];
}

#pragma mark UIBarButtonHandler

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

- (void) sortByFaves
{
    @synchronized (self.photos) {
        NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareFaves:)];
        self.photos = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void) sortByComments
{
    @synchronized (self.photos) {
        NSArray* sortedArray = [self.photos sortedArrayUsingSelector:@selector(compareComments:)];
        self.photos = sortedArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ShowGroups"])
    {
        GroupListController* ctrl = (GroupListController *)[segue destinationViewController];
        ctrl.photo = self.selectedPhoto;
    }
    else if ([segue.identifier isEqualToString:@"ShowLargeImageInNewScreen"])
    {
        LargePhotoViewerController* ctrl = (LargePhotoViewerController *)segue.destinationViewController;
        ctrl.photo = selPhoto;
        ctrl.showProfile = NO;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    @synchronized (self.photos) {
        return self.photos.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Photo* p = [self.photos objectAtIndex:indexPath.item];
    cell.imageTitle.text = p.name;
    cell.imageViews.text = [NSString stringWithFormat:@"%ld", (long)p.views];
    //
    cell.viewButton.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
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
        // Request photo download - Get app delegate
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        // Create operation
        DownloadFileOperation* op = [[DownloadFileOperation alloc] initWithURL:p.smallImageURL Directory:self.set.id FileId:p.id Delegate:self];
        // Start download
        [delegate enqueueOperation:op];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the width of the collection view after removing the padding
    float collectionViewWidth = collectionView.frame.size.width - 28;
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPhoto = [self.photos objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:@"ShowGroups" sender:self];
}

#pragma mark PhotosetGetPhotosHandler

- (void) receivedPhotos: (NSArray *) photos
{
    self.photos = photos;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self.activityIndicator stopAnimating];
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

#pragma mark EventHandler

- (IBAction)handleViewPhoto:(id)sender
{
    UIButton* btn = (UIButton *)sender;
    selPhoto = [self.photos objectAtIndex:btn.tag];
    [self performSegueWithIdentifier:@"ShowLargeImageInNewScreen" sender:self];
}

@end

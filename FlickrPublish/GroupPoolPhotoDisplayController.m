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
#import "InterestingnessGetList.h"

@interface GroupPoolPhotoDisplayController ()
{
    UIBarButtonItem* sortItem;
    NSInteger selectedCount;
    Photo* selPhoto;
    BOOL commentsAndFavs;
    UIImage* placeHolderImage;
    NSInteger currentPage;
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
    currentPage = 1;
    commentsAndFavs = NO;
    // Do any additional setup after loading the view.
    if (self.showGroupPhotos)
    {
        self.title = self.group.name;
    }
    else if (self.showExplorePhotos)
    {
        self.title = @"Explore";
    }
    else
    {
        self.title = [NSString stringWithFormat:@"%@'s Photos", self.userName];
    }
    //
    sortItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(showSortOption)];
    self.navigationItem.rightBarButtonItem = sortItem;
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (self.showGroupPhotos)
    {
        // Get group description
        GroupsPoolsGetPhotos* request = [[GroupsPoolsGetPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token GroupId:self.group.id];
        GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithRequest:request Delegate:self];
        [delegate enqueueOperation:op];
    }
    else if (self.showExplorePhotos)
    {
        // Get group description
        InterestingnessGetList* request = [[InterestingnessGetList alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token PageNumber:currentPage];
        GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithIntRequest:request Delegate:self];
        [delegate enqueueOperation:op];
    }
    else
    {
        // Get group description
        PeopleGetPublicPhotos* request = [[PeopleGetPublicPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token UserID:self.userId PageNumber:currentPage];
        PeopleGetPublicPhotosOperation* op = [[PeopleGetPublicPhotosOperation alloc] initWithRequest:request Delegate:self];
        [delegate enqueueOperation:op];
    }
    self.progressViewContainer.hidden = NO;
    [self.activityIndicator startAnimating];
    //
    selectedCount = 0;
    [self.addCommentCmd setEnabled:NO];
    [self.commentAndFavCmd setEnabled:NO];
    [self.faveCmd setEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.showGroupPhotos)
    {
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
            self.progressViewContainer.hidden = NO;
            [self.activityIndicator startAnimating];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment" message:@"Enter your comment - Leave blank for default comment" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        UITextField *commentField = [alertView textFieldAtIndex:0];
        commentField.placeholder = @"Leave blank for default comment";
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UITextField *commentField = [alertView textFieldAtIndex:0];
        //
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
        NSString* comment = commentField.text;
        if (comment.length == 0)
        {
            comment = @"Good capture. Thank you for sharing.";
        }
        comment = [comment stringByAppendingString:@"\n<b>Commented using </b><a href='https://itunes.apple.com/us/app/fotopub-for-flickr/id1020917730?mt=8'>&nbsp;&nbsp;FotoPub for Flickr</a>\n<img src='https://c2.staticflickr.com/4/3761/20292546278_f0fcbec8f7_s.jpg' width='75' height='75' alt='FotoPub for Flickr' />\n"];
        //
        if (photoIds.count > 0)
        {
            // Disable add comment button
            [self.addCommentCmd setEnabled:NO];
            [self.commentAndFavCmd setEnabled:NO];
            [self.faveCmd setEnabled:NO];
            // Create operation
            PhotosCommentsAddCommentOperation* op = [[PhotosCommentsAddCommentOperation alloc] initWithPhotoIds:photoIds Comment:comment Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
            [delegate enqueueOperation:op];
            self.progressViewContainer.hidden = NO;
            [self.activityIndicator startAnimating];
        }
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
        FavoritesAddOperation* op = [[FavoritesAddOperation alloc] initWithPhotoIds:photoIds Key:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token Delegate:self];
        [delegate enqueueOperation:op];
        self.progressViewContainer.hidden = NO;
        [self.activityIndicator startAnimating];
    }
}

- (IBAction)addCommentsAndFaves:(id)sender
{
    commentsAndFavs = YES;
    if (self.showGroupPhotos)
    {
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
            self.progressViewContainer.hidden = NO;
            [self.activityIndicator startAnimating];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment" message:@"Enter your comment - Leave blank for default comment" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
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
    if (self.showGroupPhotos)
    {
        ctrl.showProfile = YES;
    }
    else if (self.showExplorePhotos)
    {
        ctrl.showProfile = YES;
    }
    else
    {
        ctrl.showProfile = NO;
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.photos != nil)
    {
        return (self.photos.count + 1);
    }
    else
    {
        return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.photos.count)
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
    else
    {
        UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MorePhotoCell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.photos.count)
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
    else if (indexPath.item == self.photos.count)
    {
        currentPage = currentPage + 1;
        //
        AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (self.showGroupPhotos)
        {
            // Get group description
            GroupsPoolsGetPhotos* request = [[GroupsPoolsGetPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token GroupId:self.group.id PageNumber:currentPage];
            GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithRequest:request Delegate:self];
            [delegate enqueueOperation:op];
        }
        else if (self.showExplorePhotos)
        {
            // Get group description
            InterestingnessGetList* request = [[InterestingnessGetList alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token PageNumber:currentPage];
            GroupsPoolsGetPhotosOperation* op = [[GroupsPoolsGetPhotosOperation alloc] initWithIntRequest:request Delegate:self];
            [delegate enqueueOperation:op];
        }
        else
        {
            // Get group description
            PeopleGetPublicPhotos* request = [[PeopleGetPublicPhotos alloc] initWithKey:API_KEY Secret:delegate.hmacsha1Key Token:delegate.token UserID:self.userId PageNumber:currentPage];
            PeopleGetPublicPhotosOperation* op = [[PeopleGetPublicPhotosOperation alloc] initWithRequest:request Delegate:self];
            [delegate enqueueOperation:op];
        }
        self.progressViewContainer.hidden = NO;
        [self.activityIndicator startAnimating];
        //
        selectedCount = 0;
        [self.addCommentCmd setEnabled:NO];
        [self.commentAndFavCmd setEnabled:NO];
        [self.faveCmd setEnabled:NO];
    }
}

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

#pragma mark GroupsPoolsGetPhotosOperationDelegate

- (void) receivedGroupPhotos: (NSArray *) photos
{
    if (self.photos == nil)
    {
        self.photos = photos;
    }
    else
    {
        NSMutableArray* tempArr = [[NSMutableArray alloc] init];
        [tempArr addObjectsFromArray:self.photos];
        [tempArr addObjectsFromArray:photos];
        // Now assign the photos to self.photos
        self.photos = tempArr;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        self.progressViewContainer.hidden = YES;
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
            self.progressViewContainer.hidden = YES;
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
        self.progressViewContainer.hidden = YES;
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

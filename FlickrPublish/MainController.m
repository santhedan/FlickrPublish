//
//  MainController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "MainController.h"
#import "PhotosetGetList.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PhotosetCell.h"
#import "PhotoSet.h"
#import "PhotoCollectionController.h"

@interface MainController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray* photosets;

@property (nonatomic, strong) PhotoSet* selectedSet;

@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Your Sets";
    //
    [self.activityIndicator startAnimating];
    //
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Create request and operation and execute
    PhotosetGetList* request = [[PhotosetGetList alloc] initWithKey: API_KEY Secret: delegate.hmacsha1Key Token:delegate.token UserID:delegate.nsid];
    // Create operation
    PhotosetGetListOperation* op = [[PhotosetGetListOperation alloc] initWithRequest:request Delegate:self];
    //
    [delegate enqueueOperation:op];
    //
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receivedPhotoSets: (NSArray *) photosets
{
    self.photosets = photosets;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self.tableView reloadData];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PhotoCollectionController* ctrl = segue.destinationViewController;
    ctrl.set = self.selectedSet;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photosets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoSetCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    PhotoSet* set = [self.photosets objectAtIndex:indexPath.item];
    cell.photosetName.text = set.name;
    cell.photos.text = set.photos;
    cell.videos.text = set.videos;
    cell.views.text = set.views;
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoSet* set = [self.photosets objectAtIndex:indexPath.item];
    self.selectedSet = set;
    [self performSegueWithIdentifier:@"ShowPhotos" sender:self];
}

@end

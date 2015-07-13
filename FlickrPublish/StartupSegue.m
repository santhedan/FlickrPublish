//
//  StartupSegue.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "StartupSegue.h"

@implementation StartupSegue

- (void) perform
{
    // Just replace the navigation stack with new set of controllers
    // TODO: Check for saved credentials and then perform the navigation
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    [navigationController setViewControllers:@[destinationController] animated:YES];
}

@end

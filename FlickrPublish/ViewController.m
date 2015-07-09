//
//  ViewController.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 09/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Do we have authentication token?
    NSString* authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    
    if (authToken)
    {
        [self performSegueWithIdentifier:@"MainSegue" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"AuthSegue" sender:nil];
    }
    // Dismiss self
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

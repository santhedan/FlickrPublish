//
//  LoadGroupComments.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "LoadGroupComments.h"

@interface LoadGroupComments()

@property (nonatomic, strong) id<LoadGroupCommentsHandler> handler;

@end

@implementation LoadGroupComments

- (instancetype) initWithHandler: (id<LoadGroupCommentsHandler>) handler
{
    self = [super init];
    if (self)
    {
        self.handler = handler;
    }
    return self;
}

- (void) main
{
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        // Path to save dictionary
        NSString* dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"groupcomments.out"];
        // Write dictionary
        NSDictionary* groupComments = [NSDictionary dictionaryWithContentsOfFile:dictPath];
        // Inform delegate
        [self.handler loadedGroupComments:groupComments];
    }
}

@end

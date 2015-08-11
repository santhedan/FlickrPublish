//
//  SaveGroupComments.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "SaveGroupComments.h"

@interface SaveGroupComments()

@property (nonatomic, strong) NSDictionary* groupComments;

@property (nonatomic, strong) id<SaveGroupCommentsHandler> handler;

@end

@implementation SaveGroupComments

- (instancetype) initWithGroupComments: (NSDictionary*) groupComments Handler: (id<SaveGroupCommentsHandler>) handler
{
    self = [super init];
    if (self)
    {
        self.groupComments = groupComments;
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
        [self.groupComments writeToFile:dictPath atomically:YES];
        // Inform handler
        if (self.handler != nil)
        {
            [self.handler didSaveGroupComments];
        }
    }
}

@end

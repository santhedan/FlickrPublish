//
//  PhotosGetAllContextsOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosGetAllContextsOperation.h"
#import "Group.h"

@interface PhotosGetAllContextsOperation()

@property (nonatomic, strong) PhotosGetAllContexts *request;

@property (nonatomic, strong) id<PhotosGetAllContextsHandler> delegate;

@end

@implementation PhotosGetAllContextsOperation

- (instancetype) initWithRequest: (PhotosGetAllContexts *) request Delegate:(id<PhotosGetAllContextsHandler>) delegate
{
    self = [super init];
    if (self)
    {
        self.request = request;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // Create a NSURL from the request
    NSURL *url = [NSURL URLWithString:[self.request getUrl]];
    //
    NSData* response = [NSData dataWithContentsOfURL:url];
    // Create empty return value
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    // Parse the data
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* contexts = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [contexts valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                NSArray* groupArray = [contexts valueForKey:@"pool"];
                for (NSDictionary *group in groupArray)
                {
                    // Create Photo object
                    NSString* groupId = [group valueForKey:@"id"];
                    //
                    [groups addObject:groupId];
                }
            }
        }
    }
    // Call delegate
    [self.delegate receivedPhotoGroups:groups];
}

@end

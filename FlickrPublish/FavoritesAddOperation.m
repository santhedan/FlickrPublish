//
//  FavoritesAddOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 18/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "FavoritesAddOperation.h"
#import "FavoritesAdd.h"

@interface FavoritesAddOperation()

@property (nonatomic, strong) NSArray* photos;

@property (nonatomic, strong) NSString* groupId;

@property (nonatomic, strong) NSString* key;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) id<FavoritesAddOperationDelegate> delegate;

@end

@implementation FavoritesAddOperation

- (instancetype) initWithPhotoIds: (NSArray *) photos GroupId: (NSString *) groupId Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<FavoritesAddOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.photos = photos;
        self.groupId = groupId;
        self.key = key;
        self.secret = secret;
        self.token = token;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // For each photo add the comment
    for (NSString* photoId in self.photos)
    {
        // Create request
        FavoritesAdd* request = [[FavoritesAdd alloc] initWithKey:self.key Secret:self.secret Token:self.token PhotoId:photoId];
        // Create NSURL object from request URL
        NSURL* url = [NSURL URLWithString:[request getUrl]];
        // Create a mutable request
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[request getBody]];
        // Create response and error object
        NSURLResponse* response = nil;
        NSError* error = nil;
        [FavoritesAddOperation sendSynchronousDataTaskWithURL:urlRequest returningResponse:&response error:&error];
    }
    [self.delegate favoritesAdded];
}

+ (NSData *)sendSynchronousDataTaskWithURL:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *data = nil;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *taskResponse, NSError *taskError) {
        data = taskData;
        if (response) {
            *response = taskResponse;
        }
        if (error) {
            *error = taskError;
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return data;
}

@end

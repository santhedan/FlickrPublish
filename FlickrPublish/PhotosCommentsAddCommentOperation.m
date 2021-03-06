//
//  PhotosCommentsAddCommentOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PhotosCommentsAddCommentOperation.h"
#import "AppDelegate.h"
#import "PhotosCommentsAddComment.h"

@interface PhotosCommentsAddCommentOperation()

@property (nonatomic, strong) NSArray* photos;

@property (nonatomic, strong) NSString* groupId;

@property (nonatomic, strong) NSString* key;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* comment;

@property (nonatomic, strong) NSString* photoid;

@property (nonatomic, strong) id<PhotosCommentsAddCommentOperationDelegate> delegate;

@end

@implementation PhotosCommentsAddCommentOperation

- (instancetype) initWithPhotoIds: (NSArray *) photos GroupId: (NSString *) groupId Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate
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

- (instancetype) initWithPhotoId: (NSString *) photoId Comment: (NSString *) comment Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate;
{
    self = [super init];
    if (self)
    {
        self.photoid = photoId;
        self.comment = comment;
        self.key = key;
        self.secret = secret;
        self.token = token;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype) initWithPhotoIds: (NSArray *) photos Comment: (NSString *) comment Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<PhotosCommentsAddCommentOperationDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.photos = photos;
        self.comment = comment;
        self.key = key;
        self.secret = secret;
        self.token = token;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Get comment for the group
    NSString* comment = @"Good photo";
    if (self.groupId != nil)
    {
        comment = [delegate getCommentForGroup:self.groupId];
    }
    else
    {
        comment = self.comment;
        if (self.photos == nil)
        {
            self.photos = [NSArray arrayWithObjects:self.photoid, nil];
        }
    }
    // For each photo add the comment
    for (NSString* photoId in self.photos)
    {
        // Create request
        PhotosCommentsAddComment* request = [[PhotosCommentsAddComment alloc] initWithKey:self.key Secret:self.secret Token:self.token PhotoId:photoId Comment:comment];
        // Create NSURL object from request URL
        NSURL* url = [NSURL URLWithString:[request getUrl]];
        // Create a mutable request
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[request getBody]];
        // Create response and error object
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* respData = [PhotosCommentsAddCommentOperation sendSynchronousDataTaskWithURL:urlRequest returningResponse:&response error:&error];
        NSString* respStr = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
        if ([respStr containsString:@"\"code\":9"])
        {
            // Wait for 1 second to post comment
            [NSThread sleepForTimeInterval:50.0f];
            [PhotosCommentsAddCommentOperation sendSynchronousDataTaskWithURL:urlRequest returningResponse:&response error:&error];
        }
        if (self.isCancelled)
        {
            // Break as we are cancelled
            break;
        }
    }
    if (!self.isCancelled)
    {
        [self.delegate commentsAdded];
    }
}

+ (NSData *)sendSynchronousDataTaskWithURL:(NSURLRequest *)request returningResponse:(NSURLResponse * __autoreleasing *)response error:(NSError * __autoreleasing *)error {
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

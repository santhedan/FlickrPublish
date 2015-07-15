//
//  GroupsPoolsAddOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 15/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupsPoolsAddOperation.h"
#import "Group.h"
#import "GroupsPoolsAdd.h"

@interface GroupsPoolsAddOperation()

@property (nonatomic, strong) NSString* key;

@property (nonatomic, strong) NSString* secret;

@property (nonatomic, strong) NSString* token;

@property (nonatomic, strong) NSString* photoId;

@property (nonatomic, strong) NSArray* groups;

@property (nonatomic, strong) id<GroupsPoolsAddOperationHandler> delegate;

@end

@implementation GroupsPoolsAddOperation

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PhotoId: (NSString *) photoId Groups: (NSArray *) groups Delegate: (id<GroupsPoolsAddOperationHandler>) delegate
{
    self = [super init];
    if (self)
    {
        self.key = key;
        self.secret = secret;
        self.token = token;
        self.photoId = photoId;
        self.groups = groups;
        self.delegate = delegate;
    }
    return self;
}

- (void) main
{
    // Create an array for groups to which the photo was successfully added
    NSMutableArray* successGroups = [[NSMutableArray alloc] init];
    // Iterate over each group and add photo to each group
    for (Group* group in self.groups) {
        // Create GroupsPoolsAdd request
        GroupsPoolsAdd* request = [[GroupsPoolsAdd alloc] initWithKey:self.key Secret:self.secret Token:self.token PhotoId:self.photoId GroupId:group.id];
        // Create NSURL object from request URL
        NSURL* url = [NSURL URLWithString:[request getUrl]];
        // Create a mutable request
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[request getBody]];
        // Create response and error object
        NSURLResponse* response = nil;
        NSError* error = nil;
        NSData* responseData = [GroupsPoolsAddOperation sendSynchronousDataTaskWithURL:urlRequest returningResponse:&response error:&error];
        // Check if we have any error
        if (error == nil)
        {
            // Convery response to string
            NSString* strResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //
            NSLog(@"Response -> %@", strResponse);
            // Did this call succeed?
            if ([strResponse containsString:@"\"stat\": \"ok\""])
            {
                // Remember this group as a group where photo has been added
                [successGroups addObject:group];
            }
        }
    }
    // Call the delegate
    [self.delegate addedToGroups:successGroups];
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

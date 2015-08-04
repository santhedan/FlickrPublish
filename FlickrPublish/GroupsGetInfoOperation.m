//
//  GroupsGetInfoOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 31/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "GroupsGetInfoOperation.h"

@interface GroupsGetInfoOperation()

@property (nonatomic, strong) GroupsGetInfo* request;

@property (nonatomic, strong) id<GroupsGetInfoOperationDelegate> delegate;

@end

@implementation GroupsGetInfoOperation

- (instancetype) initWithRequest: (GroupsGetInfo *) request Delegate: (id<GroupsGetInfoOperationDelegate>) delegate
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
    // Parse the data
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* groupDetails = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [groupDetails valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                Group* group = [[Group alloc] init];
                group.groupDescription = [[[groupDetails valueForKey:@"group"] valueForKey:@"description"] valueForKey:@"_content"];
                [self.delegate receivedGroupInformation:group];
            }
        }
    }
}

@end

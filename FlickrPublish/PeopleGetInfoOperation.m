//
//  PeopleGetInfoOperation.m
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 19/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import "PeopleGetInfoOperation.h"

@interface PeopleGetInfoOperation()

@property (nonatomic, strong) PeopleGetInfo *request;

@property (nonatomic, strong) id<PeopleGetInfoOperationHandler> delegate;

@end

@implementation PeopleGetInfoOperation

- (instancetype) initWithRequest: (PeopleGetInfo *) request Delegate:(id<PeopleGetInfoOperationHandler>) delegate
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
    Person* person = nil;
    // Parse the data
    if (response != nil)
    {
        // Error code
        NSError* localError = nil;
        NSDictionary* dictPerson = [NSJSONSerialization JSONObjectWithData:response options:0 error:&localError];
        if (localError == nil)
        {
            NSString* status = [dictPerson valueForKey:@"stat"];
            if ([status isEqualToString:@"ok"])
            {
                dictPerson = [dictPerson valueForKey:@"person"];
                person = [[Person alloc] init];
                person.id = [dictPerson valueForKey:@"nsid"];
                person.iconServer = [dictPerson valueForKey:@"iconserver"];
                person.iconFarm = [dictPerson valueForKey:@"iconfarm"];
                person.userName = [[dictPerson valueForKey:@"username"] valueForKey:@"_content"];
                person.realName = [[dictPerson valueForKey:@"realname"] valueForKey:@"_content"];
                person.location = [[dictPerson valueForKey:@"location"] valueForKey:@"_content"];
                person.profileUrl = [[dictPerson valueForKey:@"profileurl"] valueForKey:@"_content"];
                NSNumber* cnt = [[[dictPerson valueForKey:@"photos"] valueForKey:@"count"] valueForKey:@"_content"];
                person.photoCount = [NSString stringWithFormat:@"%@", cnt];
                NSString* url = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg", person.iconFarm, person.iconServer, person.id];
                person.buddyIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            }
        }
    }
    // Call delegate
    [self.delegate receivedInfo: person];
}

@end

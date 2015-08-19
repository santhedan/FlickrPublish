//
//  PeopleGetInfoOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 19/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "PeopleGetInfo.h"

@protocol PeopleGetInfoOperationHandler <NSObject>

@required

- (void) receivedInfo: (Person *) person;

@end

@interface PeopleGetInfoOperation : NSOperation

- (instancetype) initWithRequest: (PeopleGetInfo *) request Delegate:(id<PeopleGetInfoOperationHandler>) delegate;

@end

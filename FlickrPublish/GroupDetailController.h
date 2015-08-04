//
//  GroupDetailController.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "GroupsGetInfoOperation.h"

@interface GroupDetailController : UIViewController <GroupsGetInfoOperationDelegate>

@property (nonatomic, strong) Group* group;

- (void) receivedGroupInformation: (Group *) group;

@end

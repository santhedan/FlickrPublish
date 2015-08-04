//
//  LoadGroupComments.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoadGroupCommentsHandler <NSObject>

@required

- (void) loadedGroupComments: (NSDictionary*) groupComments;

@end

@interface LoadGroupComments : NSOperation

- (instancetype) initWithHandler: (id<LoadGroupCommentsHandler>) handler;

@end

//
//  SaveGroupComments.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 04/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SaveGroupCommentsHandler <NSObject>

@required

- (void) didSaveGroupComments;

@end

@interface SaveGroupComments : NSOperation

- (instancetype) initWithGroupComments: (NSDictionary*) groupComments Handler: (id<SaveGroupCommentsHandler>) handler;

@end

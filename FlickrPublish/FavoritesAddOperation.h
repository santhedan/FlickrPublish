//
//  FavoritesAddOperation.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 18/08/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FavoritesAddOperationDelegate <NSObject>

@required

- (void) favoritesAdded;

@end

@interface FavoritesAddOperation : NSOperation

- (instancetype) initWithPhotoIds: (NSArray *) photos Key: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token Delegate: (id<FavoritesAddOperationDelegate>) delegate;

@end

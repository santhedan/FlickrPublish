//
//  PhotosGetContactsPhotos.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 20/06/16.
//  Copyright © 2016 Sanjay Dandekar. All rights reserved.
//

#import "BaseRequest.h"

@interface PhotosGetContactsPhotos : BaseRequest

@property (nonatomic, strong) NSString* authToken;

@property (nonatomic, strong) NSString* method;

@property (nonatomic, strong) NSString* nojsoncallback;

@property (nonatomic, strong) NSString* format;

@property (nonatomic, strong) NSString* extras;

@property (nonatomic, strong) NSString* perPage;

@property (nonatomic, strong) NSString* pageNo;

- (instancetype) initWithKey: (NSString *) key Secret: (NSString *) secret Token: (NSString *) token PageNumber: (NSInteger) pageNumber;

- (NSString *) getUrl;

@end

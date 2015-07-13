//
//  BaseRequest.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEscapeChars @"`~!@#$^&*()=+[]\\{}|;':\",/<>?"

@interface BaseRequest : NSObject

@property (nonatomic, strong) NSString* url;

@property (nonatomic, strong) NSString* httpVerb;

@end

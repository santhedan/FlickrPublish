//
//  Constants.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#ifndef FlickrPublish_Constants_h
#define FlickrPublish_Constants_h

#define API_KEY @"0da7e7e51f5f84f35379ec9c1fd4bd18"

#define SECRET @"249ea97b7dfe7468"

#define CALLBACK_URL @"flickrpublish://authhandler"

#define FULLNAME_KEY @"FULL_NAME_KEY"

#define AUTHTOKEN_KEY @"AUTHTOKEN_KEY"

#define SECRET_KEY @"SECRET_KEY"

#define NSID_KEY @"NSID_KEY"

#define USERNAME_KEY @"USERNAME_KEY"

typedef NS_ENUM(NSInteger, MembershipType)
{
    MEMBER,
    MODERATOR,
    ADMIN
};

#define GROUP_IMAGE_URL @"http://c3.staticflickr.com/%@/%@/buddyicons/%@.jpg"

#endif

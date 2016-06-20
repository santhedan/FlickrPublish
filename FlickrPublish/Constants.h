//
//  Constants.h
//  FlickrPublish
//
//  Created by Sanjay Dandekar on 10/07/15.
//  Copyright (c) 2015 Sanjay Dandekar. All rights reserved.
//

#ifndef FlickrPublish_Constants_h
#define FlickrPublish_Constants_h

#define API_KEY @"<<Your API Key>>"

#define SECRET @"<<Your Secret Key>>"

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

typedef NS_ENUM(NSInteger, PhotoListType)
{
    GROUP,
    EXPLORE,
    USER,
    CONTACTS
};

#define GROUP_IMAGE_URL @"http://c3.staticflickr.com/%@/%@/buddyicons/%@.jpg"

#endif

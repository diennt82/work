//
//  EventInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClipInfo.h"

@interface EventInfo : NSObject

@property (nonatomic) NSInteger eventID; //35
@property (nonatomic) NSInteger alert;//: 4,
@property (nonatomic, retain) NSString *value;//: "20131231112818000",
@property (nonatomic, retain) NSString *alert_name;//: "motion detected",
@property (nonatomic, retain) NSString *time_stamp;//: "2013-12-31T04:30:15Z",
@property (nonatomic, retain) ClipInfo *clipInfo;
@property (nonatomic) NSInteger numberVideo;

@end


/*
 "id": 11078,
 "alert": 4,
 "value": "20131231112818000",
 "alert_name": "motion detected",
 "time_stamp": "2013-12-31T04:30:15Z",
 "data": [
 {
 "image": "http://s3.amazonaws.com/hubble.wowza.content/642737396B49/snaps/642737396B49_04_20131229180917000.jpg?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=YZwYquVvxCuFrwHkMu94EJ6STNQ%3D",
 "file": "http://s3.amazonaws.com/hubble.wowza.content/642737396B49/clips/642737396B49_04_20131229180917000_00001.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1388472420&Signature=%2FXgeQFF%2BuJXt1fHuJyyif5z%2BYdY%3D",
 "title":
 }
 */
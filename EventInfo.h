//
//  EventInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClipInfo.h"

@interface EventInfo : NSObject

@property (nonatomic, retain) ClipInfo *clipInfo;
@property (nonatomic, copy) NSString *value;//: "20131231112818000",
@property (nonatomic, copy) NSString *alertName;//: "motion detected",
@property (nonatomic, copy) NSString *timeStamp;//: "2013-12-31T04:30:15Z",

@property (nonatomic) NSInteger eventID; //35
@property (nonatomic) NSInteger alert;//: 4,
@property (nonatomic) NSInteger numberVideo;

@end

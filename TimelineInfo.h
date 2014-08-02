//
//  TimelineInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimelineInfo : NSObject

@property (nonatomic, retain) UIImage *snapshotImage;
@property (nonatomic, copy) NSString *eventMessage;
@property (nonatomic, copy) NSString *eventTime;
@property (nonatomic) NSInteger numberVideos;

@end

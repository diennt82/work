//
//  TimelineInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimelineInfo : NSObject

@property (retain, nonatomic) NSString *eventMessage;
@property (retain, nonatomic) NSString *eventTime;
@property (retain, nonatomic) UIImage *snapshotImage;
@property (nonatomic) NSInteger numberVideos;

@end

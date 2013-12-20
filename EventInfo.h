//
//  EventInfo.h
//  BlinkHD_ios
//
//  Created by Developer on 12/20/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventInfo : NSObject

@property (nonatomic) NSInteger eventID; //35
@property (retain, nonatomic) NSString *time_code;//: "20131212074200",
@property (retain, nonatomic) NSString *event_code;//: "01",
@property (retain, nonatomic) NSString *description;//: "All is quiet",
@property (retain, nonatomic) NSString *time_zone;//: "+07.00",
@property (retain, nonatomic) NSString *snaps_url;//: "http://nxcomm-office.no-ip.info/release/events/motion01.jpg"
@property (retain, nonatomic) NSString *clip_url;//: "http://nxcomm-office.no-ip.info/release/events/cam_clip.flv"

@property (retain, nonatomic) UIImage *snapshotImage;
@property (nonatomic) NSInteger numberVideo;

@end

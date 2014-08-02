//
//  H264PlayerVCDelegate.h
//  BlinkHD_ios
//
//  Created by Sven Resch on 2014-08-01.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CameraScanner/CameraScanner.h>

@protocol H264PlayerVCDelegate <NSObject>

- (void)stopStreamFinished:(CamChannel *)camChannel;

@end

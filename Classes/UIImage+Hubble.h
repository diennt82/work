//
//  UIImage+Hubble.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 17/2/14.
//  Copyright (c) 2014 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Hubble)

+ (UIImage *) imageCameraActionPan;
+ (UIImage *)imageMic;
+ (UIImage *)imageMicPressed;
+ (UIImage *)imageVideoGrey;
+ (UIImage *)imageVideoGreyPressed;
+ (UIImage *)imagePhotoGrey;
+ (UIImage *)imagePhotoGreyPressed;

+ (UIImage *)imageRecordVideo;
+ (UIImage *)imageRecordVideoPressed;
+ (UIImage *)imageTakePhoto;
+ (UIImage *)imageTakePhotoPressed;
+ (UIImage *)imageVideoStop;
+ (UIImage *)imageVideoStopPressed;
+ (UIImage *)imageCameraActionPlay;
+ (UIImage *)imageCameraActionPlayPressed;
+ (UIImage *)imageCameraActionPause;
+ (UIImage *)imageCameraActionPausePressed;
//for playback
+ (UIImage *)imageVideoPlay;
+ (UIImage *)imageVideoPause;
+ (UIImage *)imageVerticalVideoClose;
+ (UIImage *)imageVerticalVideoClosePressed;
+ (UIImage *)imageVideoFullScreenClose;
+ (UIImage *)imageVideoFullScreenClosePressed;
+ (UIImage *)imageVideoProgressBG;
+ (UIImage *)imageVideoProgressGreen;
//switch-on and off
+ (UIImage *)imageSwitchOn;
+ (UIImage *)imageSwitchOff;

@end

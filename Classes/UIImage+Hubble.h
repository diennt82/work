//
//  UIImage+Hubble.h
//  BlinkHD_ios
//
//  Created by Jason Lee on 17/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
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
@end

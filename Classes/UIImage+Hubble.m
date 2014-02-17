//
//  UIImage+Hubble.m
//  BlinkHD_ios
//
//  Created by Jason Lee on 17/2/14.
//  Copyright (c) 2014 Smart Panda Ltd. All rights reserved.
//

#import "UIImage+Hubble.h"
#import "define.h"

@implementation UIImage (Hubble)

+ (UIImage *) imageCameraActionPan
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_pan_bg"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_pan_bg@5"];
    }
}

+ (UIImage *)imageMic
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_mic"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_mic@5"];
    }
}

+ (UIImage *)imageMicPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_mic_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_mic_pressed@5.png"];
    }
}

+ (UIImage *)imageVideoGrey
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"video_grey.png"];
    }
    else
    {
        return [UIImage imageNamed:@"video_grey@5.png"];
    }
}
+ (UIImage *)imageVideoGreyPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"video_grey_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"video_grey_pressed@5.png"];
    }
}
+ (UIImage *)imagePhotoGrey
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"photo_grey.png"];
    }
    else
    {
        return [UIImage imageNamed:@"photo_grey@5.png"];
    }
}
+ (UIImage *)imagePhotoGreyPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"photo_grey_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"photo_grey_pressed@5.png"];
    }
}

+ (UIImage *)imageRecordVideo
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_video.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_video@5.png"];
    }
}
+ (UIImage *)imageRecordVideoPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_video_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_video_pressed@5.png"];
    }
}


+ (UIImage *)imageTakePhoto
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_photo.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_photo@5.png"];
    }
}
+ (UIImage *)imageTakePhotoPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_photo_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_photo_pressed@5.png"];
    }
}
+ (UIImage *)imageVideoStop
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_video_stop.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_video_stop@5.png"];
    }
}

+ (UIImage *)imageVideoStopPressed
{
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_video_stop_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_video_stop_pressed@5.png"];
    }
}

@end

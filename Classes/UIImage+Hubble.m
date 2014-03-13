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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_pan_bg"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_mic_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_mic_pressed_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"video_grey_land.png"];
    }
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"video_grey_pressed_land"];
    }
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"photo_grey_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"photo_grey_pressed_land.png"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_video_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_video_pressed_land"];
    }
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_photo_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_photo_pressed_land"];
    }
    
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_video_stop_land"];
    }
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
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_video_stop_pressed_land"];
    }
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_video_stop_pressed.png"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_video_stop_pressed@5.png"];
    }
}

//20140219
+ (UIImage *)imageCameraActionPlay
{
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_play_land"];
    }
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_play"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_play@5"];
    }
}

+ (UIImage *)imageCameraActionPlayPressed
{
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_play_pressed_land"];
    }
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_play_pressed"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_play_pressed@5"];
    }
}

+ (UIImage *)imageCameraActionPause
{
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_pause_land"];
    }
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_pause"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_pause@5"];
    }
}

+ (UIImage *)imageCameraActionPausePressed
{
    if (isPhoneLandscapeMode)
    {
        return [UIImage imageNamed:@"camera_action_pause_pressed_land"];
    }
    if (isiPhone4)
    {
        return [UIImage imageNamed:@"camera_action_pause_pressed"];
    }
    else
    {
        return [UIImage imageNamed:@"camera_action_pause_pressed@5"];
    }
}

//For playback
+ (UIImage *)imageVideoPlay
{
    return [UIImage imageNamed:@"video_play"];
}

+ (UIImage *)imageVideoPause
{
    return [UIImage imageNamed:@"video_pause"];
}

+ (UIImage *)imageVerticalVideoClose
{
    return [UIImage imageNamed:@"vertcal_video_close"];
}

+ (UIImage *)imageVerticalVideoClosePressed
{
    return [UIImage imageNamed:@"vertcal_video_close_pressed"];
}
+ (UIImage *)imageVideoFullScreenClose
{
    return [UIImage imageNamed:@"video_fullscreen_close"];
}
+ (UIImage *)imageVideoFullScreenClosePressed
{
    return [UIImage imageNamed:@"video_fullscreen_close_pressed"];
}

+ (UIImage *)imageVideoProgressBG
{
    return [UIImage imageNamed:@"video_progress_bg"];
}
+ (UIImage *)imageVideoProgressGreen
{
    return [UIImage imageNamed:@"video_progress_green"];
}


+ (UIImage *)imageSwitchOn
{
    return [UIImage imageNamed:@"settings_switch_on.png"];
}
+ (UIImage *)imageSwitchOff
{
    return [UIImage imageNamed:@"settings_switch_off.png"];
}
@end

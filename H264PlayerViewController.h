//
//  H264PlayerViewController.h
//  MBP_ios
//
//  Created by NxComm on 3/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CameraScanner/CameraScanner.h>
#import <CameraScanner/Util.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import <MonitorCommunication/MonitorCommunication.h>
#import <AudioToolbox/AudioToolbox.h>

#import "PlaybackViewController.h"
#import "H264PlayerVCDelegate.h"
#import "PlaylistInfo.h"
#import "PlaylistCell.h"
#import "H264PlayerListener.h"
#import "PlayerCallbackHandler.h"
#import "MelodyViewController.h"
#import "ScrollHorizontalMenu.h"
#import "AudioOutStreamer.h"
#import "UIColor+Hubble.h"
#import "UIImage+Hubble.h"
#import "StunClient.h"
#import "GAITrackedViewController.h"

@interface H264PlayerViewController: GAITrackedViewController <PlayerCallbackHandler, ScanForCameraNotifier, StunClientDelegate, MelodyVCDelegate, UIScrollViewDelegate, ScrollHorizontalMenuDelegate, AudioOutStreamerDelegate>

@property (nonatomic, strong) NSMutableArray *itemImages;
@property (nonatomic, strong) NSMutableArray *itemSelectedImages;
@property (nonatomic, strong) NSTimer *alertTimer;
@property (nonatomic, strong) NSTimer *probeTimer;
@property (nonatomic, strong) StunClient *client;
@property (nonatomic, strong) MelodyViewController *melodyViewController;
@property (nonatomic, strong) CamChannel *selectedChannel;
@property (nonatomic, weak) id<H264PlayerVCDelegate> h264PlayerVCDelegate;

@property (nonatomic) int selectedItemMenu;
@property (nonatomic) int currentMediaStatus;
@property (nonatomic) BOOL h264StreamerIsInStopped;
@property (nonatomic) BOOL recordingFlag;
@property (nonatomic) BOOL askForFWUpgradeOnce;
@property (nonatomic) BOOL iFrameOnlyFlag;

- (void)goBackToCameraList;

@end

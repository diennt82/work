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

@property (nonatomic, weak) IBOutlet ScrollHorizontalMenu *horizMenu;
@property (nonatomic, weak) IBOutlet UIView *menuBackgroundView;

// Touch to talk
@property (nonatomic, weak) IBOutlet UIView *ib_ViewTouchToTalk;
@property (nonatomic, weak) IBOutlet UIButton *ib_buttonTouchToTalk;
@property (nonatomic, weak) IBOutlet UILabel *ib_labelTouchToTalk;

// Recording
@property (nonatomic, weak) IBOutlet UIView *ib_viewRecordTTT;
@property (nonatomic, weak) IBOutlet UIButton *ib_processRecordOrTakePicture;
@property (nonatomic, weak) IBOutlet UIButton *ib_buttonChangeAction;

@property (nonatomic, weak) IBOutlet UIButton *ib_changeToMainRecording;
@property (nonatomic, weak) IBOutlet UILabel *ib_labelRecordVideo;
@property (nonatomic, weak) IBOutlet UILabel *ib_temperature;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *imgViewDrectionPad;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityStopStreamingProgress;
@property (nonatomic, weak) IBOutlet UIImageView *customIndicator;
@property (nonatomic, weak) IBOutlet UILabel *ib_lbCameraNotAccessible;
@property (nonatomic, weak) IBOutlet UILabel *ib_lbCameraName;

@property (nonatomic, weak) IBOutlet UIButton *ib_btShowDebugInfo;
@property (nonatomic, weak) IBOutlet UIButton *sendLogButton;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewVideo;

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

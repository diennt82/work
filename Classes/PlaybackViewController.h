//
//  PlaybackViewController
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <H264MediaPlayer/H264MediaPlayer.h>

#import "EarlierNavigationController.h"
#import "PlaylistInfo.h"
#import "PlaybackListener.h"
#import "PlayerCallbackHandler.h"
#import "UIImage+Hubble.h"
#import "UIFont+Hubble.h"
#import "UIColor+Hubble.h"

@protocol PlaybackDelegate <NSObject>

@optional

- (void)motionEventDeleted;
- (void)playbackStopped;

@end

@interface PlaybackViewController : UIViewController <PlayerCallbackHandler>

@property (nonatomic, weak) id<PlaybackDelegate> playbackVCDelegate;
@property (nonatomic, strong) NSMutableArray *clips;

@property (nonatomic, weak) IBOutlet UIImageView *imageVideo;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIImageView *ib_bg_top_player;

@property (nonatomic, weak) IBOutlet UIView *ib_viewControlPlayer;
@property (nonatomic, weak) IBOutlet UIButton *ib_closePlayBack;
@property (nonatomic, weak) IBOutlet UIButton *ib_playPlayBack;
@property (nonatomic, weak) IBOutlet UISlider *ib_sliderPlayBack;
@property (nonatomic, weak) IBOutlet UILabel *ib_timerPlayBack;
@property (nonatomic, weak) IBOutlet UIButton *ib_zoomingPlayBack;

@property (nonatomic, weak) IBOutlet UIView *ib_myOverlay;
@property (nonatomic, weak) IBOutlet UIView *ib_viewOverlayVideo;
@property (nonatomic, weak) IBOutlet UIButton *ib_delete;
@property (nonatomic, weak) IBOutlet UIButton *ib_download;
@property (nonatomic, weak) IBOutlet UIButton *ib_share;

@property (nonatomic, strong) NSTimer *list_refresher;
@property (nonatomic, strong) PlaylistInfo *clipInfo;
@property (nonatomic, strong) NSMutableArray *clipsInEvent;
@property (nonatomic, strong) NSTimer *timerHideMenu;
@property (nonatomic, copy) NSString *camera_mac;
@property (nonatomic, copy) NSString *urlVideo;
@property (nonatomic) BOOL userWantToBack;
@property (nonatomic) NSInteger intEventId;

- (IBAction)onTimeSliderChange:(id)sender;
- (IBAction)stopStream:(id) sender;
- (IBAction)closePlayBack:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)minimizeVideo:(id)sender;
- (IBAction)deleteVideo:(id)sender;
- (IBAction)downloadVideo:(id)sender;
- (IBAction)shareVideo:(id)sender;

@end

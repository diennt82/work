//
//  PlaybackViewController
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 eBuyNow eCommerce Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <H264MediaPlayer/H264MediaPlayer.h>
#import "PlaylistInfo.h"
#import "PlaybackListener.h"
#import "PlayerCallbackHandler.h"
#import "UIImage+Hubble.h"
#import "UIFont+Hubble.h"
#import "UIColor+Hubble.h"
#import "EarlierNavigationController.h"

@protocol PlaybackDelegate <NSObject>

@optional

- (void)motionEventDeleted;
- (void)playbackStopped;

@end

@interface PlaybackViewController : UIViewController <PlayerCallbackHandler>
{
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *backBarBtnItem;
    IBOutlet UIView *progressView;
}

@property (nonatomic, assign) id<PlaybackDelegate> playbackVCDelegate;
@property (nonatomic, retain) NSMutableArray *clips;

@property (nonatomic, retain) IBOutlet UIImageView *imageVideo;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *ib_bg_top_player;

@property (nonatomic, retain) IBOutlet UIView *ib_viewControlPlayer;
@property (nonatomic, retain) IBOutlet UIButton *ib_closePlayBack;
@property (nonatomic, retain) IBOutlet UIButton *ib_playPlayBack;
@property (nonatomic, retain) IBOutlet UISlider *ib_sliderPlayBack;
@property (nonatomic, retain) IBOutlet UILabel *ib_timerPlayBack;
@property (nonatomic, retain) IBOutlet UIButton *ib_zoomingPlayBack;

@property (nonatomic, retain) IBOutlet UIView *ib_myOverlay;

//for delete, download and share
@property (nonatomic, retain) IBOutlet UIView *ib_viewOverlayVideo;
@property (nonatomic, retain) IBOutlet UIButton *ib_delete;
@property (nonatomic, retain) IBOutlet UIButton *ib_download;
@property (nonatomic, retain) IBOutlet UIButton *ib_share;

@property (nonatomic, retain)  NSTimer *list_refresher;
@property (nonatomic, retain) PlaylistInfo *clipInfo;

@property (nonatomic, retain) NSString *camera_mac;
@property (nonatomic, retain) NSString *urlVideo;
@property (nonatomic, retain) NSMutableArray *clipsInEvent;
@property (nonatomic, retain) NSTimer *timerHideMenu;
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

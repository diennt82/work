//
//  PlaybackViewController
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
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
-(void)motioEventDeleted;

@end

@interface PlaybackViewController : UIViewController<PlayerCallbackHandler>

{
    IBOutlet UIImageView *imageVideo;
    IBOutlet UIToolbar *topToolbar;
    IBOutlet UIBarButtonItem *backBarBtnItem;
    IBOutlet UIView *progressView;
    
    MediaPlayer *_playbackStreamer;
    PlaybackListener * listener; 
    
    NSMutableArray * _clips;
    
    NSString *urlVideo;
    NSString *camera_mac;

    //EarlierNavigationController *_navController;
    BOOL _isSwitchingWhenPress;
    BOOL _isClickedOnZooming;
}
@property (nonatomic, assign) id<PlaybackDelegate> plabackVCDelegate;
@property (nonatomic, retain) NSMutableArray *clips;
@property (retain, nonatomic) IBOutlet UIImageView *imageVideo;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIImageView *ib_bg_top_player;

@property (retain, nonatomic) IBOutlet UIView *ib_viewControlPlayer;
@property (retain, nonatomic) IBOutlet UIButton *ib_closePlayBack;
@property (retain, nonatomic) IBOutlet UIButton *ib_playPlayBack;
@property (retain, nonatomic) IBOutlet UISlider *ib_sliderPlayBack;
@property (retain, nonatomic) IBOutlet UILabel *ib_timerPlayBack;
@property (retain, nonatomic) IBOutlet UIButton *ib_zoomingPlayBack;

@property (retain, nonatomic) IBOutlet UIView *ib_myOverlay;

//for delete, download and share
@property (retain, nonatomic) IBOutlet UIView *ib_viewOverlayVideo;
@property (retain, nonatomic) IBOutlet UIButton *ib_delete;
@property (retain, nonatomic) IBOutlet UIButton *ib_download;
@property (retain, nonatomic) IBOutlet UIButton *ib_share;


@property (nonatomic, retain)  NSTimer * list_refresher;
@property (nonatomic, retain) PlaylistInfo * clip_info;

@property (nonatomic, retain) NSString *camera_mac;

@property (nonatomic, retain) NSString *urlVideo;
@property (nonatomic) BOOL userWantToBack;
@property (retain, nonatomic) NSMutableArray *clipsInEvent;
@property (nonatomic, retain) NSTimer *timerHideMenu;
@property (nonatomic) NSInteger intEventId;
//- (void)stopStream;

- (IBAction)onTimeSliderChange:(id)sender;

- (IBAction)stopStream:(id) sender;
- (IBAction)closePlayBack:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)minimizeVideo:(id)sender;
- (IBAction)deleteVideo:(id)sender;
- (IBAction)downloadVideo:(id)sender;
- (IBAction)shareVideo:(id)sender;


@end

//
//  PlaybackViewController.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "PlaybackViewController.h"

#import <MonitorCommunication/MonitorCommunication.h>

#include "PlaybackListener.h"
#import "define.h"
#import "NotifViewController.h"
#import <objc/message.h>

#define START 0
#define END   100.0
#define HEIGHT_BG_CONTROL 45
#define HEIGHT_SLIDER_DEFAULT   33

//#define USE_H264PLAYER 0
@interface PlaybackViewController()

@property (nonatomic) BOOL isPause;
@property (nonatomic) double duration;
@property (nonatomic) int64_t startPositionMovieFile;
@property (nonatomic) double timeStarting;
@property (nonatomic) BOOL shouldRestartProcess;
@property (nonatomic) NSInteger mediaCurrentState;

@end

@implementation PlaybackViewController

@synthesize camera_mac;
@synthesize  clip_info;
@synthesize  imageVideo, urlVideo;//, topToolbar,backBarBtnItem, progressView;
@synthesize clips = _clips;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //load new nib for landscape iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PlaybackViewController_ipad"
                                      owner:self
                                    options:nil];
    }
    
    [self applyFont];
    [self.view addSubview:_ib_myOverlay];
    self.ib_myOverlay.hidden = YES;
    [self.ib_viewOverlayVideo setHidden:YES];
    self.view.userInteractionEnabled = NO;
    [self.ib_playPlayBack setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    [self.ib_playPlayBack setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    //[self becomeActive];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    self.startPositionMovieFile = 0;
    self.duration = 1;
    self.timeStarting = 0;
    self.shouldRestartProcess = FALSE;
    self.mediaCurrentState = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController.navigationBar setHidden:YES];
    //Here is show indicator
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.ib_sliderPlayBack.userInteractionEnabled = NO; // Disable it because it's featur not done yet!
    
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playbackEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playbackBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%s parent:%@", __FUNCTION__, self.parentViewController);
    
    [self becomeActive];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillDisappear:animated];
    NSLog(@"%s viewWillDisappear: ", __FUNCTION__);
}

#pragma mark - NSNotificationCenter

- (void)playbackEnteredBackground
{
    NSLog(@"%s mediaCurrentState:%d", __FUNCTION__, _mediaCurrentState);
#if 1
    if (self.mediaCurrentState == MEDIA_PLAYER_STARTED)
    {
        NSLog(@"Playback - playbackEnteredBackground - IF()");
        
        if (_isPause)
        {
            self.isPause = NO;
            MediaPlayer::Instance()->resume();
            self.ib_playPlayBack.selected = NO;
        }
        
        [self stopStream:nil];
    }
    else if(_mediaCurrentState == 0) // Start set data sourece
    {
        NSLog(@"Playback - playbackEnteredBackground - else if()");
        MediaPlayer::Instance()->sendInterrupt();
    }
    else
    {
        NSLog(@"Playback - playbackEnteredBackground - else{}");
    }
#else
    if (_playbackStreamer != NULL)
    {
        if (self.mediaCurrentState == MEDIA_PLAYER_STARTED)
        {
            NSLog(@"H264VC - handleEnteredBackground - IF()");
            
            if (_isPause)
            {
                self.isPause = NO;
                _playbackStreamer->resume();
                self.ib_playPlayBack.selected = NO;
            }
            
            [self stopStream:nil];
        }
        else
        {
            NSLog(@"H264VC - handleEnteredBackground - else if(h264Streamer != nil)");
            _playbackStreamer->sendInterrupt();
        }
    }
#endif
    
    if (self.list_refresher != nil)
    {
        [self.list_refresher invalidate];
    }
}

- (void)playbackBecomeActive
{
    NSLog(@"%s _shouldRestartProcess:%d", __FUNCTION__, _shouldRestartProcess);
    
    if (_shouldRestartProcess)
    {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        
        self.view.userInteractionEnabled = NO;
        self.ib_myOverlay.hidden = YES;
        
        [self becomeActive];
    }
}

#pragma mark - PLAY VIDEO
- (void)becomeActive
{
    
#if 0 // TEST Multiple clips
    self.urlVideo = @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00001.flv";
    listener = new PlaybackListener(self);
    //hardcode some data for test now:
    self.clips = nil;
    self.clips = [[NSMutableArray alloc] init];
    self.clips = [NSMutableArray arrayWithObjects:
                  @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00001.flv",
                  @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00002.flv",
                  @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00003.flv",
                  @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00004.flv",
                  @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00005_last.flv", nil];
    listener->updateClips(self.clips);
    listener->updateFinalClipCount(self.clips.count);
#else
    
    self.shouldRestartProcess = FALSE;
    self.mediaCurrentState = -1;
    _clips = [[NSMutableArray alloc]init];
    //Decide whether or not to start the background polling
    
    if (self.clip_info != nil )
    {
        listener = new PlaybackListener(self);
        
        if ([self.clip_info isLastClip])
        {
            //Only one clip & it is the last
            NSLog(@"this is the olny clip do not poll");
            [_clips addObject:clip_info.urlFile];
            listener->updateClips(_clips);
            listener->updateFinalClipCount(1);
        }
        else
        {
            // It is not the last clip - scheduling querying of clips
            NSLog(@"clip_info is %@", clip_info);
            self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                   target:self
                                                                 selector:@selector(getCameraPlaylistForEvent:)
                                                                 userInfo:clip_info repeats:NO];
            NSLog(@"[----- self.list_refresher: %p", self.list_refresher);
        }
        
        self.urlVideo = self.clip_info.urlFile;
    }
#endif
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        NSLog(@"%s. Inactive mode", __FUNCTION__);
    }
    else
    {
        [self performSelector:@selector(startStream)
                   withObject:nil
                   afterDelay:0.1];
    }
}

-(void) startStream
{
#if 0
    _playbackStreamer = new MediaPlayer(true, false);
    self.shouldRestartProcess = TRUE;
    _playbackStreamer->setListener(listener);
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
#else

    self.shouldRestartProcess = TRUE;
    
    MediaPlayer::Instance()->setListener(listener);
    MediaPlayer::Instance()->setPlaybackAndSharedCam(true, false);
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
#endif
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    NSString * url = self.urlVideo;
#if 0
    status = _playbackStreamer->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        printf("setDataSource error: %d\n", status);
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    _playbackStreamer->setVideoSurface(self.imageVideo);
    
    NSLog(@"Prepare the player");
    status =  _playbackStreamer->prepare();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageVideo setAlpha:1];
        [self.activityIndicator setHidden:YES];
        self.view.userInteractionEnabled = YES;
        self.ib_myOverlay.hidden = NO;
        [self.ib_sliderPlayBack setMinimumTrackTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_progress_green"]]];
        [self watcher];
    });
    
    printf("prepare return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    status =  _playbackStreamer->start();
    
    printf("start() return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        printf("start() error: %d\n", status);
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    if (status == NO_ERROR)
    {
        [self handleMessage:MEDIA_PLAYER_STARTED
                       ext1:0
                       ext2:0];
    }
#else
    self.mediaCurrentState = 0;
    status = MediaPlayer::Instance()->setDataSource([url UTF8String]);
    
    NSLog(@"%s status: %d", __FUNCTION__, status);
    
    if (status != NO_ERROR) // NOT OK
    {
        NSLog(@"setDataSource error: %d\n", status);
        
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    MediaPlayer::Instance()->setVideoSurface(self.imageVideo);
    
    NSLog(@"Prepare the player");
    status =  MediaPlayer::Instance()->prepare();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageVideo setAlpha:1];
        [self.activityIndicator setHidden:YES];
        self.view.userInteractionEnabled = YES;
        self.ib_myOverlay.hidden = NO;
        [self.ib_sliderPlayBack setMinimumTrackTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_progress_green"]]];
        [self watcher];
    });
    
    NSLog(@"prepare return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        NSLog(@"prepare() error: %d\n", status);
        exit(1); // Dangerous
    }
    
    status =  MediaPlayer::Instance()->start();
    
    NSLog(@"start() return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        NSLog(@"start() error: %d\n", status);
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    if (status == NO_ERROR)
    {
        [self handleMessage:MEDIA_PLAYER_STARTED
                       ext1:0
                       ext2:0];
    }
#endif
}

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2
{
    switch (msg)
    {
        case MEDIA_PLAYER_PREPARED:
            break;
        case MEDIA_PLAYER_STARTED:
            NSLog(@"%s msg: MEDIA_PLAYER_STARTED", __FUNCTION__);
            self.mediaCurrentState = msg;
            break;
            
        case MEDIA_ERROR_SERVER_DIED:
        case MEDIA_PLAYBACK_COMPLETE:
            //DONE Playback
            //clean up
            NSLog(@"Got playback complete>>>>  OUT ");
            if (self.userWantToBack == FALSE && [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                NSLog(@"%s call goBackToPlayList", __FUNCTION__);
                [self goBackToPlayList];
            }
            else
            {
                NSLog(@"%s NOT call goBackToPlayList", __FUNCTION__);
            }
            break;
            
        case MEDIA_SEEK_COMPLETE:
            dispatch_async(dispatch_get_main_queue(), ^{
                self.activityIndicator.hidden = YES;
                self.ib_playPlayBack.selected = NO;
                self.ib_myOverlay.userInteractionEnabled = YES;
                [self performSelector:@selector(watcher) withObject:nil afterDelay:2];
            });
            break;
            
        default:
            break;
    }
}

- (IBAction)stopStream:(id) sender
{
    NSLog(@"Stop stream start ");
#if 1
    if(MediaPlayer::Instance()->isPlaying())
    {
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        MediaPlayer::Instance()->setListener(nil);
    }
    else // set Data source failed!
    {
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        MediaPlayer::Instance()->setListener(nil);
    }
#else
    if (_playbackStreamer != NULL)
    {
        NSLog(@"Stop stream _playbackStreamer != NULL");
        
        if(_playbackStreamer->isPlaying())
        {
            _playbackStreamer->suspend();
            _playbackStreamer->stop();
            //_playbackStreamer->setListener(nil);
            delete _playbackStreamer;
            _playbackStreamer = NULL;
        }
        else // set Data source failed!
        {
            _playbackStreamer->suspend();
            _playbackStreamer->stop();
            _playbackStreamer->setListener(nil);
            delete _playbackStreamer;
            _playbackStreamer = NULL;
        }
    }
#endif
    NSLog(@"Stop stream end");
}

#pragma mark - FONT

-(void)applyFont
{
    [self.ib_timerPlayBack setFont:[UIFont lightSmall13Font]];
    self.ib_timerPlayBack.textColor = [UIColor textTimerPlayBackColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - RELEASE MEMORY

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [imageVideo release];
    
    [_list_refresher release];
    
    [_activityIndicator release];
    [clip_info release];
    [_clips release];
    [_ib_closePlayBack release];
    [_ib_playPlayBack release];
    [_ib_sliderPlayBack release];
    [_ib_timerPlayBack release];
    [_ib_zoomingPlayBack release];
    [_ib_viewOverlayVideo release];
    [_ib_delete release];
    [_ib_download release];
    [_ib_share release];
    [_ib_viewControlPlayer release];
    [_ib_myOverlay release];
    [_ib_bg_top_player release];
    
    [super dealloc];
}



- (void)goBackToPlayList
{
    self.userWantToBack = TRUE;
    self.ib_playPlayBack.enabled = NO;
    
    [self stopStream:nil];
    
    if (self.list_refresher != nil)
    {
        [self.list_refresher invalidate];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.navigationController != nil)
    {
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIDeviceOrientationPortrait);
            }
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationNone];
#if 1
        [self.navigationController popViewControllerAnimated:YES];
#else
        NotifViewController * vc = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
        
        NSLog(@"Playback with nav controller pop all:%@", vc);
        
        if ([vc isKindOfClass:[NotifViewController class]])
        {
            NSLog(@"Playback with nav controller pop to NotifViewController");
            //[self.navigationController popToRootViewControllerAnimated:NO];
            [self.navigationController popViewControllerAnimated:NO];
            [vc ignoreTouchAction:nil];
        }
        else // Timeline
        {
            //id tmp = [self.navigationController.viewControllers objectAtIndex:2];
            //NSLog(@"%s goBackToPlayList - vc: %@", __FUNCTION__, NSStringFromClass([tmp class]));
            [self.navigationController popViewControllerAnimated:YES];
        }
#endif
    }
    else
    {
        NSLog(@"Playback no nav controller");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark - Rotation screen

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!_userWantToBack)
    {
        [self adjustViewsForOrientation:toInterfaceOrientation];
    }
}

-(void) checkOrientation
{
	[self adjustViewsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        [self.imageVideo setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        
        [self.ib_closePlayBack setImage:[UIImage imageNamed:@"video_fullscreen_close"] forState:UIControlStateNormal];
        [self.ib_closePlayBack setImage:[UIImage imageNamed:@"video_fullscreen_close_pressed"] forState:UIControlEventTouchDown];
        self.ib_bg_top_player.hidden = YES;
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (isiPhone5 || isiPhone4)
        {
            [self.imageVideo setFrame:CGRectMake(0, 194, SCREEN_WIDTH, 180)];
        }
        else
        {
            //iPad
            [self.imageVideo setFrame:CGRectMake(0, 296, SCREEN_WIDTH, 432)];
        }
        
        [self.ib_closePlayBack setImage:[UIImage imageNamed:@"vertcal_video_close"] forState:UIControlStateNormal];
        [self.ib_closePlayBack setImage:[UIImage imageNamed:@"vertcal_video_close_pressed"] forState:UIControlEventTouchDown];
        self.ib_bg_top_player.hidden = NO;
	}
}

#pragma mark - Hide&Show Control

- (void)singleTapGestureCaptured:(id)sender
{
    if (_ib_myOverlay.hidden)
    {
        [self showControlMenu];
    }
    else
    {
        [self hideControlMenu];
    }
}

- (void)hideControlMenu
{
    [self.ib_myOverlay setHidden:YES];
    self.view.userInteractionEnabled = YES;
}

- (void)showControlMenu
{
    [self.ib_myOverlay setHidden:NO];
    [self.view bringSubviewToFront:self.ib_myOverlay];
    
    if (_timerHideMenu != nil)
    {
        [self.timerHideMenu invalidate];
        self.timerHideMenu = nil;
    }
    
    self.timerHideMenu = [NSTimer scheduledTimerWithTimeInterval:10
                                                          target:self
                                                        selector:@selector(hideControlMenu)
                                                        userInfo:nil
                                                         repeats:NO];
}

#pragma mark - Actions

- (IBAction)minimizeVideo:(id)sender
{
    UIDeviceOrientation orietation = UIDeviceOrientationPortrait;
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)
    {
        orietation = UIDeviceOrientationLandscapeRight;
    }
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    orietation);
    }
}

- (IBAction)deleteVideo:(id)sender
{
}

- (IBAction)downloadVideo:(id)sender
{
}

- (IBAction)shareVideo:(id)sender
{
}

- (IBAction)onTimeSliderChange:(id)sender
{
}

- (IBAction)sliderProgressTouchDownAction:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_playbackStreamer   &&
        !_isPause           &&
        _playbackStreamer->isPlaying())
    {
        self.isPause = YES;
        _playbackStreamer->pause();
        self.ib_playPlayBack.selected = YES;
        self.view.userInteractionEnabled = NO;
        [self.ib_myOverlay setHidden:NO];

        if (_timerHideMenu != nil)
        {
            [self.timerHideMenu invalidate];
            self.timerHideMenu = nil;
        }
    }
}

- (IBAction)sliderProgressTouchUpInsideAction:(UISlider *)sender
{
    double seekTarget = sender.value * _duration;
    
    NSLog(@"%s value: %f, target: %f", __FUNCTION__, sender.value, seekTarget);//0.666,667 --> 666,667
    
    if (_playbackStreamer   &&
        _isPause)
    {
        self.activityIndicator.hidden = NO;
        self.isPause = NO;
        
        //_playbackStreamer->seekTo(seekTarget);// USE THIS
        _playbackStreamer->seekTo(seekTarget);// USE THIS

        self.view.userInteractionEnabled = YES;
        self.ib_myOverlay.userInteractionEnabled = NO;
        
        [self showControlMenu];
    }
}

- (IBAction)sliderProgressTouchUpOutsideAction:(UISlider *)sender
{
    // Option ♀(✿◠‿◠) 
    [self sliderProgressTouchUpInsideAction:sender];
}

- (IBAction)closePlayBack:(id)sender
{
    //handle remove all callback, notification here
    //stop handle method watcher
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(watcher)
                                               object:nil];
    if (_isPause)
    {
        MediaPlayer::Instance()->resume();
    }
    
    [self goBackToPlayList];
}

- (IBAction)playVideo:(id)sender
{
    NSLog(@"%s wants to pause: %d", __FUNCTION__, _isPause);
#if 1
    if (_isPause)
    {
        self.isPause = NO;
        MediaPlayer::Instance()->resume();
        [self watcher];
        self.ib_playPlayBack.selected = NO;
    }
    else if(MediaPlayer::Instance()->isPlaying())
    {
        self.isPause = YES;
        MediaPlayer::Instance()->pause();
        self.ib_playPlayBack.selected = YES;
    }
#else
    if (_playbackStreamer)
    {
        if (_isPause)
        {
            self.isPause = NO;
            _playbackStreamer->resume();
            [self watcher];
            self.ib_playPlayBack.selected = NO;
        }
        else if(_playbackStreamer->isPlaying())
        {
            self.isPause = YES;
            _playbackStreamer->pause();
            self.ib_playPlayBack.selected = YES;
        }
    }
#endif
}


#pragma mark Display Time
-(void)watcher
{
    //NSLog(@"%s", __FUNCTION__);
    if (MediaPlayer::Instance() == NULL || _isPause || _userWantToBack)
    {
        return;
    }
    
    self.duration = MediaPlayer::Instance()->getDuration();
    self.timeStarting = MediaPlayer::Instance()->getTimeStarting();
    double timeCurrent = MediaPlayer::Instance()->getCurrentTime() - _timeStarting;
    
#if 0
    NSLog(@"timeCurrent: %f, _timeStarting: %f", timeCurrent, _timeStarting);
#endif
    
    self.ib_sliderPlayBack.value = timeCurrent / _duration;
    
    NSInteger time = lround(timeCurrent);
    self.ib_timerPlayBack.text = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(watcher)
                                   userInfo:nil
                                    repeats:NO];
}

- (NSString *) timeFormat: (float) seconds {
    NSLog(@"%s seconds: %f", __FUNCTION__, seconds);
    int minutes = seconds / 60;
    int sec     = fabs(round((int)seconds % 60));
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, sec];
    
//    NSString *cm = minutes <= 9 ? @"00": @"";
//    NSString *cs = sec <= 9 ? @"00": @"";
//    
//    return [NSString stringWithFormat:@"%@%i:%@%i", cm, minutes, cs, sec];
}

#pragma mark - Poll camera events

-(void) getCameraPlaylistForEvent:(NSTimer *) clipTimer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    
    NSString *mac = clip_info.mac_addr;
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString * event_timecode = [NSString stringWithFormat:@"%@_0%@_%@", mac,clip_info.alertType, clip_info.alertVal];
    
    
    NSDictionary * responseDic = [jsonComm getListOfEventsBlockedWithRegisterId:clip_info.registrationID
                                                                beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                      eventCode:event_timecode//event_code // temp
                                                                         alerts:nil
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    [jsonComm release];
    
    [self getPlaylistSuccessWithResponse:responseDic];
}

- (void)getPlaylistSuccessWithResponse: (NSDictionary *)responseDict
{
    BOOL got_last_clip = FALSE;
    
    if (responseDict != nil)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSArray *eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            NSLog(@"play list: %@ ",responseDict);
            if (eventArr.count > 0)
            {
                NSArray *clipInEvents = [[eventArr objectAtIndex:0] objectForKey:@"data"];
                
                for (NSDictionary *clipInfo in clipInEvents) {
                    PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init]autorelease];
                    playlistInfo.mac_addr = clip_info.mac_addr;
                    
                    playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                    playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                    playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                    
                    //check if the clip is in our private array
                    BOOL found = FALSE;
                    
                    for ( NSString * one_clip in _clips)
                    {
                        NSLog(@"one clip: *%@*", one_clip);
                        NSLog(@"playlistInfo.url: *%@*", playlistInfo.urlFile);
                        
                        if ([playlistInfo containsClip:one_clip])
                        {
                            found = TRUE;
                            break;
                        }
                    }
                    
                    if (found == FALSE)
                    {
                        //add the clip
                        [_clips addObject:playlistInfo.urlFile];
                        NSLog(@"clips: %@", _clips);
                    }
                    
                    
                    if ([playlistInfo isLastClip])
                    {
                        NSLog(@"This is last");
                        got_last_clip = TRUE;
                    }
                }
                
                NSLog(@"there is %d in playlist", [_clips count]);
            }
        }
    }
    
    if (got_last_clip == TRUE)
    {
        listener->updateFinalClipCount([_clips count]);
        
    }
    else
    {
        
        
        self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                               target:self
                                                             selector:@selector(getCameraPlaylistForEvent:)
                                                             userInfo:clip_info repeats:NO];
    }
    
    listener->updateClips(_clips);
}

- (void)getPlaylistFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"getPlaylistFailedWithResponse");
    self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(getCameraPlaylistForEvent:)
                                                         userInfo:clip_info repeats:NO];
    
}

- (void)getPlaylistUnreachableSetver
{
    NSLog(@"getPlaylistUnreachableSetver");
    self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(getCameraPlaylistForEvent:)
                                                         userInfo:clip_info repeats:NO];
    
}

@end

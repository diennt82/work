//
//  PlaybackViewController.m
//  MBP_ios
//
//  Created by NxComm on 6/9/13.
//  Copyright (c) 2013 Hubble Connected Ltd. All rights reserved.
//

#import <MonitorCommunication/MonitorCommunication.h>
#import <objc/message.h>

#import "PlaybackViewController.h"
#import "NotifViewController.h"
#import "PlaybackListener.h"
#import "TimelineDatabase.h"
#import "MBProgressHUD.h"
#import "define.h"

#define START 0
#define END 100.0
#define HEIGHT_BG_CONTROL 45
#define HEIGHT_SLIDER_DEFAULT 33

@interface PlaybackViewController()

@property (nonatomic, assign) MediaPlayer *playbackStreamer;
@property (nonatomic, assign) PlaybackListener *listener;

@property (nonatomic) BOOL isSwitchingWhenPress;
@property (nonatomic) BOOL isClickedOnZooming;

@property (nonatomic) BOOL isPause;
@property (nonatomic) double duration;
@property (nonatomic) int64_t startPositionMovieFile;
@property (nonatomic) double timeStarting;
@property (nonatomic) BOOL shouldRestartProcess;
@property (nonatomic) NSInteger mediaCurrentState;

@end

@implementation PlaybackViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load new nib for landscape iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[NSBundle mainBundle] loadNibNamed:@"PlaybackViewController_ipad" owner:self options:nil];
    }
    
    [self applyFont];
    [self.view addSubview:_ib_myOverlay];
    self.view.userInteractionEnabled = NO;
    
    _ib_myOverlay.hidden = YES;
    _ib_viewOverlayVideo.hidden = YES;
    [_ib_playPlayBack setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
    [_ib_playPlayBack setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // Ensure that view rotations are disabled
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:CAM_IN_VEW];
    [userDefaults synchronize];
    
    //Here is show indicator
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    _ib_sliderPlayBack.userInteractionEnabled = NO; // Disable it because it's featur not done yet!
    
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

#pragma mark - NSNotificationCenter

- (void)playbackEnteredBackground
{
    NSLog(@"%s mediaCurrentState:%d", __FUNCTION__, _mediaCurrentState);

    if (self.mediaCurrentState == MEDIA_PLAYER_STARTED) {
        NSLog(@"Playback - playbackEnteredBackground - IF()");
        
        if (_isPause) {
            self.isPause = NO;
            MediaPlayer::Instance()->resume();
            self.ib_playPlayBack.selected = NO;
        }
        
        [self stopStream:nil];
    }
    else if(_mediaCurrentState == 0) {
        // Start set data sourece
        NSLog(@"Playback - playbackEnteredBackground - else if()");
        MediaPlayer::Instance()->sendInterrupt();
    }
    else {
        NSLog(@"Playback - playbackEnteredBackground - else{}");
    }
    
    if (self.list_refresher != nil) {
        [self.list_refresher invalidate];
    }
}

- (void)playbackBecomeActive
{
    NSLog(@"%s _shouldRestartProcess:%d", __FUNCTION__, _shouldRestartProcess);
    
    if (_shouldRestartProcess) {
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
    self.shouldRestartProcess = NO;
    self.mediaCurrentState = -1;
    _clips = [[NSMutableArray alloc]init];
    //Decide whether or not to start the background polling
    
    if ( _clipInfo ) {
        self.listener = new PlaybackListener(self);
        
        if ([_clipInfo isLastClip]) {
            //Only one clip & it is the last
            NSLog(@"this is the olny clip do not poll");
            [_clips addObject:_clipInfo.urlFile];
            _listener->updateClips(_clips);
            _listener->updateFinalClipCount(1);
        }
        else {
            // It is not the last clip - scheduling querying of clips
            NSLog(@"clip_info is %@", _clipInfo);
            self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                   target:self
                                                                 selector:@selector(getCameraPlaylistForEvent:)
                                                                 userInfo:_clipInfo repeats:NO];
            NSLog(@"[----- self.list_refresher: %p", self.list_refresher);
        }
        
        self.urlVideo = _clipInfo.urlFile;
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        NSLog(@"%s. Inactive mode", __FUNCTION__);
    }
    else {
        [self performSelector:@selector(startStream) withObject:nil afterDelay:0.1];
    }
}

- (void)startStream
{
    self.shouldRestartProcess = YES;
    
    MediaPlayer::Instance()->setListener(_listener);
    MediaPlayer::Instance()->setPlaybackAndSharedCam(true, false);
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    NSString *url = _urlVideo;
    
    self.mediaCurrentState = 0;
    status = MediaPlayer::Instance()->setDataSource([url UTF8String]);
    
    NSLog(@"%s status: %d", __FUNCTION__, status);
    
    if (status != NO_ERROR) {
        // NOT OK
        NSLog(@"setDataSource error: %d\n", status);
        
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
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
    
    if (status != NO_ERROR) {
        // NOT OK
        NSLog(@"prepare() error: %d\n", status);
        exit(1); // Dangerous
    }
    
    status =  MediaPlayer::Instance()->start();
    NSLog(@"start() return: %d\n", status);
    
    if (status != NO_ERROR) {
        // NOT OK
        NSLog(@"start() error: %d\n", status);
        [self handleMessage:MEDIA_ERROR_SERVER_DIED ext1:0 ext2:0];
        return;
    }
    
    if (status == NO_ERROR) {
        [self handleMessage:MEDIA_PLAYER_STARTED ext1:0 ext2:0];
    }
}

- (void)handleMessage:(int)msg ext1:(int)ext1 ext2:(int)ext2
{
    switch (msg) {
        case MEDIA_PLAYER_PREPARED:
            break;

        case MEDIA_PLAYER_STARTED:
        {
            NSLog(@"%s msg: MEDIA_PLAYER_STARTED", __FUNCTION__);
            self.mediaCurrentState = msg;
            break;
        }
            
        case MEDIA_ERROR_SERVER_DIED:
        case MEDIA_PLAYBACK_COMPLETE:
        {
            //DONE Playback
            //clean up
            NSLog(@"Got playback complete>>>>  OUT ");
            if (self.userWantToBack == FALSE && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                NSLog(@"%s call goBackToPlayList", __FUNCTION__);
                [self goBackToPlayList];
            }
            else {
                NSLog(@"%s NOT call goBackToPlayList", __FUNCTION__);
            }
            break;
        }
            
        case MEDIA_SEEK_COMPLETE:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.activityIndicator.hidden = YES;
                self.ib_playPlayBack.selected = NO;
                self.ib_myOverlay.userInteractionEnabled = YES;
                [self performSelector:@selector(watcher) withObject:nil afterDelay:2];
            });
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)stopStream:(id)sender
{
    NSLog(@"Stop stream start ");

    if(MediaPlayer::Instance()->isPlaying()) {
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        MediaPlayer::Instance()->setListener(nil);
    }
    else {
        // set Data source failed!
        MediaPlayer::Instance()->suspend();
        MediaPlayer::Instance()->stop();
        MediaPlayer::Instance()->setListener(nil);
    }

    NSLog(@"Stop stream end");
}

#pragma mark - FONT

- (void)applyFont
{
    [_ib_timerPlayBack setFont:[UIFont lightSmall13Font]];
    _ib_timerPlayBack.textColor = [UIColor textTimerPlayBackColor];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)goBackToPlayList
{
    self.userWantToBack = TRUE;
    _ib_playPlayBack.enabled = NO;
    
    [self stopStream:nil];
    
    if ( _list_refresher ) {
        [_list_refresher invalidate];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([_playbackVCDelegate respondsToSelector:@selector(playbackStopped)]) {
        [_playbackVCDelegate playbackStopped];
    }
    
    if ( self.navigationController ) {
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
            [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
        {
            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
                objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),   UIDeviceOrientationPortrait);
            }
        }
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Rotation screen

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!_userWantToBack) {
        [self adjustViewsForOrientation:toInterfaceOrientation];
    }
}

- (void)checkOrientation
{
	[self adjustViewsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (UIInterfaceOrientationIsLandscape(orientation)) {
        [_imageVideo setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        
        [_ib_closePlayBack setImage:[UIImage imageNamed:@"video_fullscreen_close"] forState:UIControlStateNormal];
        [_ib_closePlayBack setImage:[UIImage imageNamed:@"video_fullscreen_close_pressed"] forState:UIControlEventTouchDown];
        _ib_bg_top_player.hidden = YES;
	}
	else if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.imageVideo setFrame:CGRectMake(0, 194, SCREEN_WIDTH, 180)];
        }
        else {
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
    [self.ib_viewOverlayVideo setHidden:YES];
    self.view.userInteractionEnabled = YES;
}

- (void)showControlMenu
{
    [self.ib_myOverlay setHidden:NO];
    [self.view bringSubviewToFront:self.ib_myOverlay];
    
    [self.ib_viewOverlayVideo setHidden:NO];
    [self.view bringSubviewToFront:self.ib_viewOverlayVideo];
    
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
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        orietation = UIDeviceOrientationLandscapeRight;
    }
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:), orietation);
    }
}

- (IBAction)deleteVideo:(id)sender
{
    if (self.intEventId==0) {
        return;
    }
    
    [self hideControlMenu];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Deleting Video..."];
    
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^{
        NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"PortalApiKey"];
        NSString *strEventID = [NSString stringWithFormat:@"%d", _intEventId];
        
        BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self Selector:nil FailSelector:nil ServerErr:nil];
        NSDictionary *responseDict = [jsonComm deleteEventsBlockedWithRegistrationId:_clipInfo.registrationID eventIds:strEventID apiKey:apiKey];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ( responseDict ) {
            if ([responseDict[@"status"] integerValue] == 200) {
                [[TimelineDatabase getSharedInstance] deleteEventWithID:strEventID];
                if ([_playbackVCDelegate respondsToSelector:@selector(motionEventDeleted)]) {
                    [_playbackVCDelegate motionEventDeleted];
                }
                
                [self closePlayBack:nil];
            }
            else if ( responseDict[@"message"] ) {
                Alert(nil, responseDict[@"message"]);
            }
            else {
                Alert(nil, @"Error occured. Please try again.");
            }
        }
        else {
            Alert(@"Failed: Server is unreachable", @"Please check your network connection");
        }
    });
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
    
    if ( _playbackStreamer && !_isPause && _playbackStreamer->isPlaying()) {
        self.isPause = YES;
        _playbackStreamer->pause();
        self.ib_playPlayBack.selected = YES;
        self.view.userInteractionEnabled = NO;
        [self.ib_myOverlay setHidden:NO];

        if ( _timerHideMenu ) {
            [self.timerHideMenu invalidate];
            self.timerHideMenu = nil;
        }
    }
}

- (IBAction)sliderProgressTouchUpInsideAction:(UISlider *)sender
{
    double seekTarget = sender.value * _duration;
    NSLog(@"%s value: %f, target: %f", __FUNCTION__, sender.value, seekTarget);//0.666,667 --> 666,667
    
    if ( _playbackStreamer && _isPause) {
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
    // Handle removing all callback notifications here.
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(watcher)
                                               object:nil];
    if ( _isPause ) {
        MediaPlayer::Instance()->resume();
    }
    
    [self goBackToPlayList];
}

- (IBAction)playVideo:(id)sender
{
    NSLog(@"%s wants to pause: %d", __FUNCTION__, _isPause);

    if (_isPause) {
        self.isPause = NO;
        MediaPlayer::Instance()->resume();
        [self watcher];
        self.ib_playPlayBack.selected = NO;
    }
    else if (MediaPlayer::Instance()->isPlaying()) {
        self.isPause = YES;
        MediaPlayer::Instance()->pause();
        self.ib_playPlayBack.selected = YES;
    }
}

#pragma mark - Display Time

- (void)watcher
{
    if (MediaPlayer::Instance() == NULL || _isPause || _userWantToBack) {
        return;
    }
    
    self.duration = MediaPlayer::Instance()->getDuration();
    self.timeStarting = MediaPlayer::Instance()->getTimeStarting();
    double timeCurrent = MediaPlayer::Instance()->getCurrentTime() - _timeStarting;
    
    self.ib_sliderPlayBack.value = timeCurrent / _duration;
    
    NSInteger currentTime = lround(timeCurrent);
    NSInteger totalTime = lround(self.duration);
    self.ib_timerPlayBack.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", currentTime / 60, currentTime % 60,totalTime / 60, totalTime % 60];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(watcher)
                                   userInfo:nil
                                    repeats:NO];
}

- (NSString *)timeFormat:(float)seconds
{
    NSLog(@"%s seconds: %f", __FUNCTION__, seconds);
    int minutes = seconds / 60;
    int sec     = fabs(round((int)seconds % 60));
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, sec];
}

#pragma mark - Poll camera events

- (void)getCameraPlaylistForEvent:(NSTimer *)clipTimer
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil];
    NSString *mac = _clipInfo.macAddr;
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *event_timecode = [NSString stringWithFormat:@"%@_0%@_%@", mac,_clipInfo.alertType, _clipInfo.alertVal];
    
    NSDictionary * responseDic = [jsonComm getListOfEventsBlockedWithRegisterId:_clipInfo.registrationID
                                                                beforeStartTime:nil//@"2013-12-28 20:10:18"
                                                                      eventCode:event_timecode//event_code // temp
                                                                         alerts:nil
                                                                           page:nil
                                                                         offset:nil
                                                                           size:nil
                                                                         apiKey:apiKey];
    
    [self getPlaylistSuccessWithResponse:responseDic];
}

- (void)getPlaylistSuccessWithResponse:(NSDictionary *)responseDict
{
    BOOL got_last_clip = NO;
    
    if ( responseDict ) {
        if ([responseDict[@"status"] intValue] == 200) {
            NSArray *eventArr = [responseDict[@"data"] objectForKey:@"events"];
            
            NSLog(@"play list: %@ ",responseDict);
            if (eventArr.count > 0) {
                NSArray *clipInEvents = [[eventArr objectAtIndex:0] objectForKey:@"data"];
                
                for (NSDictionary *clipInfo in clipInEvents) {
                    PlaylistInfo *playlistInfo = [[PlaylistInfo alloc] init];
                    playlistInfo.macAddr = _clipInfo.macAddr;
                    
                    playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                    playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                    playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                    
                    //check if the clip is in our private array
                    BOOL found = NO;
                    
                    for ( NSString * one_clip in _clips) {
                        NSLog(@"one clip: *%@*", one_clip);
                        NSLog(@"playlistInfo.url: *%@*", playlistInfo.urlFile);
                        
                        if ([playlistInfo containsClip:one_clip]) {
                            found = YES;
                            break;
                        }
                    }
                    
                    if ( !found ) {
                        //add the clip
                        [_clips addObject:playlistInfo.urlFile];
                        NSLog(@"clips: %@", _clips);
                    }
                    
                    if ([playlistInfo isLastClip]) {
                        NSLog(@"This is last");
                        got_last_clip = YES;
                    }
                }
                
                NSLog(@"there is %d in playlist", [_clips count]);
            }
        }
    }
    
    if ( got_last_clip ) {
        _listener->updateFinalClipCount([_clips count]);
    }
    else {
        self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                               target:self
                                                             selector:@selector(getCameraPlaylistForEvent:)
                                                             userInfo:_clipInfo repeats:NO];
    }
    
    _listener->updateClips(_clips);
}

- (void)getPlaylistFailedWithResponse:(NSDictionary *)responseDict
{
    NSLog(@"getPlaylistFailedWithResponse");
    self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(getCameraPlaylistForEvent:)
                                                         userInfo:_clipInfo repeats:NO];
}

- (void)getPlaylistUnreachableSetver
{
    NSLog(@"getPlaylistUnreachableSetver");
    self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                           target:self
                                                         selector:@selector(getCameraPlaylistForEvent:)
                                                         userInfo:_clipInfo repeats:NO];
}

#pragma mark - Memory management

- (void)dealloc
{
    _playbackVCDelegate = nil;
    _playbackStreamer = nil;
    _listener = nil;
}

@end

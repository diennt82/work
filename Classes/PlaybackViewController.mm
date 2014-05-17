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
@property (nonatomic) int64_t duration;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController.navigationBar setHidden:YES];
    //Here is show indicator
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%s: viewDidAppear", __FUNCTION__);
    
    [self becomeActive];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: ");
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
    
    [self performSelector:@selector(startStream)
               withObject:nil
               afterDelay:0.1];
}

-(void) startStream
{
    _playbackStreamer = new MediaPlayer(true, false);
    _playbackStreamer->setListener(listener);
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    //NSString * url = self.urlVideo;//http://hubble-resources.s3.amazonaws.com/devices/01006644334C5A03AEPGARBUYQ/clips/44334C5A03AE_04_20140512142408000_00001_last.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1399969712&Signature=3yU8amUp9VHutvusSDAQg6XGc%2Fw%3D
    NSString * url = @"http://hubble-resources.s3.amazonaws.com/devices/01006644334C5A03AEPGARBUYQ/clips/44334C5A03AE_04_20140516103037000_00001_last.flv?AWSAccessKeyId=AKIAJNYQ3ONBL7OLSZDA&Expires=1400315858&Signature=eydvKkxRSFcxkU3A%2F4CkoQAFB4w%3D";
    //NSString * url = @"http://cvision-office.no-ip.info/release/spider2_hd.flv";
    //NSString * url = [[NSBundle mainBundle] pathForResource:@"spider2_hd" ofType:@"flv"];
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
        _playbackStreamer -> getDuration(&_duration);
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
}

-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2
{
    switch (msg)
    {
        case MEDIA_PLAYER_PREPARED:
        case MEDIA_PLAYER_STARTED:
            break;
            
        case MEDIA_ERROR_SERVER_DIED:
        case MEDIA_PLAYBACK_COMPLETE:
            //DONE Playback
            //clean up
            NSLog(@"Got playback complete>>>>  OUT ");
            if (self.userWantToBack == FALSE)
            {
                [self goBackToPlayList];
            }
            break;
            
        case MEDIA_SEEK_COMPLETE:
            dispatch_async(dispatch_get_main_queue(), ^{
                self.activityIndicator.hidden = YES;
                [self watcher];
            });
            break;
            
        default:
            break;
    }
}

- (IBAction)stopStream:(id) sender
{
    NSLog(@"Stop stream start ");
    
    if (_playbackStreamer != NULL)
    {
        NSLog(@"Stop stream _playbackStreamer != NULL");
        
        if(_playbackStreamer->isPlaying())
        {
            _playbackStreamer->suspend();
            _playbackStreamer->stop();
            _playbackStreamer->setListener(nil);
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
    
    if (_playbackStreamer != NULL)
    {
        [self stopStream:nil];
    }
    
    if (self.list_refresher != nil)
    {
        [self.list_refresher invalidate];
    }
    
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
        
        NSLog(@"Playback with nav controller pop all");
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationNone];
        
        NotifViewController * vc = [self.navigationController.viewControllers objectAtIndex:0];
        
        if ([vc isKindOfClass:[NotifViewController class]])
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [vc ignoreTouchAction:nil];
        }
        else // Timeline
        {
            //id tmp = [self.navigationController.viewControllers objectAtIndex:2];
            //NSLog(@"%s goBackToPlayList - vc: %@", __FUNCTION__, NSStringFromClass([tmp class]));
            [self.navigationController popViewControllerAnimated:YES];
        }
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

- (IBAction)sliderProgressTouchUpInsideAction:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    int64_t seekTarget = (slider.value * 100 * _duration) * 10 + 20069258499;
                                                                  //1279873122304
                                                                  //1220588077056
                                                                  // 124509814784
    NSLog(@"%s value: %f, target: %lld", __FUNCTION__, slider.value, seekTarget);//0.666,667 --> 666,667
    
    if (_playbackStreamer   &&
        _isPause)
    {
        self.activityIndicator.hidden = NO;
        self.isPause = NO;
        //_playbackStreamer->resume();
        //61810.
        //       1,500,000
        //       1,467,285
        
        //      20,069,258,499
        //  --> 20,084,258,499
        //      20068464640
        //      1235294
        
        //_playbackStreamer->seekTo(roundl(slider.value *  _duration));
        
        //int64_t seekTarget = slider.value * AV_TIME_BASE * 10 + 20069258499;
        //int64_t seekTarget = slider.value * _duration * 100;// + 20069258499;
        
        //_playbackStreamer->seekTo(seekTarget);// USE THIS
                                                                   //20084258499
          _playbackStreamer->seekTo(2900000000);
        //[self watcher];
        self.ib_playPlayBack.selected = NO;
        self.view.userInteractionEnabled = YES;
        
        [self showControlMenu];
    }
}

- (IBAction)sliderProgressTouchUpOutsideAction:(id)sender
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
    [self goBackToPlayList];
}

- (IBAction)playVideo:(id)sender
{
    NSLog(@"%s wants to pause: %d", __FUNCTION__, _isPause);
    
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
}


#pragma mark Display Time
-(void)watcher
{
    if (_playbackStreamer == NULL || _isPause || _userWantToBack)
    {
        return;
    }
    //_playbackStreamer -> getDuration(&_duration);
    int currentTime = _playbackStreamer->getCurrPos();
    //_playbackStreamer->getCurrentPosition(&currentTime);
    //int64_t currentTime;// = _playbackStreamer->getCurrPos();
    //_playbackStreamer->getCurrPos(&currentTime);
    //currentTime = _playbackStreamer->mCurrentPosition;
    
    NSLog(@"%s current time: %d, duration: %lld, div: %f", __FUNCTION__, currentTime, _duration, (float)currentTime/(_duration * 100));
    
    self.ib_timerPlayBack.text = [self timeFormat:(float)((currentTime)/1000)];

    self.ib_sliderPlayBack.value = (float)currentTime / (_duration * 100);
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(watcher)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (NSString *) timeFormat: (float) seconds {
    
    int minutes = seconds / 60;
    int sec     = fabs(round((int)seconds % 60));
    NSString *cm = minutes <= 9 ? @"0": @"";
    NSString *cs = sec <= 9 ? @"0": @"";
    
    return [NSString stringWithFormat:@"%@%i:%@%i",cm, minutes, cs, sec];
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

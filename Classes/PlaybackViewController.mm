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


#define START 0
#define END   100.0
#define HEIGHT_BG_CONTROL 45
#define HEIGHT_SLIDER_DEFAULT   33

//#define USE_H264PLAYER 0
@interface PlaybackViewController()

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
    [self.ib_viewOverlayVideo setHidden:YES];
    
    //remove logo
    for (UIView *view in self.navigationController.view.subviews) { // instead of self.view you can use your main view
        if ([view isKindOfClass:[UIButton class]] && view.tag == 11) {
            UIButton *btn = (UIButton *)view;
            [btn removeFromSuperview];
        }
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self becomeActive];
    
#if 0 // Will implement later.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(singleTapGestureCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
#endif
    
    //hide navigation controller
    [self.navigationController setHidesBottomBarWhenPushed:YES];
    
}

#pragma mark - Hide&Show Control
- (void)singleTapGestureCaptured:(id)sender
{
    NSLog(@"Single tap singleTapGestureCaptured");
    _isHorizeShow = !_isHorizeShow;

    {
        if (_isHorizeShow == TRUE)
        {
            [self showControlMenu];
        }
        else
        {
            [self hideControlMenu];
        }
    }
}

- (void)hideControlMenu
{
    _isHorizeShow = NO;
//    [self.ib_viewControlPlayer setHidden:YES];
    [self.ib_viewOverlayVideo setHidden:YES];
//    [self.ib_closePlayBack setHidden:YES];
}

- (void)showControlMenu
{
    _isHorizeShow = YES;
    [self.ib_viewOverlayVideo setHidden:NO];
    [self.view bringSubviewToFront:self.ib_viewOverlayVideo];
    [self.view bringSubviewToFront:self.ib_closePlayBack];
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
    NSString * url = self.urlVideo;
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
        [self.view addSubview:self.ib_myOverlay];
        [self.ib_closePlayBack setFrame:CGRectMake(15, 15, 20, 20)];
        [self.ib_closePlayBack setBackgroundImage:[UIImage imageVerticalVideoClose] forState:UIControlStateNormal];
        [self.ib_sliderPlayBack setMinimumTrackTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"video_progress_green"]]];
        [self watcher];
    });
    
    printf("prepare return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    status=  _playbackStreamer->start();
    
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
        {
            break;
        }
        case MEDIA_PLAYER_STARTED:
        {
            break;
        }
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

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController.navigationBar setHidden:YES];
    //Here is show indicator
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self checkOrientation];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: ");
    //[self goBackToPlayList];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
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
    
    if (_playbackStreamer != NULL)
    {
        [self stopStream:nil];
    }
    
    if (self.list_refresher != nil)
    {
        [self.list_refresher invalidate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Rotation screen

- (void) didRotate:(NSNotification *)notification
{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [[self view] setBounds:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_HEIGHT)];
    // Calculate rotation angle
    NSInteger delta = (SCREEN_HEIGHT - SCREEN_WIDTH);
    CGFloat angle;
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
            //auto rotate phone
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            [self updateRotatingLandWith:0 andY:delta];
            angle =  M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            //auto rotate phone
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
            [self updateRotatingLandWith:0 andY:0];
            angle =  -M_PI_2;
            break;
        default:
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            [self updateRotatingPortraitWith:0 andY:0];
            angle = 0;
            break;
    }
    
    self.view.layer.position = CGPointMake(SCREEN_HEIGHT/2.0,SCREEN_HEIGHT/2.0);
    static NSTimeInterval animationDuration = 0.3;
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.transform = CGAffineTransformMakeRotation(angle);
    }];
}



- (BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void) checkOrientation
{
	UIInterfaceOrientation infOrientation = [UIApplication sharedApplication].statusBarOrientation;
	[self adjustViewsForOrientation:infOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        if (isiPhone5 || isiPhone4)
        {
            [self.imageVideo setFrame:CGRectMake(0, 0, SCREEN_HEIGHT,SCREEN_WIDTH)];

            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_WIDTH - HEIGHT_BG_CONTROL, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 840/2, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(10, 10, 33, 33)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVideoFullScreenClose] forState:UIControlStateNormal];
        }
        else
        {
            //for iPad
            [self.imageVideo setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
            
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_WIDTH - HEIGHT_BG_CONTROL, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
            [self.ib_sliderPlayBack setFrame:CGRectMake(80, 5, SCREEN_HEIGHT - 300, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(10, 10, 33, 33)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVideoFullScreenClose] forState:UIControlStateNormal];
        }
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (isiPhone5 || isiPhone4)
        {
            [self.imageVideo setFrame:CGRectMake(0, 194, SCREEN_WIDTH, 180)];
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_BG_CONTROL, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
            //width of slider is 390/2;
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 364/2, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(15, 15, 17, 17)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVerticalVideoClose] forState:UIControlStateNormal];
        }
        else
        {
            //iPad
            [self.imageVideo setFrame:CGRectMake(0, 296, SCREEN_WIDTH, 432)];
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_BG_CONTROL, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
            //width of slider is 390/2;
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, SCREEN_WIDTH - 200, HEIGHT_SLIDER_DEFAULT)];
        }
	}
}

- (void) updateRotatingLandWith:(float)deltaX andY:(float)deltaY
{
    
    if (isiPhone5 || isiPhone4)
    {
        [self.imageVideo setFrame:CGRectMake(deltaX , deltaY, SCREEN_HEIGHT, SCREEN_WIDTH)];
        [self.ib_viewControlPlayer setFrame:CGRectMake(deltaX, SCREEN_WIDTH - HEIGHT_BG_CONTROL + deltaY, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
        [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 840/2, HEIGHT_SLIDER_DEFAULT)];
        [self.ib_closePlayBack setFrame:CGRectMake(10 + deltaX, 10 + deltaY, 33, 33)];
        [self.ib_closePlayBack setBackgroundImage:[UIImage imageVideoFullScreenClose] forState:UIControlStateNormal];
        [self.ib_viewOverlayVideo setFrame:CGRectMake(158 + deltaX, 112 + deltaY, 240, 90)];
    }
    else
    {
        //for iPad
        [self.imageVideo setFrame:CGRectMake(0 + deltaX, 0 + deltaY, SCREEN_HEIGHT, SCREEN_WIDTH)];
        
        [self.ib_viewControlPlayer setFrame:CGRectMake(0 + deltaX, SCREEN_WIDTH - HEIGHT_BG_CONTROL + deltaY, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
        [self.ib_sliderPlayBack setFrame:CGRectMake(80, 5, SCREEN_HEIGHT - 300, HEIGHT_SLIDER_DEFAULT)];
        [self.ib_closePlayBack setFrame:CGRectMake(10 + deltaX, 10 + deltaY, 33, 33)];
    }
    [self.ib_bg_top_player setHidden:YES];
}

- (void) updateRotatingPortraitWith:(float)deltaX andY:(float)deltaY
{
    [self.ib_bg_top_player setHidden:NO];
    if (isiPhone5 || isiPhone4)
    {
        [self.imageVideo setFrame:CGRectMake(0 + deltaX, 194 + deltaY, SCREEN_WIDTH, 180)];
        [self.ib_viewControlPlayer setFrame:CGRectMake(0 + deltaX, SCREEN_HEIGHT - HEIGHT_BG_CONTROL + deltaY, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
        //width of slider is 390/2;
        [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 364/2, HEIGHT_SLIDER_DEFAULT)];
        [self.ib_closePlayBack setFrame:CGRectMake(15 + deltaX, 15 + deltaY, 20, 20)];
        [self.ib_closePlayBack setBackgroundImage:[UIImage imageVerticalVideoClose] forState:UIControlStateNormal];
        [self.ib_viewOverlayVideo setFrame:CGRectMake(39 + deltaX, 239 + deltaY, 240, 90)];
    }
    else
    {
        //iPad
        [self.imageVideo setFrame:CGRectMake(0, 296, SCREEN_WIDTH, 432)];
        [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_BG_CONTROL, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
        //width of slider is 390/2;
        [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, SCREEN_WIDTH - 200, HEIGHT_SLIDER_DEFAULT)];
        
    }
    
}

- (IBAction)minimizeVideo:(id)sender
{
    _isSwitchingWhenPress = YES;
    /**
     TODO:
     1. if phone at portrait
     then
     scale view and rotate it 90°
     2. If phone at landscape
     then
     switch it to portrait
     */
     float delta;
        delta = (SCREEN_HEIGHT - SCREEN_WIDTH);
    [[self view] setBounds:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_HEIGHT)];
    
    if (isPhoneLandscapeMode)
    {
        NSLog(@"Phone at landscape mode");
//        auto rotate phone
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        self.view.layer.position = CGPointMake(SCREEN_HEIGHT/2.0,SCREEN_HEIGHT/2.0);
        static NSTimeInterval animationDuration = 0.3;
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.transform = CGAffineTransformMakeRotation(0);
        }];
        [self updateRotatingPortraitWith:0 andY:0];
    }
    else
    {
        NSLog(@"Phone at portrait mode");
        //auto rotate phone
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        //rotate at center of image
        self.view.layer.position = CGPointMake(SCREEN_HEIGHT/2.0,SCREEN_HEIGHT/2.0);
        [self updateRotatingLandWith:0 andY:delta];
        static NSTimeInterval animationDuration = 0.3;
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        }];
        
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
    NSLog(@"_Value__Changed__");
}

- (IBAction)closePlayBack:(id)sender
{
    //handle remove all callback, notification here
	[self.ib_myOverlay removeFromSuperview];
    //stop handle method watcher
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(watcher)
                                               object:nil];
    [self goBackToPlayList];
    
}

- (IBAction)playVideo:(id)sender
{
    if(_playbackStreamer ->isPlaying())
    {
        NSLog(@"Yes Playing");
        [self.ib_playPlayBack setImage:[UIImage imageVideoPlay] forState:UIControlStateNormal];
        _playbackStreamer->pause();
    }
    else
    {
        NSLog(@"Not Playing");
        
        _playbackStreamer -> start();
        
        [self.ib_playPlayBack setImage:[UIImage imageVideoPause] forState:UIControlStateNormal];
    }
    [self checkOrientation];
}


#pragma mark Display Time
-(void)watcher
{
    int currentTime;
    int duration;
    if (_playbackStreamer == NULL)
    {
        return;
    }
    _playbackStreamer->getCurrentPosition(&currentTime);
    _playbackStreamer -> getDuration(&duration);
    
    self.ib_timerPlayBack.textAlignment = NSTextAlignmentCenter;
    self.ib_timerPlayBack.text = [self timeFormat:(float)(currentTime/1000)];
    
    
    float rate = (float)((END - START) / duration);
    self.ib_sliderPlayBack.value = (float)(rate * currentTime)/100;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(watcher)
                                   userInfo:nil
                                    repeats:NO];
    
}
- (NSString *) timeFormat: (float) seconds {
    
    int minutes = seconds / 60;
    
    int sec = fabs(round((int)seconds % 60));
    
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

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

@property (nonatomic, retain) NSMutableArray *clips;

@end

@implementation PlaybackViewController

@synthesize camera_mac;
@synthesize  clip_info;

@synthesize  imageVideo, urlVideo;//, topToolbar,backBarBtnItem, progressView;


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
    [self applyFont];
    
    [self.ib_viewOverlayVideo setHidden:YES];
    [self becomeActive];
}
#pragma mark - PLAY VIDEO
- (void)becomeActive
{
    listener = new PlaybackListener(self);
    self.urlVideo = clip_info.urlFile;
//    self.urlVideo = @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/release/events/cam_clip.flv"; //xxx
    self.urlVideo = @"http://movies.apple.com/media/us/mac/getamac/2009/apple-mvp-biohazard_suit-us-20090419_480x272.mov";
//    self.urlVideo = @"http://nxcomm:2013nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00001.flv";
    NSLog(@"self.urlVideo is %@", self.urlVideo);
    NSLog(@"%@", _clipsInEvent);
    if (_clipsInEvent != nil &&
        _clipsInEvent.count > 0)
    {
        self.clips = [NSMutableArray array];
        for (NSDictionary *clipInfo in _clipsInEvent)
        {
            NSString *urlClipString = [clipInfo objectForKey:@"file"];
            if (![urlClipString isEqual:[NSNull null]] &&
                ![urlClipString isEqualToString:@""])
            {
                [self.clips addObject:urlClipString];
            }
        }
    }
    NSLog(@"%@", self.clips);
    listener->updateClips(_clips);
    listener->updateFinalClipCount(_clips.count);
#if 0
    clips = [[NSMutableArray alloc]init];
    //Decide whether or not to start the background polling
    if (self.clip_info != nil )
    {
        listener = new PlaybackListener(self);
        if ([self.clip_info isLastClip])
        {
            //Only one clip & it is the last
            NSLog(@"this is the olny clip do not poll");
            [clips addObject:clip_info.urlFile];
            listener->updateClips(clips);
            listener->updateFinalClipCount(1);
        }
        else
         {
            // It is not the last clip - scheduling querying of clips
            
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
    _playbackStreamer = new MediaPlayer(true);
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
        [self.view addSubview:self.ib_myOverlay];
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
    /*
     MEDIA_PLAYER_STATE_ERROR        = 0,
     MEDIA_PLAYER_IDLE               = 1 << 0,
     MEDIA_PLAYER_INITIALIZED        = 1 << 1,
     MEDIA_PLAYER_PREPARING          = 1 << 2,
     MEDIA_PLAYER_PREPARED           = 1 << 3,
     MEDIA_PLAYER_DECODED            = 1 << 4,
     MEDIA_PLAYER_STARTED            = 1 << 5,
     MEDIA_PLAYER_PAUSED             = 1 << 6,
     MEDIA_PLAYER_STOPPED            = 1 << 7,
     MEDIA_PLAYER_PLAYBACK_COMPLETE  = 1 << 8*/
    
    
    
    switch (msg)
    
    {
            
        case MEDIA_PLAYER_PREPARED:
        {
//            self.activityIndicator.hidden = YES;
//            [self.activityIndicator stopAnimating];
//            
//            //add UI overlay here, need handle remove it
//            [self.view addSubview:self.ib_myOverlay];
//            //start watcher to update timer and slider
//            [self watcher];
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
	[self adjustViewsForOrientation:toInterfaceOrientation];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame]; // Get status bar frame dimensions
//    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
//          rect.origin.y, rect.size.width, rect.size.height);
    //HACK : incase hotspot is turned on
    if (rect.size.height>21 &&  rect.size.height<50)
    {
        
    }
    
    else
    {
        
    }
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
            [self.imageVideo setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];

            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_WIDTH - HEIGHT_BG_CONTROL, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 840/2, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(10, 10, 33, 33)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVideoFullScreenClose] forState:UIControlStateNormal];
        }
        else
        {
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
            [self.imageVideo setFrame:CGRectMake(0, 296, SCREEN_WIDTH, 432)];
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_BG_CONTROL, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
            //width of slider is 390/2;
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, SCREEN_WIDTH - 200, HEIGHT_SLIDER_DEFAULT)];
//                        [self.ib_closePlayBack setBackgroundImage:[UIImage imageVerticalVideoClose] forState:UIControlStateNormal];
        }
	}

}

#pragma mark Add Button Control
-(void)watcher{

    //    float currentTime = self.player.currentPlaybackTime;
    int currentTime;
    if (_playbackStreamer == NULL)
    {
        return;
    }
    _playbackStreamer->getCurrentPosition(&currentTime);
    
    NSLog(@"currentTime is %d", currentTime);
    
    self.ib_timerPlayBack.textAlignment = NSTextAlignmentCenter;
    
    self.ib_timerPlayBack.text = [self timeFormat:(float)(currentTime/1000)];
    
//    [self performSelector:@selector(watcher) withObject:nil afterDelay:0.5];//to update the value each 0.5 seconds
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(watcher) userInfo:nil repeats:NO];

    int duration;
    _playbackStreamer -> getDuration(&duration);
    NSLog(@"duration $$$$$$$$$$$$$$ is %d", duration);
    float rate = (float)((END - START) / duration);
    
    NSLog(@" _CC_ %f = , %d =",rate,currentTime);
    
    NSLog(@"rate * currentTime is %f", rate * currentTime);
    
    self.ib_sliderPlayBack.value = (float)(rate * currentTime)/100;

}
- (NSString *) timeFormat: (float) seconds {
    
    int minutes = seconds / 60;
    
    int sec = fabs(round((int)seconds % 60));
    
    NSString *cm = minutes <= 9 ? @"0": @"";
    
    NSString *cs = sec <= 9 ? @"0": @"";
    
    return [NSString stringWithFormat:@"%@%i:%@%i",cm, minutes, cs, sec];
    
}


- (IBAction)onTimeSliderChange:(id)sender {
    NSLog(@"_Value__Changed__");
//    float rate = (_playbackStreamer->getCurrentPlaybackTime())/ (END - START);
//    float _time =  rate * self.ib_sliderPlayBack.value;
//    NSLog(@"onTimeSliderChange, _timer is %f", _time);
//    _playbackStreamer->seekTo(_time);
//    
//    //    float currentTime = self.player.currentPlaybackTime;
//    float currentTime = _playbackStreamer->getCurrentPlaybackTime();
//    
//    self.ib_timerPlayBack.text = [self timeFormat:(currentTime)];
}

- (IBAction)closePlayBack:(id)sender {
    //handle remove all callback, notification here
    /*
     status_t        start();
     status_t        stop();
     status_t        pause();
     bool            isPlaying();
     */
	[self.ib_myOverlay removeFromSuperview];
    //stop handle method watcher
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(watcher)
                                               object:nil];
    [self goBackToPlayList];
    
}

- (IBAction)playVideo:(id)sender {
//    NSLog(@"state of _playback is %d", _playbackStreamer->get);
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

- (IBAction)minimizeVideo:(id)sender {
}
@end

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
#define END   100
#define HEIGHT_BG_CONTROL 45
#define HEIGHT_SLIDER_DEFAULT   33
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
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://movies.apple.com/media/us/mac/getamac/2009/apple-mvp-biohazard_suit-us-20090419_480x272.mov"]];
    NSString *urlString = clip_info.urlFile;
    NSURL *convertToURL = [NSURL URLWithString:urlString];
    
        NSLog(@"***********************convertToURL is %@", convertToURL);
    self.urlVideo = convertToURL;
    if (self.urlVideo)
    {
        if ([self.urlVideo scheme])	// sanity check on the URL
        {
            /* Play the movie with the specified URL. */
            [self playMovieStream:self.urlVideo];
        }
    }
}

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


#pragma mark -

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
    
    if (playbackStreamer != NULL)
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
//        xxxxxx
        
        if (isiPhone5 || isiPhone4)
        {
            [self.player.view setFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_WIDTH - HEIGHT_BG_CONTROL, SCREEN_HEIGHT, HEIGHT_BG_CONTROL)];
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 840/2, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(10, 10, 33, 33)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVideoFullScreenClose] forState:UIControlStateNormal];
        }

	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (isiPhone5 || isiPhone4)
        {
            [self.player.view setFrame:CGRectMake(0, 194, SCREEN_WIDTH, 180)];
            [self.ib_viewControlPlayer setFrame:CGRectMake(0, SCREEN_HEIGHT - HEIGHT_BG_CONTROL, SCREEN_WIDTH, HEIGHT_BG_CONTROL)];
            //width of slider is 390/2;
            [self.ib_sliderPlayBack setFrame:CGRectMake(40, 5, 364/2, HEIGHT_SLIDER_DEFAULT)];
            [self.ib_closePlayBack setFrame:CGRectMake(15, 15, 17, 17)];
            [self.ib_closePlayBack setBackgroundImage:[UIImage imageVerticalVideoClose] forState:UIControlStateNormal];
        }
	}

}

/* Called soon after the Play Movie button is pressed to play the streaming movie. */
-(void)playMovieStream:(NSURL *)movieFileURL
{
    MPMovieSourceType movieSourceType = MPMovieSourceTypeUnknown;
    /* If we have a streaming url then specify the movie source type. */
//    if ([[movieFileURL pathExtension] compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame)
//    {
        movieSourceType = MPMovieSourceTypeStreaming;
//    }
    [self createAndPlayMovieForURL:movieFileURL sourceType:movieSourceType];
}

/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL sourceType:sourceType];
    
    /* Play the movie! */
    [[self player] prepareToPlay];
}


#pragma mark Create and Play Movie URL

/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and
 controls to the existing view hierarchy.
 */
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player)
    {
        /* Save the movie object. */
        [self setPlayer:player];
        
        /* Register the current object as an observer for the movie
         notifications. */
        [self installMovieNotificationObservers];
        
        /* If you specify the movie type before playing the movie it can result
         in faster load times. */
        [player setMovieSourceType:sourceType];
        
        /* Specify the URL that points to the movie file. */
        [player setContentURL:movieURL];
        
        /* Apply the user movie preference settings to the movie player object. */
        [self applyUserSettingsToMoviePlayer];
    }
}
#pragma mark Movie Settings

/* Apply user movie preference settings (these are set from the Settings: iPhone Settings->Movie Player)
 for scaling mode, control style, background color, repeat mode, application audio session, background
 image and AirPlay mode.
 */
-(void)applyUserSettingsToMoviePlayer
{
    MPMoviePlayerController *player = [self player];
    if (player)
    {
        self.player.controlStyle = MPMovieControlStyleNone;
        self.player.fullscreen = YES;
        self.player.shouldAutoplay = YES;
        self.player.movieSourceType = MPMovieSourceTypeStreaming;
    }
}

#pragma mark Movie Notification Handlers

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    
    if (error) {
        
        NSLog(@"Did finish with error: %@", error);
        
    }
    [self closePlayBack:nil];
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    

}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
    

}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    //hide
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    [self.player play];
    
    self.player.view.frame = CGRectMake(0, 190,320,180);
	// Add an overlay view on top of the movie view
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.ib_myOverlay];
    
    self.ib_sliderPlayBack.minimumValue = START;
    self.ib_sliderPlayBack.maximumValue = END;
    
    //    UIImage *ball = [UIImage imageNamed:@"player-handle"];
    //    [self.slider setThumbImage:ball forState:UIControlStateNormal];
    //    [self.slider setThumbImage:ball forState:UIControlStateHighlighted];
//    [self.ib_sliderPlayBack setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageVideoProgressBG]]];
    [self.ib_sliderPlayBack setMinimumTrackTintColor:[UIColor colorWithPatternImage:[UIImage imageVideoProgressGreen]]];
    
    [self watcher];
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
    MPMoviePlayerController *player = [self player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setPlayer:nil];
}








#pragma mark Add Button Control
-(void)watcher{
    
    if([[NSString stringWithFormat:@"%f", self.player.currentPlaybackTime] isEqualToString:@"nan"])
        
    {
        
        NSLog(@"Sorry,video can't be played");
        
        //[self showAlertError:@"Sorry,video can't be played"];
        
        return;
        
    }
    
    float currentTime = self.player.currentPlaybackTime;
    
    
    
    self.ib_timerPlayBack.textAlignment = NSTextAlignmentCenter;
    
    self.ib_timerPlayBack.text = [self timeFormat:currentTime];
    
    [self performSelector:@selector(watcher) withObject:nil afterDelay:0.5];//to update the value each 0.5 seconds
    
    
    
    float rate = (END - START) / self.player.duration;
    
    NSLog(@" _CC_ %f = , %f =",rate,currentTime);
    
    self.ib_sliderPlayBack.value = rate * currentTime;
    
    
    
    
    
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
    
    float rate = self.player.duration / (END - START);
    
    float _time =  rate * self.ib_sliderPlayBack.value;
    
    self.player.currentPlaybackTime = _time;//totalVideoTime / END;
    
    float currentTime = self.player.currentPlaybackTime;
    
    self.ib_timerPlayBack.text = [self timeFormat:currentTime];
}

- (IBAction)closePlayBack:(id)sender {
    
    [self.player stop];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(watcher)
                                               object:nil];
    
	[self.player.view removeFromSuperview];
    
	[self.ib_myOverlay removeFromSuperview];
    
    [self deletePlayerAndNotificationObservers];
    
    [self goBackToPlayList];
    
}

- (IBAction)playVideo:(id)sender {
//    [self playMovieStream:url];
    NSLog(@"self.player.playbackState is %d", self.player.playbackState);
    
    if(self.player.playbackState == MPMoviePlaybackStatePlaying)
        
    {
        
        NSLog(@"Yes Playing");
        
        [self.ib_playPlayBack setImage:[UIImage imageVideoPlay] forState:UIControlStateNormal];
        
        [self.player pause];
        
    }
    
//    else if (self.player.playbackState  == MPMoviePlaybackStatePaused)
//
//        
//    {
//        
//        NSLog(@"Not Playing");
//        
//        [self.player play];
//        
//        [self.ib_playPlayBack setImage:[UIImage imageVideoPause] forState:UIControlStateNormal];
//        
//        [self watcher];
//        
//    }
//    else if (self.player.playbackState == MPMoviePlaybackStateStopped)
//    {
//        [self.ib_viewOverlayVideo setHidden:YES];
//        
//        [self playMovieStream:self.urlVideo];
//    }
    else
    {
        NSLog(@"Not Playing");
        
        [self.player play];
        
        [self.ib_playPlayBack setImage:[UIImage imageVideoPause] forState:UIControlStateNormal];
        
        [self watcher];
    }
    [self checkOrientation];
}

- (IBAction)minimizeVideo:(id)sender {
}

@end

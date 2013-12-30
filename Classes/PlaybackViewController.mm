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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"PlaybackViewController_ipad"
                                      owner:self
                                    options:nil];
    }
    
    self.navigationController.navigationBarHidden = NO;
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                       @"Back", nil);
    
    backBarBtnItem = [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(goBackToPlayList)] autorelease];
    
	self.navigationItem.leftBarButtonItem = backBarBtnItem;
    self.navigationItem.leftBarButtonItem.tintColor = nil;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    self.navigationItem.title = @"Camera";
    
    [self becomeActive];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self checkOrientation];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: ");
    //[self goBackToPlayList];
    [self stopStream:nil];
}



- (void)becomeActive
{
    
    playbackStreamer = NULL;
    
    
    //CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    //self.backBarBtnItem.target = self;
   // self.backBarBtnItem.action = @selector(goBackToPlayList);
    
    self.urlVideo = clip_info.urlFile;
    
    if (_clipsInEvent != nil &&
        _clipsInEvent.count > 0)
    {
        for (NSDictionary *clipInfo in _clipsInEvent)
        {
            NSString *urlClipString = [clipInfo objectForKey:@"file"];
            
            if (urlClipString != nil &&
                ![urlClipString isEqualToString:@""])
            {
                [clips addObject:urlClipString];
            }
        }
    }
    
    listener->updateClips(clips);
    listener->updateFinalClipCount(clips.count);
    
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

#pragma mark - Poll camera events

-(void) getCameraPlaylistForEvent:(NSTimer *) clipTimer
{
    PlaylistInfo *first_clip = [clipTimer userInfo];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)]
                                        autorelease];
    NSString *mac = first_clip.mac_addr;
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString * event_timecode = [NSString stringWithFormat:@"0%@_%@", [first_clip getAlertType], [first_clip getAlertVal]];
    
    [jsonComm getAllRecordedFilesWithRegistrationId:mac
                                           andEvent:event_timecode
                                          andApiKey:apiKey];
    
   

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
                NSArray *playlist = [[eventArr objectAtIndex:0] objectForKey:@"playlist"];
                
                for (NSDictionary *clipInfo in playlist) {
                    //NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                    
                    PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init]autorelease];
                    playlistInfo.mac_addr = clip_info.mac_addr;
                    
                    playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                    playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                    playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                    
                    
                    //check if the clip is in our private array
                    BOOL found = FALSE;
                    for ( NSString * one_clip in clips)
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
                        [clips addObject:playlistInfo.urlFile];
                        NSLog(@"clips: %@", clips);
                    }
                    
                    
                    if ([playlistInfo isLastClip])
                    {
                        NSLog(@"This is last");
                        got_last_clip = TRUE;
                    }
                    
                }
                
                NSLog(@"there is %d in playlist", [clips count]);
            }
            
        }
    }
    
    if (got_last_clip == TRUE)
    {
        listener->updateFinalClipCount([clips count]);

    }
    else
    {
        
        
        self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(getCameraPlaylistForEvent:)
                                                        userInfo:clip_info repeats:NO];
    }
    
    listener->updateClips(clips);
    
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




#pragma mark - Play Video

-(IBAction)startStream  :(id)sender
{
    [self startStream];
}

-(void) startStream
{
    
    
    playbackStreamer = new MediaPlayer(true);
    playbackStreamer->setListener(listener);
    
    [self performSelectorInBackground:@selector(startStream_bg) withObject:nil];
}

- (void)startStream_bg
{
    status_t status = !NO_ERROR;
    
    NSString * url = self.urlVideo;

    
    status = playbackStreamer->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("setDataSource error: %d\n", status);
        [self handleMessage:MEDIA_ERROR_SERVER_DIED
                       ext1:0
                       ext2:0];
        return;
    }
    
    playbackStreamer->setVideoSurface(self.imageVideo);
    
    NSLog(@"Prepare the player");
    
    status=  playbackStreamer->prepare();
    
    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blueColor];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    // Play anyhow
    
    status=  playbackStreamer->start();
    
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
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)stopStream:(id) sender
{
    NSLog(@"Stop stream start ");

    if (playbackStreamer != NULL)
    {
        NSLog(@"Stop stream playbackStreamer != NULL");
        if(playbackStreamer->isPlaying())
        {
            playbackStreamer->suspend();
            playbackStreamer->stop();
            delete playbackStreamer;
            playbackStreamer = NULL;
        }
        else // set Data source failed!
        {
            playbackStreamer->suspend();
            playbackStreamer->stop();
            delete playbackStreamer;
            playbackStreamer = NULL;
            
        }
    }
    
  
    //20130919:phung : delete here will crash !!! don't know why

//    if (listener != NULL)
//    {
//      delete listener;
//    }

    
    NSLog(@"Stop stream end");
    
}


-(void) handleMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2
{
    
    switch (msg)
    {
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

#pragma mark - Rotation screen
- (BOOL)shouldAutorotate
{

	return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    CGFloat screenHeight = screenBounds.size.height;
    
    CGSize activitySize = _activityIndicator.frame.size;
    
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
	{
        
        self.view.backgroundColor = nil;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.navigationController.navigationBar.hidden = YES;
        
        CGFloat imageViewHeight = screenHeight * 9 / 16;
        CGRect newRect = CGRectMake(0, (screenWidth - imageViewHeight) / 2, screenHeight, imageViewHeight);
        self.imageVideo.frame = newRect;
        self.activityIndicator.frame = CGRectMake(screenHeight / 2 - activitySize.width / 2, screenWidth / 2 - activitySize.height / 2, activitySize.width, activitySize.height);
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        NSInteger deltaY = 0;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            deltaY = 20;
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.navigationController.navigationBar.hidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        
        CGFloat imageViewHeight = screenWidth * 9 / 16;
        
        CGRect destRect = CGRectMake(0, 44 + deltaY, screenWidth, imageViewHeight);
        self.imageVideo.frame = destRect;
        
        self.activityIndicator.frame = CGRectMake(screenWidth / 2 - activitySize.width / 2, imageViewHeight / 2 - activitySize.height / 2 + 44 + deltaY, activitySize.width, activitySize.height);
	}
    
//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(goBackToCameraList);
    // SLIDE MENU
    //    self.backBarBtnItem.target = self.stackViewController;
    //    self.backBarBtnItem.action = @selector(toggleLeftViewController);
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
    [clips release];
    [super dealloc];
}

@end

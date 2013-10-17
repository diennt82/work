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

@synthesize  imageVideo, topToolbar,backBarBtnItem, progressView, urlVideo;
@synthesize list_refresher;


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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_background"]];
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
    
    
    clips = [[NSMutableArray alloc]init];
    
    //Decide whether or not to start the background polling
    
    if (self.clip_info != nil )
    {
        
        listener = new PlaybackListener(self);
        
        
        if ([self.clip_info isLastClip])
        {
            //Only one clip & it is the last
            NSLog(@"this is the olny clip do not poll");
        }
        else
        {
            
            
            // It is not the last clip - scheduling querying of clips
            self.list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                              target:self
                                                            selector:@selector(getCameraPlaylistForEvent:)
                                                            userInfo:clip_info repeats:NO];
        }
        
        
        self.urlVideo = self.clip_info.urlFile;
    }
    
    

    

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
    
    if (got_last_clip == TRUE)
    {
        listener->updateFinalClipCount([clips count]);

    }
    else
    {
        
        
        list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(getCameraPlaylistForEvent:)
                                                        userInfo:clip_info repeats:NO];
    }
    
    listener->updateClips(clips);
    
}

- (void)getPlaylistFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"getPlaylistFailedWithResponse");
    list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                      target:self
                                                    selector:@selector(getCameraPlaylistForEvent:)
                                                    userInfo:clip_info repeats:NO];

}

- (void)getPlaylistUnreachableSetver
{
    NSLog(@"getPlaylistUnreachableSetver");
    list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
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
    status_t status;
    
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
    NSLog(@"Should Auto Rotate");
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
    NSLog(@"1 Statusbar frame: %1.0f, %1.0f, %1.0f, %1.0f", rect.origin.x,
          rect.origin.y, rect.size.width, rect.size.height);
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            
            CGRect newRect = CGRectMake(0, 96, 1024, 576);
            
            NSLog(@"width: %f", screenBounds.size.width);
            NSLog(@"heigth: %f", screenBounds.size.height);
            
            if (screenBounds.size.height == 1920)
            {
                newRect = CGRectMake(0, 304, 1920, 1080);
            }
            
            self.imageVideo.frame = newRect;
        }
        else
        {
            
            //            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController_land"
            //                                          owner:self
            //                                        options:nil];
            CGRect newRect = CGRectMake(0, 32, 480, 256);
            self.imageVideo.frame = newRect;
            
            self.view.backgroundColor = [UIColor blackColor];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            self.topToolbar.hidden = YES;
            self.navigationController.navigationBar.hidden = YES;
        }
	}
	else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            
            CGRect newRect = CGRectMake(0, 44, 768, 432);
            
            if (screenBounds.size.height == 1920)
            {
                newRect = CGRectMake(0, 304, 1200, 675);
            }
            
            self.imageVideo.frame = newRect;
        }
        else
        {
            //            [[NSBundle mainBundle] loadNibNamed:@"H264PlayerViewController"
            //                                          owner:self
            //                                        options:nil];
            CGRect newRect = CGRectMake(0, 44, 320, 180);
            self.imageVideo.frame = newRect;
            
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_background"]];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            self.topToolbar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        }
	}
    
    [self checkIphone5Size:orientation];
    
//    self.backBarBtnItem.target = self;
//    self.backBarBtnItem.action = @selector(goBackToCameraList);
    // SLIDE MENU
    //    self.backBarBtnItem.target = self.stackViewController;
    //    self.backBarBtnItem.action = @selector(toggleLeftViewController);
}

- (void) checkIphone5Size: (UIInterfaceOrientation)orientation
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if (screenBounds.size.height == 568)
    {
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"iphone5 SHift right...");
            //            CGAffineTransform translate = CGAffineTransformMakeTranslation(44, 0);
            //            self.imageViewVideo.transform = translate;
            CGRect newRect = CGRectMake(0, 0, 568, 320);
            self.imageVideo.frame = newRect;
        }
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [imageVideo release];
    //[topToolbar release];
    //[backBarBtnItem release];
    //[progressView release];
    
    //[urlVideo release];
    
    
    [self.list_refresher release];

    [_activityIndicator release];
    [clip_info release];
    [clips release];
    [super dealloc];
}

@end

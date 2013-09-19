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
    
    self.navigationController.navigationBarHidden = YES;
    
    self.progressView.hidden = NO;
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                                       @"Back", nil);
	self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    [self becomeActive];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopStream];
}

- (void)becomeActive
{
    //CamProfile *cp = self.selectedChannel.profile;
    
    //Set camera name
    //self.cameraNameBarBtnItem.title = cp.name;
    
    //set Button handler
    self.backBarBtnItem.target = self;
    self.backBarBtnItem.action = @selector(goBackToPlayList);
    
    
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
            list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
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

-(void) getCameraPlaylistForEvent:(PlaylistInfo *) first_clip
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
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
    
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSArray *eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            
            NSLog(@"play list: %@ ",responseDict);
            
            
            for (NSDictionary *playlist in eventArr) {
                NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                
                PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init]autorelease];
                playlistInfo.mac_addr = clip_info.mac_addr;
                
                playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                

                //check if the clip is in our private array
                BOOL found = FALSE; 
                for ( NSString * one_clip in clips)
                {
                    if ([playlistInfo.urlFile isEqualToString:one_clip])
                    {
                        found = TRUE; 
                        break;
                    }
                }
                
                if (found == FALSE)
                {
                    //add the clip
                    [clips addObject:playlistInfo.urlFile];
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
    
    if (got_last_clip == FALSE)
    {
        list_refresher = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(getCameraPlaylistForEvent:)
                                                        userInfo:clip_info repeats:NO];

    }
    else
    {
        listener->updateFinalClipCount([clips count]);
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

-(void) startStream
{
    //self.progressView.hidden = YES;
    
    status_t status;
    
    mp = new MediaPlayer(true);
    mp->setListener(listener);
    
    
    NSString * url =@"";
    
    url = self.urlVideo;
    
    
    status = mp->setDataSource([url UTF8String]);
    printf("setDataSource return: %d\n", status);
    
    
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("setDataSource error: %d\n", status);
        return;
    }

    mp->setVideoSurface(self.imageVideo);
    
    NSLog(@"Prepare the player");
    
    status=  mp->prepare();
    
    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("prepare() error: %d\n", status);
        exit(1);
    }
    
    self.progressView.hidden = YES;
    // Play anyhow
    
    status=  mp->start();
    
    printf("start() return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {
        
        printf("start() error: %d\n", status);
        return;
    }
    
    self.progressView.hidden = YES;
}

- (void)goBackToPlayList
{
    if (mp)
    {
        [self stopStream];
    }
    
    if ([list_refresher isValid])
    {
        [list_refresher invalidate]; 
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    //DBG
//    [self dismissViewControllerAnimated:NO
//                             completion:nil];
}

- (void)stopStream
{
    printf("STOP\n");
    if (mp != NULL && mp->isPlaying())
    {
        mp->suspend();
        mp->stop();
    }
    free(mp);
    
    if (listener != NULL)
    {
        //free(listener);
    }
    
    
    mp = NULL;
}


-(void) handeMessage:(int) msg ext1: (int) ext1 ext2:(int) ext2
{
    
    switch (msg)
    {
        case MEDIA_PLAYBACK_COMPLETE:
            //DONE Playback
            //clean up
            //[self goBackToPlayList];
            
            break;
            
        default:
            break;
    }
    
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageVideo release];
    [_topToolbar release];
    [_backBarBtnItem release];
    [_progressView release];
    
    [_urlVideo release];
     [list_refresher release]; 
    [super dealloc];
}
- (void)viewDidUnload {
    [self setImageVideo:nil];
    [self setTopToolbar:nil];
    [self setBackBarBtnItem:nil];
    [self setProgressView:nil];
    
    [self setUrlVideo:nil];
    
    [super viewDidUnload];
}
@end

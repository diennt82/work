//
//  NotificationViewController.m
//  BlinkHD_ios
//
//  Created by Admin on 14/9/13.
//  Copyright (c) 2013 Smart Panda Ltd. All rights reserved.
//

#import "NotificationViewController.h"
#import <MonitorCommunication/MonitorCommunication.h>
#import "MBPNavController.h"


@interface NotificationViewController ()

@end

@implementation NotificationViewController

@synthesize   cameraMacNoColon, cameraName, alertType, alertVal;
@synthesize eventInfo;
@synthesize  delegate;


-(void) dealloc
{
    [super dealloc];
    [cameraMacNoColon release];
    [cameraName release];
    [alertVal release];
    [alertType release];
    //[eventInfo release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	return (interfaceOrientation == UIInterfaceOrientationMaskPortrait);
    
}




- (BOOL) shouldAutorotate
{
    
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    


    NSString * msg = NSLocalizedStringWithDefaultValue(@"Back",nil, [NSBundle mainBundle],
                                            @"Back", nil);
    
    //Back key
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:msg
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    // Do any additional setup after loading the view from its nib.

    
    //TODO:
    // 1. Load latest snapshot event
    
    [self getLatestEvent];
    
    
    
    
    // 2. Load all playlist
    [self getPlaylist] ;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction) gotoCameraList:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];

    // Will call dismiss eventually
    [delegate sendStatus:SCAN_CAMERA];

}

-(IBAction) viewRecording:(id)sender
{

    if(eventInfo.urlFile && ![eventInfo.urlFile isEqualToString:@""])
    {
        PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
        playbackViewController.urlVideo = eventInfo.urlFile;
        
        [playbackViewController autorelease];
        
        [self presentViewController:playbackViewController animated:NO  completion:nil]; 
        
    }
    else
    {
        NSLog(@"urlFile nil");
        [[[[UIAlertView alloc] initWithTitle:@"Empty"
                                     message:@"Url file is empty"
                                    delegate:self
                           cancelButtonTitle:nil
                           otherButtonTitles:@"OK", nil]
          autorelease]
         show];
    }

}



- (void)presentModallyOn:(UIViewController *)parent
{
    MBPNavController *    navController;
    
    //setup nav controller
    navController= [[[MBPNavController alloc]initWithRootViewController:self] autorelease];
    
    
    
    // Create a navigation controller with us as its root.
    assert(navController != nil);
    
    navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    // Set up the Cancel button on the left of the navigation bar.
    self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)] autorelease];
    assert(self.navigationItem.leftBarButtonItem != nil);
   
    // Present the navigation controller on the specified parent
    // view controller.
    
    [parent presentViewController:navController
                         animated:NO
                       completion:nil];
}



-(IBAction)goBack:(id)sender
{
    [self gotoCameraList:nil];
    
}
#pragma mark -
#pragma mark Get Event


-(void) getLatestEvent
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(getEventSuccessWithResponse:)
                                                                         FailSelector:@selector(getEventFailedWithResponse:)
                                                                            ServerErr:@selector(getEventUnreachableSetver)];
    NSString *mac = self.cameraMacNoColon;
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    
    NSString * event_timecode = [NSString stringWithFormat:@"0%@_%@", self.alertType, self.alertVal];
    
    [jsonComm getAllRecordedFilesWithRegistrationId:mac
                                           andEvent:event_timecode
                                          andApiKey:apiKey];
}

- (void)getEventSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict) {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSLog(@"Event : %@ ",responseDict);
            
            NSArray *eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            

            if (eventArr.count == 1)
            {
                tempPlaylist.playlistArray = [NSMutableArray array];
                
                //expect 1 event only
                NSDictionary * eventPlaylist = [eventArr objectAtIndex:0];
                
                NSDictionary *clipInfo = [[eventPlaylist objectForKey:@"playlist"]
                                          objectAtIndex:0];
                
                eventInfo = [[[PlaylistInfo alloc] init] autorelease];
                eventInfo.mac_addr = self.cameraMacNoColon;
                eventInfo.urlImage = [clipInfo objectForKey:@"image"];
                eventInfo.titleString = [clipInfo objectForKey:@"title"];
                eventInfo.urlFile = [clipInfo objectForKey:@"file"];
                
                UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:eventInfo.urlImage]]] ;
                [image autorelease];
                [lastest_snapshot setImage: image];
            }
            else
            {
                NSLog(@"Empty event ");
            }
        }

    }
}

- (void)getEventFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"getPlaylistFailedWithResponse");
}

- (void)getEventUnreachableSetver
{
    NSLog(@"getPlaylistUnreachableSetver");
}


#pragma mark -
#pragma mark Get Playlist

-(void) getPlaylist
{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BMS_JSON_Communication *jsonComm = [[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:@selector(getPlaylistSuccessWithResponse:)
                                                                         FailSelector:@selector(getPlaylistFailedWithResponse:)
                                                                            ServerErr:@selector(getPlaylistUnreachableSetver)];
    NSString *mac = self.cameraMacNoColon;
    
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
  
    
    
    [jsonComm getAllRecordedFilesWithRegistrationId:mac
                                           andEvent:[NSString stringWithFormat:@"0%@",self.alertType]
                                          andApiKey:apiKey];
}

- (void)getPlaylistSuccessWithResponse: (NSDictionary *)responseDict
{
    if (responseDict)
    {
        if ([[responseDict objectForKey:@"status"] intValue] == 200)
        {
            NSArray *eventArr = [[responseDict objectForKey:@"data"] objectForKey:@"events"];
            
            
            NSLog(@"play list: %@ ",responseDict);

            tempPlaylist.playlistArray = [NSMutableArray array];
            
            for (NSDictionary *playlist in eventArr) {
                NSDictionary *clipInfo = [[playlist objectForKey:@"playlist"] objectAtIndex:0];
                
                PlaylistInfo *playlistInfo = [[[PlaylistInfo alloc] init]autorelease];
                playlistInfo.mac_addr = self.cameraMacNoColon;
                playlistInfo.urlImage = [clipInfo objectForKey:@"image"];
                playlistInfo.titleString = [clipInfo objectForKey:@"title"];
                playlistInfo.urlFile = [clipInfo objectForKey:@"file"];
                
                [tempPlaylist.playlistArray addObject:playlistInfo];
            }
            
            NSLog(@"there is %d in playlist", [tempPlaylist.playlistArray count]);
            [progress stopAnimating];
            
            [tempPlaylist.tableView reloadData]; 
            tempPlaylist.view.hidden = NO;
            
        }
        

    
    }
}

- (void)getPlaylistFailedWithResponse: (NSDictionary *)responseDict
{
    NSLog(@"getPlaylistFailedWithResponse");
}

- (void)getPlaylistUnreachableSetver
{
    NSLog(@"getPlaylistUnreachableSetver");
}



@end

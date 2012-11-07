//
//  QuickViewCamera_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 8/16/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "QuickViewCamera_ViewController.h"

@interface QuickViewCamera_ViewController ()

@end

@implementation QuickViewCamera_ViewController

@synthesize streamer;
@synthesize listOfChannel;
@synthesize currentChannelIndex; 
@synthesize  flipTimer, alertTimer;

@synthesize selected_channel;

SystemSoundID soundFileObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        CFBundleRef mainbundle = CFBundleGetMainBundle();
        CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("beep"), CFSTR("wav"), NULL);
        OSStatus status = AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
        
        NSLog(@"sound obj: %ld  sstatus: %ld", soundFileObject, status);


    }
    return self;
}

-(void) dealloc
{
    [streamer release];
    [listOfChannel release];
    [flipTimer release]; 
    [selected_channel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
        
    self.currentChannelIndex = 0; 
    
    if (self.listOfChannel == nil)
    {
        NSLog(@"ERROR list of channel is nil!!!"); 
    }
    
    [self channelFlip:nil]; 
    
    self.flipTimer = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                 target:self
                                               selector:@selector(channelFlip:) 
                                               userInfo:nil
                                                repeats:YES];
    
    //set Button handler 
    cameraListBarBtn.target = self;
    cameraListBarBtn.action = @selector(goBackToCameraList);
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
     NSLog(@"viewDidUnloadl!!!"); 
    
    
      
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return  YES ;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma  mark Orientation handling

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation
{
    NSString * currentCam = cameraNameBarBtn.title; 
       
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) 
    {
        
        [[NSBundle mainBundle] loadNibNamed:@"QuickViewCamera_landscape" 
									  owner:self 
									options:nil];
        

       
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        
        [[NSBundle mainBundle] loadNibNamed:@"QuickViewCamera_ViewController" 
									  owner:self 
									options:nil];
        

    }
    
    
    cameraListBarBtn.target = self;
    cameraListBarBtn.action = @selector(goBackToCameraList);
    
    
    cameraNameBarBtn.title = currentCam; 
    
    streamer.videoImage = videoView;
    [streamer switchToOrientation:orientation];
    
}




-(void) goBackToCameraList
{
    if (scanner != nil)
    {
        [scanner cancel];
    }
    
    //invalidate all timer
    if (self.alertTimer != nil && [self.alertTimer isValid])
    {
        [self.alertTimer invalidate]; 
    }
    if (self.flipTimer != nil && [self.flipTimer isValid])
    {
        [self.flipTimer invalidate]; 
    }
    
    
    if (self.streamer != nil)
    {
        [self.streamer stopStreaming]; 
    }
   
    [self.navigationController popViewControllerAnimated:NO];


}





-(void) channelFlip: (NSTimer*) exp
{

    CamChannel * channel; 
    BOOL foundNext = FALSE; 
    
    while (foundNext == FALSE)
    {
        
        channel =(CamChannel*) [ self.listOfChannel objectAtIndex:self.currentChannelIndex];
        
        if (channel != nil && 
            channel.profile != nil && 
            channel.profile.isInLocal == TRUE)
        {
            [self viewOneChannel:channel];    
            foundNext = TRUE;
        }
        else
        {
            self.currentChannelIndex = ( self.currentChannelIndex +1 ) % [self.listOfChannel count]; 
        }
    }
    
    self.currentChannelIndex = ( self.currentChannelIndex +1 ) % [self.listOfChannel count]; 

}


//Should be non blocking... 

-(void) viewOneChannel:(CamChannel *) ch
{
    
    cameraNameBarBtn.title = ch.profile.name;
    
	NSString* ip = ch.profile.ip_address;
	int port = ch.profile.port;
    
	NSLog(@"connect to cam %@: %@:%d",ch.profile.name, ip, port);
    
    self.selected_channel = ch;
    
    if (streamer != nil)
    {
        [streamer stopStreaming];
        [streamer release];
    }
     
    streamer = [[MBP_Streamer alloc]initWithIp:ip 
                                       andPort:port 
                                       handler:self ];
    
        
    streamer.communication_mode = COMM_MODE_LOCAL;
    
    [streamer setVideoImage:videoView];
    streamer.mTempUpdater = self;
    streamer.mFrameUpdater = self;
    
    
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    
    UIInterfaceOrientation infOrientation = (UIInterfaceOrientation)deviceOrientation;
    
    if ( deviceOrientation == UIDeviceOrientationUnknown ||
        deviceOrientation == UIDeviceOrientationFaceDown ||
        deviceOrientation == UIDeviceOrientationFaceUp)
    {
        infOrientation = UIInterfaceOrientationPortrait;
    }
    
    [streamer switchToOrientation:infOrientation];
    
    
    [streamer startStreaming];
    
	
}


#pragma mark -
#pragma mark StreamerEventHandler


-(void) playSound
{
    
	NSLog(@"Play the B: %ld", soundFileObject);
    
    //NSLog(@"init audio session..");
    //AudioSessionInitialize(NULL, NULL, NULL, nil);
    //AudioSessionSetActive(true);

     
    
	//201201011 This is needed to play the system sound on top of audio from camera
	UInt32 sessionCategory =  kAudioSessionCategory_AmbientSound;    // 1
	AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,                        // 2
                             sizeof (sessionCategory),                                   // 3
                             &sessionCategory                                            // 4
                             );

	//Play beep
	//AudioServicesPlaySystemSound(soundFileObject); <- does not work on Iphone
    AudioServicesPlayAlertSound(soundFileObject);
    
    
}


-(void) periodicPopup:(NSTimer *) exp
{
	NSString * msg = (NSString *) [exp userInfo];
    
    [self playSound];
    
    
    
	if ( alert != nil)
	{
		if ([alert isVisible]) 
		{
			[alert setMessage:msg];
			
		
            return;
		}
		
		[alert release]; 
		alert = nil; 
		
	}
	
	NSLog(@"create new alert"); 
	alert = [[UIAlertView alloc]
			 initWithTitle:@"Streamer Stopped"
			 message:msg
			 delegate:self
			 cancelButtonTitle:@"OK"
			 otherButtonTitles:nil];
	
	alert.tag = LOCAL_VIDEO_STOPPED_UNEXPECTEDLY;
	[alert show];
	
	[alert retain]; 
	
	
	
	
}

-(void) stopPeriodicPopup
{
	if (self.alertTimer != nil)
	{
		if ([self.alertTimer isValid])
		{
			[self.alertTimer invalidate];
		}
		
	}
	if ( alert != nil)
	{
		if ([alert isVisible]) 
		{
			[alert dismissWithClickedButtonIndex:1 animated:NO ];
		}
		
		[alert release]; 
		alert = nil; 
		
	}
}


-(void) statusReport:(int) status andObj:(NSObject*) obj
{
    
	
	switch (status) {
		case STREAM_STARTED:
		{
			progressView.hidden = YES;
			[self stopPeriodicPopup];
            
            
            if (self.flipTimer == nil  || ![self.flipTimer isValid])
            {
                NSLog(@"restart flip timer "); 
                self.flipTimer = [NSTimer scheduledTimerWithTimeInterval:20.0
                                                                  target:self
                                                                selector:@selector(channelFlip:)
                                                                userInfo:nil
                                                                 repeats:YES];
            }
           
			
			break;
		}
		case STREAM_STOPPED:
			break;
		case STREAM_STOPPED_UNEXPECTEDLY:
		{
            
            //Stop flipTimer 
            if (self.flipTimer != nil && [self.flipTimer isValid])
            {
                [self.flipTimer invalidate]; 
                
            }
            /* Stop Streamming */
            [self.streamer stopStreaming];

            // re-scan for the camera */
            [self scan_for_missing_camera];
            
            
            
            
			//Perform connectivity check - wifi?
            
            
			//NSString * currSSID = [CameraPassword fetchSSIDInfo]; 
			NSString * msg = @"Network lost link. Please check the Phone, Camera and Wifi router or move closer to the Router" ;
			
			
			//popup ?
			if (self.alertTimer != nil && [self.alertTimer isValid])
			{
				//some periodic is running dont care
                NSLog(@"some periodic is running dont care");
				
			}
			else
			{
                
				self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
																   target:self 
																 selector:@selector(periodicPopup:) 
																 userInfo:msg 
																  repeats:YES];
				[self.alertTimer fire] ;//fire once now
                
			}
			
			
			break;
		}
		
		case STREAM_RESTARTED:
			break; 
		default:
			break;
	}
}




#pragma mark -
#pragma mark Alertview delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	int tag = alertView.tag;
	
	if (tag == LOCAL_VIDEO_STOPPED_UNEXPECTEDLY)
	{
		switch(buttonIndex) {
			case 0: //Stop monitoring 
							break;
			case 1: //continue -- streamer is connecting so we dont do anything here.
				break;
			default:
				break;
		}
		[alert release];
		alert = nil; 
	}
	
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView willDismissWithButtonIndex.. ");
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"alertView Cancelled.. ");
}

#pragma mark -

#pragma mark -
#pragma mark  Temp & frame rate update 



-(void) updateTemperature:(int) tempC
{
    
    float tempF ;
    if (tempC < 1 || tempC > 60)
    {
        return; 
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int tempunit = [userDefaults integerForKey:_tempUnit];
    
    
	switch (tempunit) {
		case 0://F
			tempF= ((float)tempC*9 + 32*5)/5;
            
            [temperature_label performSelectorOnMainThread:@selector(setText:)
                                                withObject:[NSString stringWithFormat:@"%.2f \u00B0F", tempF] 
                                             waitUntilDone:YES];
            
			break;
		case 1:
            [temperature_label performSelectorOnMainThread:@selector(setText:)
                                                withObject:[NSString stringWithFormat:@"%d \u00B0C", tempC] 
                                             waitUntilDone:YES];
			break;
		default:
			break;
	}
    
    
    
    
    if (  tempC > HIGH_TEMPERATURE_THRESHOLD_C || 
        tempC < LOW_TEMPERATURE_THRESHOLD_C)
    {
        //Go RED
        [temperature_bg performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[UIImage imageNamed:@"temp_alert_bg.png"]
                                      waitUntilDone:YES];
        
    }
    else
    {
        [temperature_bg performSelectorOnMainThread:@selector(setImage:)
                                         withObject:[UIImage imageNamed:@"temp_bg.png"]
                                      waitUntilDone:YES];
    }
    
    
    
    
}

-(void) updateFrameRate:(int) frameRate
{
   
}
#pragma mark -


#pragma mark - 
#pragma mark Scan cameras

- (void) scan_for_missing_camera
{
    NSLog(@"scanning for : %@", self.selected_channel.profile.mac_address);
	
	scanner = [[ScanForCamera alloc] initWithNotifier:self];
	[scanner scan_for_device:self.selected_channel.profile.mac_address];
    
}


- (void)scan_done:(NSArray *) _scan_results
{
	//Sync
    
    if ([_scan_results count] ==0 )
    {
        //empty result... rescan
        NSLog(@"Empty result-> Re- scan");
        [self scan_for_missing_camera];
        
    }
    else
    {
        //confirm the mac address
        CamProfile * cp = self.selected_channel.profile; 
        BOOL found = FALSE; 
        for (int j = 0; j < [_scan_results count]; j++)
        {
            CamProfile * cp1 = (CamProfile *) [_scan_results objectAtIndex:j];
            
            if ( [cp.mac_address isEqualToString:cp1.mac_address])
            {
                //FOUND - copy ip address.
                cp.ip_address = cp1.ip_address;
                found = TRUE; 
                break;
            }
        }
        
        
        if (!found)
        {
            //Rescann...
            NSLog(@"Re- scan for : %@", self.selected_channel.profile.mac_address);
            [self scan_for_missing_camera];
        }
        else
        {
            //Restart streaming..
            NSLog(@"Re-start streaming for : %@", self.selected_channel.profile.mac_address);
            [self viewOneChannel:self.selected_channel];   
        }
    }
    
}
#pragma mark - 


@end

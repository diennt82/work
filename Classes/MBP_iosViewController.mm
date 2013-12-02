//
//  MBP_iosViewController.m
//  MBP_ios
//
//  Created by NxComm on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <CFNetwork/CFNetwork.h>
#include <ifaddrs.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CameraScanner/CameraScanner.h>
#import <MonitorCommunication/MonitorCommunication.h>

#import "MBP_FirstPage.h"
#import "MBP_iosViewController.h"
#import "PlayListViewController.h"
#import "H264PlayerViewController.h"


@implementation MBP_iosViewController

//@synthesize  mainMenuView;

@synthesize toTakeSnapShot,recordInProgress ;
@synthesize bc_addr,own_addr;


@synthesize channel_array; 
@synthesize restored_profiles ; 

@synthesize progressView;
@synthesize splashScreen;
@synthesize sunBackground;



@synthesize app_stage;



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
// Custom initialization

}
return self;
}
 */

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

[super loadView];


}*/

- (void) initialize 
{
	self.toTakeSnapShot = NO;
	self.recordInProgress = NO;
    


	self.app_stage = APP_STAGE_INIT;

    CFBundleRef mainbundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainbundle, CFSTR("Voicemail"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
    
    CFRelease(soundFileURLRef);
}

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[super viewDidLoad];

    
    //self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[self initialize];


    
    backgroundView.hidden = YES;
	[self.view addSubview:backgroundView];


	//go Back to main menu
	[NSTimer scheduledTimerWithTimeInterval:4
		target:self
		selector:@selector(wakeup_display_login:)
		userInfo:nil
		repeats:NO];

    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
//    [self adjustViewsForOrientations:interfaceOrientation];
    
    [self start_animation_with_orientation:interfaceOrientation];

#if 1
    
    
#else
    
    self.splashScreen.image = [UIImage imageNamed:@"mestartup2000012.png"];

#endif
    
    
    

}

-(CGRect) deviceFrameWithOrientation:(UIInterfaceOrientation) orientation
{
    CGRect deviceBound = [UIScreen mainScreen].bounds;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight)
    {
        CGRect newBound = CGRectMake(0, 0, deviceBound.size.height, deviceBound.size.width);
        return newBound;
    }
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return deviceBound;
    }
    
    return deviceBound;
}

-(void)start_animation_with_orientation :(UIInterfaceOrientation) orientation
{
    CGRect deviceScreen = [self deviceFrameWithOrientation:orientation];
//    CGRect deviceScreen = CGRectMake(0, 0, 480, 320);
    sunBackground = [[UIImageView alloc]initWithFrame:deviceScreen];
    [sunBackground setImage:[UIImage imageNamed:@"ME-sun_background.png"]];
    
    UITextField * initTextView = [[UITextField alloc] initWithFrame:CGRectMake(deviceScreen.size.width/2 - 50, deviceScreen.size.height - 40, 200 , 30)];
    
    NSString * initString = NSLocalizedStringWithDefaultValue(@"Initialize", nil,
                                                              [NSBundle mainBundle],
                                                              @"INITIALIZING...", nil);
    [initTextView setTextColor:[UIColor blackColor]];
    [initTextView setText:initString];
    
    [self.view addSubview:sunBackground];
    [self.view bringSubviewToFront:sunBackground];
    [self.view addSubview:initTextView];
    [self.view bringSubviewToFront:initTextView];
    
    self.splashScreen = [[[UIImageView alloc ] initWithFrame:deviceScreen] autorelease];
    [self.splashScreen setImage:[UIImage imageNamed:@"mestartup000032.png"]];
    [self.splashScreen setContentMode:UIViewContentModeScaleAspectFit];
    
    self.splashScreen.animationImages =[NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"mestartup000020.png"],
                                        [UIImage imageNamed:@"mestartup000021.png"],
                                        [UIImage imageNamed:@"mestartup000022.png"],
                                        [UIImage imageNamed:@"mestartup000023.png"],
                                        [UIImage imageNamed:@"mestartup000024.png"],
                                        [UIImage imageNamed:@"mestartup000025.png"],
                                        [UIImage imageNamed:@"mestartup000026.png"],
                                        [UIImage imageNamed:@"mestartup000027.png"],
                                        [UIImage imageNamed:@"mestartup000028.png"],
                                        [UIImage imageNamed:@"mestartup000029.png"],
                                        [UIImage imageNamed:@"mestartup000030.png"],
                                        [UIImage imageNamed:@"mestartup000031.png"],
                                        [UIImage imageNamed:@"mestartup000032.png"],
                                        nil];
    splashScreen.animationDuration = 3.5;
    splashScreen.animationRepeatCount = 1;
    
    [self.view addSubview:splashScreen];
    [self.view bringSubviewToFront:splashScreen];
    [self.view bringSubviewToFront:initTextView];
    
    [initTextView release];
    
    [splashScreen startAnimating];
    
    
    
//    [NSTimer scheduledTimerWithTimeInterval:0.1
//                                     target:self
//                                   selector:@selector(wakeup_start_animte:)
//                                   userInfo:nil
//                                    repeats:NO];
}


- (void)wakeup_start_animte:(NSTimer*) timer_exp
{

    NSLog(@"is animating? %d", [self.splashScreen isAnimating]);
    
    NSLog(@"animating images == nil? %d", (self.splashScreen.animationImages == nil));
    NSLog(@"count? %d", [self.splashScreen.animationImages count]);
    //[self.splashScreen startAnimating];
    
}

- (void)wakeup_display_login:(NSTimer*) timer_exp
{


    
#if 0
    NSLog(@">>> DBG PLAYER  ");
    PlaybackViewController *playbackViewController = [[PlaybackViewController alloc] init];
    //playbackViewController.urlVideo = @"http://nxcomm:2009nxcomm@nxcomm-office.no-ip.info/app_release/sub_clips/48022A2CAC31_04_20130917065256730_00001.flv";
    
    playbackViewController.urlVideo = @"http://s3.amazonaws.com/sm.wowza.content/48022A2CAC31/clips/48022A2CAC31_04_20130918083756010_00001_last.flv?AWSAccessKeyId=AKIAIDBFDZTAR2EB4KPQ&Expires=1379501535&Signature=m%2FGcG%2BOh8wlwXcWqkiw%2BztAqAn8%3D"; 
    
    //[playbackViewController autorelease];
    
    [self presentViewController:playbackViewController animated:NO  completion:nil];
#else
    
    
	//hide splash screen page
     backgroundView.hidden = NO;
    [self.view bringSubviewToFront:backgroundView];


    //load user/pass
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	//can be user email or user name here --
	NSString * old_usr = (NSString *) [userDefaults objectForKey:@"PortalUsername"];
	NSString * old_pass = (NSString *) [userDefaults objectForKey:@"PortalPassword"];
    
    if (old_usr  != nil && old_pass != nil)
    {
        
        [userDefaults setBool:TRUE forKey:_AutoLogin];
        [userDefaults synchronize];
        
        self.app_stage = APP_STAGE_LOGGING_IN;
        
        MBP_LoginOrRegistration * loginOrReg;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        else
        {
            loginOrReg = [[MBP_LoginOrRegistration alloc]
                          initWithNibName:@"MBP_LoginOrRegistration"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        
        //Use navigation controller
        [loginOrReg presentModallyOn:self];
    }
    else
    {
        //Showing first page here --- NEED to adapt to proper orientation
        self.app_stage = APP_STAGE_INIT;
        
        MBP_FirstPage * firstPage = nil;
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                            bundle:nil
                                                  withConnDelegate:self];
            }
            else
            {
                firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_land"
                                                            bundle:nil
                                                  withConnDelegate:self];
            }
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
                 interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                            bundle:nil
                                                  withConnDelegate:self];
            }
            else
            {
                firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage"
                                                            bundle:nil
                                                  withConnDelegate:self];
            }
        }

        
        
        //[self presentModalViewController:firstPage animated:NO];
        [self presentViewController:firstPage animated:NO completion:^{}];
    }
#endif


}


- (void)wakeup_display_first_page:(NSTimer*) timer_exp
{
    
	self.app_stage = APP_STAGE_INIT;
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    MBP_FirstPage * firstPage = nil;
    [self.view addSubview:backgroundView];
    [self.view bringSubviewToFront:backgroundView];
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        else
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_land"
                                                        bundle:nil
                                              withConnDelegate:self];
        }    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage_ipad"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
        else
        {
            firstPage = [[MBP_FirstPage alloc] initWithNibName:@"MBP_FirstPage"
                                                        bundle:nil
                                              withConnDelegate:self];
        }
    }
    

    //[self presentModalViewController:firstPage animated:NO];
    [self presentViewController:firstPage animated:NO completion:^{}];
    
}




-(void) startShowingCameraList
{

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSLog(@"Load IPad");
        
        dashBoard = [[DashBoard_ViewController alloc] initWithNibName:@"DashBoard_ViewController_ipad"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }
    else
    {
        NSLog(@"Load IPhne");

        dashBoard = [[DashBoard_ViewController alloc] initWithNibName:@"DashBoard_ViewController"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }


	


	NSMutableArray * validChannels = [[NSMutableArray alloc]init ];

	for (int i =0 ; i< [channel_array count]; i++)
	{
		CamChannel * ch = [channel_array objectAtIndex:i]; 
		if (ch.profile != nil)
			[validChannels addObject:[channel_array objectAtIndex:i]]; 

	}
    
	dashBoard.listOfChannel = validChannels;

	[dashBoard presentModallyOn:self];

    [validChannels release];
}



/*
// Override to allow orientations other than the default portrait orientation.
  */
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	return YES;

}




- (BOOL) shouldAutorotate
{
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskAllButUpsideDown;
}







- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {

	// [mainMenuView release];
    [_bonjourBrowser release];
    [splashScreen release];
    [sunBackground release];
	[bc_addr release];
	[own_addr release];

	[channel_array release]; 
	[restored_profiles release];

    [splashScreen release];
    [bonjourThread release];
	[super dealloc];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

}

#pragma mark -
#pragma mark Rotating



-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustViewsForOrientations:toInterfaceOrientation];
}

-(void) adjustViewsForOrientations: (UIInterfaceOrientation) interfaceOrientation
{
    CGRect newFrame = [self deviceFrameWithOrientation:interfaceOrientation];
    if (splashScreen)
    {
        [splashScreen setFrame:newFrame];
    }
    if (sunBackground)
    {
        [sunBackground setFrame:newFrame];
    }
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (sunBackground)
        {
            [sunBackground setImage:[UIImage imageNamed:@"ME-screen_landscape.png"]];
        }
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //[[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_land_ipad" owner:self options:nil];
            
//            UIImageView * splashScreen = (UIImageView*) [self.view viewWithTag:11];
//            
//            UIImage * landscapeImage = [UIImage imageNamed:@"bb_splash_screen_horizontal.png"];
//            
//            [splashScreen setImage:landscapeImage];
            
        }
        else
        {
            
            
//            UIImageView * splashScreen = (UIImageView*) [self.view viewWithTag:11];
//            
//            UIImage * landscapeImage = [UIImage imageNamed:@"bb_splash_screen_horizontal.png"];
//            
//            [splashScreen setImage:landscapeImage];

#if 0
            BOOL statusHidden = statusDialogLabel.hidden;
            
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_land" owner:self options:nil];
            
    
            statusDialogLabel.hidden = statusHidden;
            
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
            }
            
            self.view.transform = transform;
            
            self.view.frame = CGRectMake(0,0,  self.view.frame.size.height,self.view.frame.size.width);
#endif 
            
        }
        
       
        
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortrait ||
             interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if (sunBackground)
        {
            [sunBackground setImage:[UIImage imageNamed:@"ME-sun_background.png"]];
        }
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //[[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController_ipad" owner:self options:nil];
            
//            UIImageView * splashScreen = (UIImageView*) [self.view viewWithTag:11];
//            
//            UIImage * landscapeImage = [UIImage imageNamed:@"splash_screen_portrait.png"];
//            
//            [splashScreen setImage:landscapeImage];

        }
        else
        {
            
//            UIImageView * splashScreen = (UIImageView*) [self.view viewWithTag:11];
//            
//            UIImage * landscapeImage = [UIImage imageNamed:@"splash_screen_portrait.png"];
//            
//            [splashScreen setImage:landscapeImage];
            
#if 0
            BOOL statusHidden = statusDialogLabel.hidden;
            [[NSBundle mainBundle] loadNibNamed:@"MBP_iosViewController" owner:self options:nil];
            
            statusDialogLabel.hidden = statusHidden;
#endif
        }
    }
    
   
}

#pragma mark -
#pragma mark ConnectionMethodDelegate - Views navigation 

/**** Main program switching point is here *****/ 
- (void)sendStatus:(int) method
{

	switch (method) {
		case SETUP_CAMERA: 
			{

				
                
                
				[self dismissViewControllerAnimated:NO completion:nil];


                NSLog(@">>> SETUP ");
                self.app_stage = APP_STAGE_SETUP;

                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                BOOL isFirstTimeSetup = [userDefaults boolForKey:FIRST_TIME_SETUP];
                if (isFirstTimeSetup ==FALSE)
                {

                    //Normal add cam sequence
                    //Load the next xib
                    Step_02_ViewController *step02ViewController = nil;
                    
                    
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        step02ViewController = [[Step_02_ViewController alloc]
                                                initWithNibName:@"Step_02_ViewController_ipad" bundle:nil];
                    }
                    else
                    {
                        
                        step02ViewController = [[Step_02_ViewController alloc]
                                                initWithNibName:@"Step_02_ViewController" bundle:nil];
                    }
                    
                    step02ViewController.delegate = self;
                    [step02ViewController presentModallyOn:self];
                }
                else
                {
                    
                    MBP_InitialSetupViewController *initSeupViewController = nil;
                    
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    {
                        
                        initSeupViewController = [[MBP_InitialSetupViewController alloc]
                                                  initWithNibName:@"MBP_InitialSetupViewController_ipad" bundle:nil];
                        
                    }
                    else
                    {   
                        initSeupViewController = [[MBP_InitialSetupViewController alloc]
                                                  initWithNibName:@"MBP_InitialSetupViewController" bundle:nil];
                        
                    }
                    
                    initSeupViewController.delegate = self;
                    [initSeupViewController presentModallyOn:self];
                    
                }

				break;
			}
		case LOGIN: //GOTO ROUTER mode - Login
			{
				//NSLog(@">>> Login "); 

				[self dismissViewControllerAnimated:NO completion:nil];
                
                self.app_stage = APP_STAGE_LOGGING_IN;
                
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];

                
                MBP_LoginOrRegistration * loginOrReg;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                                           bundle:nil
                                                                 withConnDelegate:self];
                }
                else
                {
                    loginOrReg = [[MBP_LoginOrRegistration alloc]
                                  initWithNibName:@"MBP_LoginOrRegistration"
                                  bundle:nil
                                  withConnDelegate:self];
                }


				


				//Use navigation controller 
				[loginOrReg presentModallyOn:self];
				break;
			}
		case SCAN_CAMERA:
			//may be offline mode
            NSLog(@"start scanning"); 
            statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;

            isRebinded = [self rebindCameraResource];
			[self performSelector:@selector(scan_for_devices)
                       withObject:nil
                       afterDelay:0.1];

			//Back from login- login success 
			[self dismissViewControllerAnimated:NO completion:nil];
			self.progressView.hidden = NO;

			break; 
		case AFTER_ADD_RELOGIN:
			{
				NSLog(@" back from adding cam. relogin -- to get the new cam data");

				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];



				[NSTimer scheduledTimerWithTimeInterval:0.01
					target:self
					selector:@selector(show_login_or_reg:)
					userInfo:nil
					repeats:NO];

				break; 
			}
		case AFTER_DEL_RELOGIN: //Just remove camera, currently in CameraMenu page 
			{

                statusDialogLabel.hidden = YES;
				[self dismissViewControllerAnimated:NO completion:nil];
                
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				[userDefaults setBool:TRUE forKey:_AutoLogin];
				[userDefaults synchronize];

				[NSTimer scheduledTimerWithTimeInterval:2.0
					target:self
					selector:@selector(show_login_or_reg:)
					userInfo:nil
					repeats:NO];

				break;
			}
		case  BACK_FRM_MENU_NOLOAD: //USED by AppDelegate as well.. please check if modifying this case
			{
				NSLog(@"Back from menu");
                statusDialogLabel.hidden = YES;
				[self dismissViewControllerAnimated:NO completion:nil];
				//[self.streamer startStreaming];
                


				break;
			}
		case  FRONT_PAGE:
			{
				NSLog(@" display first page ");
                statusDialogLabel.hidden = YES;
                [self dismissViewControllerAnimated:NO completion:nil];
        
                [NSTimer scheduledTimerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(wakeup_display_first_page:)
                                               userInfo:nil
                                                repeats:NO];

				break;
			}
		case LOGIN_FAILED_OR_LOGOUT : //back from login -failed Or logout
			{
                statusDialogLabel.hidden = YES;
				[self dismissViewControllerAnimated:NO completion:nil];
                self.app_stage = APP_STAGE_LOGGING_IN;
                
                [self performSelectorInBackground:@selector(logoutAndUnregistration_bg) withObject:nil];
			
				break;
			}
        case SCAN_BONJOUR_CAMERA :
        {
            /*
             20130523_nguyendang :
             Scan camera with bonjour here
             If have any problem ? Back to Scan_for_camera
             */
            NSLog(@"start scanning Bonjour");
            
            statusDialogLabel.hidden = NO;
			self.app_stage = APP_STAGE_LOGGED_IN;
            
            isRebinded = [self rebindCameraResource];
            [self callForStartScanningBonjour];
            [self scan_for_devices];
            
            //Back from login- login success
            //[self dismissModalViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:NO completion:^{}];
            self.progressView.hidden = NO;


            
            break;
        }
		default:
			break;
	}

}

-(BOOL) rebindCameraResource
{
    BOOL restore_successful = FALSE;
    restore_successful = [self restoreConfigData];
    if (restore_successful == YES)
    {
        CamChannel* ch = nil;
        
        for (int i = 0; i< [channel_array count]; i++)
        {
            ch = (CamChannel*) [channel_array objectAtIndex:i];
            
            if ( ch.profile != nil)
            {
                for (int j = 0; j < [restored_profiles count]; j++)
                {
                    CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                    if ( !cp.isSelected //&&
                        //[cp.mac_address isEqualToString:ch.profile.mac_address]
                        )
                    {
                        //Re-bind camera - channel
                        
                        [ch setCamProfile:cp];
                        cp.isSelected = TRUE;
                        [cp setChannel:ch];
                        break;
                        
                    }
                    
                    
                }
            }
            else {
                
                //NSLog(@"channel profile = nil");
            }
            
            
        }
    }
    return restore_successful;
}


-(void) callForStartScanningBonjour
{
    
    if (isRebinded)
    {
        
        
        if ( [self isCurrentConnection3G] ||
            [self.restored_profiles count] ==0)
        {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            
            
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                
                cp.isInLocal = FALSE;
                cp.hasUpdateLocalStatus = TRUE;
            }
            
            
            
            
            [self finish_scanning];
        }
        else
        {
            bonjourThread = [[NSThread alloc] initWithTarget:self selector:@selector(scan_with_bonjour) object:nil];
            [bonjourThread start];
        }
        
//        [self startShowingCameraList];
    }
}

-(void) scan_with_bonjour
{
    @autoreleasepool
    {
        NSDate * endDate;
        _bonjourBrowser = [[[Bonjour alloc] initSetupWith:self.restored_profiles] autorelease];
        [_bonjourBrowser setDelegate:self];
        
        [_bonjourBrowser startScanLocalWiFi];
        
        endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while (_bonjourBrowser.isSearching)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        bonjourList = _bonjourBrowser.cameraList;
    }
    
    [NSThread exit];
}

- (BOOL) isThisMacStoredOffline:(NSString*) mac_without_colon
{

	if (self.restored_profiles == nil &&
			self.channel_array == nil)
	{
		// No offline data is available --> force re login
		return FALSE;

	}


	CamProfile * cp = nil;
	for (int i =0; i< [self.restored_profiles count]; i++)
	{
		cp = (CamProfile *) [self.restored_profiles objectAtIndex:i];
		if (cp!= nil &&
				cp.mac_address != nil )
		{
			NSString *  mac_wo_colon = [Util strip_colon_fr_mac:cp.mac_address];
			if ([mac_wo_colon isEqualToString:mac_without_colon])
			{
				return TRUE;
			}
		}

	}


	return FALSE; 
}




-(BOOL) isServerAnnouncement: (CameraAlert *) camAlert
{
    if ( [camAlert.alertType isEqualToString:ALERT_GENERIC_SERVER_INFO]  )
    {
        
        return TRUE;
    }
    
    
    
    return FALSE;
}


-(BOOL) pushNotificationRcvedInForeground:(CameraAlert *) camAlert
{
    // IF this is just a server announcement - Dont do anything -
    if ([self isServerAnnouncement:camAlert])
    {
        
        
        
        NSString * ignore = NSLocalizedStringWithDefaultValue(@"close",nil, [NSBundle mainBundle],
                                                              @"Close", nil);
        
        NSString * details = NSLocalizedStringWithDefaultValue(@"detail",nil, [NSBundle mainBundle],
                                                              @"Detail", nil);
        

        
        NSString * msg = camAlert.alertVal;
        
        
        
        

        
        
        pushAlert = [[AlertPrompt alloc]
                     initWithTitle:camAlert.cameraName
                     message:msg
                     delegate:self
                     cancelButtonTitle:ignore
                     otherButtonTitles:details, nil];
        ((AlertPrompt*)pushAlert).otherInfo = camAlert.server_url;
        
        pushAlert.tag = ALERT_PUSH_SERVER_ANNOUNCEMENT;
        
        [self playSound];
        [pushAlert show];
        
        
        
        
        return FALSE ;
        
    }
    
    //Check if we should popup
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	//mac with COLON
	NSString * camInView = (NSString*)[userDefaults objectForKey:CAM_IN_VEW];
    
    NSLog(@"camInView: %@", camInView);
	
    if (camInView != nil)
	{
		if ( [[Util strip_colon_fr_mac:camInView] isEqualToString:camAlert.cameraMacNoColon])
		{
			NSLog(@"Silencely return, don't popup");
			return FALSE;
		}
        
	}
    
    if (self.app_stage == APP_STAGE_SETUP)
    {
        NSLog(@"APP_STAGE_SETUP. Don't popup!");
        return FALSE;
    }
    
    if (latestCamAlert != nil && [latestCamAlert.cameraMacNoColon  isEqualToString:camAlert.cameraMacNoColon])
    {
        NSLog(@"Same cam alert is currenlty stored.");
        
        if (pushAlert != nil &&
            [pushAlert isVisible])
        {
            NSLog(@"Dialog exist, don't popup");
            
            @synchronized(self)
            {
                
                //keep the reference here
                if (latestCamAlert != nil)
                {
                    [latestCamAlert release];
                    latestCamAlert = nil;
                }
                latestCamAlert = camAlert;
                
            }
            
             return FALSE;
        }
    }
    
      

    
    
    NSString * msg = NSLocalizedStringWithDefaultValue(@"Sound_detected",nil, [NSBundle mainBundle],
                                                       @"Sound detected", nil);
    
    
    
    if ( [camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_HI]  )
    {
        msg =NSLocalizedStringWithDefaultValue( @"Temperature_too_high",nil, [NSBundle mainBundle],
                                               @"Temperature too high", nil);
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_TEMP_LO])
    {
        msg =NSLocalizedStringWithDefaultValue( @"Temperature_too_low",nil, [NSBundle mainBundle],
                                               @"Temperature too low", nil);
    }
    else if ([camAlert.alertType isEqualToString:ALERT_TYPE_MOTION])
    {
        msg =NSLocalizedStringWithDefaultValue( @"Motion Detected",nil, [NSBundle mainBundle],
                                               @"Motion Detected", nil);
    }
    
    
    NSString * cancel = NSLocalizedStringWithDefaultValue(@"Cancel",nil, [NSBundle mainBundle],
                                                          @"Cancel", nil);
    
    NSString * msg2 = NSLocalizedStringWithDefaultValue(@"View_snapshot",nil, [NSBundle mainBundle],
                                                        @"View Snapshot", nil);
    
    if (pushAlert != nil )
    {
        if ([pushAlert isVisible])
        {
            [pushAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
        
        [pushAlert release];
    }
    
    
    
    
    pushAlert = [[UIAlertView alloc]
                 initWithTitle:camAlert.cameraName
                 message:msg
                 delegate:self
                 cancelButtonTitle:cancel
                 otherButtonTitles:msg2,nil];
    
    //if ([self isThisMacStoredOffline:camAlert.cameraMacNoColon])
    {
        
        pushAlert.tag = ALERT_PUSH_RECVED_RESCAN_AFTER;
        
        
        
    }
    //	else
    //	{
    //		NSLog(@"Relogin");
    //		[self sendStatus:2];
    //		pushAlert.tag = ALERT_PUSH_RECVED_RELOGIN_AFTER;
    //	}
    
    @synchronized(self)
    {
        
        //keep the reference here
        if (latestCamAlert != nil)
        {
            [latestCamAlert release];
            latestCamAlert = nil;
        }
        latestCamAlert = camAlert;
        
    }
    
    
    [self playSound];
    
    [pushAlert show];
    
    
    

	return TRUE;

}



-(void) playSound
{
	
    
	//NSLog(@"Play the B");
    
    
	//201201011 This is needed to play the system sound on top of audio from camera
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;    // 1
	AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,                        // 2
                             sizeof (sessionCategory),                                   // 3
                             &sessionCategory                                            // 4
                             );
    
	//Play beep
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AudioServicesPlaySystemSound(soundFileObject);
    }
    else
    {
        AudioServicesPlayAlertSound(soundFileObject);
    }
    
    
    
}

-(void) logoutAndUnregistration_bg
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"De-Register push with both parties: APNs and BMS ");
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *apiKey = [userDefaults objectForKey:@"PortalApiKey"];
    NSString *appId = [userDefaults objectForKey:@"APP_ID"];
    
    //REmove password and registration id
    [userDefaults removeObjectForKey:@"PortalPassword"];
    [userDefaults removeObjectForKey:_push_dev_token];
    
    [userDefaults synchronize];
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    BMS_JSON_Communication *jsonComm = [[[BMS_JSON_Communication alloc] initWithObject:self
                                                                             Selector:nil
                                                                         FailSelector:nil
                                                                            ServerErr:nil] autorelease];
    
    NSDictionary *responseDict = [jsonComm deleteAppBlockedWithAppId:appId
                                                           andApiKey:apiKey];
    NSLog(@"logout --> delete app status = %d", [[responseDict objectForKey:@"status"] intValue]);
    
    [NSThread sleepForTimeInterval:0.10];
    
    [self performSelectorOnMainThread:@selector(show_login_or_reg:)
                           withObject:nil
                        waitUntilDone:NO];
    
	[pool release];
}

#pragma mark -
#pragma mark Alertview delegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
	int tag = alertView.tag ;
    
	if (tag == ALERT_PUSH_RECVED_RESCAN_AFTER)
	{
		switch(buttonIndex)
        {
			case 0:
                [pushAlert release];
                pushAlert = nil;
				break;
			case 1:
            {
				if (dashBoard != nil)
				{
					NSLog(@"RESCAN_AFTER close all windows and thread");
                    
					NSArray * views = dashBoard.navigationController.viewControllers;
					NSLog(@"views count = %d",[views count] );
					if ( [views count] > 1)
					{
                        if (views.count > 2)
                        {
                            id obj2 = [views objectAtIndex:2];
                            
                            if ([obj2 isKindOfClass:[PlaybackViewController class]])
                            {
                                PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                                [playbackViewController stopStream:nil];
                            }
                        }
                        
                        id obj = [views objectAtIndex:1];
                        
                        if ([obj isKindOfClass:[H264PlayerViewController class]])
                        {
                            H264PlayerViewController * h264PlayerViewController = (H264PlayerViewController *) obj;
                            [h264PlayerViewController goBackToCameraList];
                        }
					}
				}
                
				[self dismissViewControllerAnimated:NO completion:nil];
                
#if 0
				NSLog(@"Re-scan ");
				[self sendStatus:3];
                
#endif
                NotificationViewController * notif_view;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    notif_view = [[[NotificationViewController alloc]
                                   initWithNibName:@"NotificationViewController_ipad" bundle:nil]autorelease];
                }
                else
                {
                    notif_view = [[[NotificationViewController alloc]
                                   initWithNibName:@"NotificationViewController" bundle:nil]autorelease];
                }

                
                
                @synchronized(self)
                {
                    //Feed in data now
                    notif_view.cameraMacNoColon = latestCamAlert.cameraMacNoColon;
                    notif_view.cameraName  = latestCamAlert.cameraName;
                    notif_view.alertType   = latestCamAlert.alertType;
                    notif_view.alertVal    = latestCamAlert.alertVal;
                    
                    notif_view.delegate = self;
                    
                    [latestCamAlert release];
                    latestCamAlert = nil;
                }
                
                [notif_view presentModallyOn:self];
                
                [pushAlert release];
                pushAlert = nil;
				break;
            }
			default:
				break;
                
		}
	}
	else if (tag == ALERT_PUSH_RECVED_RELOGIN_AFTER)
	{
		switch(buttonIndex)
        {
			case 0:
				break;
			case 1:
                
				if (dashBoard != nil)
				{
					NSLog(@"RELOGIN_AFTER close all windows and thread");
                    
					//[dashBoard.navigationController popToRootViewControllerAnimated:NO];
                    
					NSArray * views = dashBoard.navigationController.viewControllers;
					NSLog(@"views count = %d",[views count] );
					if ( [views count] > 1)
					{
						if (views.count > 2)
                        {
                            id obj2 = [views objectAtIndex:2];
                            
                            if ([obj2 isKindOfClass:[PlaybackViewController class]])
                            {
                                PlaybackViewController *playbackViewController = (PlaybackViewController *)obj2;
                                [playbackViewController stopStream:nil];
                            }
                        }
                        
                        id obj = [views objectAtIndex:1];
                        
                        if ([obj isKindOfClass:[H264PlayerViewController class]])
                        {
                            H264PlayerViewController * h264PlayerViewController = (H264PlayerViewController *) obj;
                            [h264PlayerViewController goBackToCameraList];
                        }
					}
				}
                
				//[self dismissModalViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:NO completion:^{}];
                
                
				[self sendStatus:2];
				break;
			default:
				break;
                
		}
	}
    else if (tag == ALERT_PUSH_SERVER_ANNOUNCEMENT)
    {
        switch(buttonIndex)
        {
			case 0://IGNORE
				break;
			case 1://Detail
            {
                // Open the web browser now..
                NSString * url =  ((AlertPrompt*)alertView).otherInfo;
                
                
                if (url != nil)
                {
                    if ( [url hasPrefix:@"http://"] != TRUE)
                    {
                        url  = [NSString stringWithFormat:@"http://%@", url];
                    }
                    
                    
                    NSLog(@"final url:%@ ",url);
                    
                    NSURL *ns_url = [NSURL URLWithString:url];
                    
                    [[UIApplication sharedApplication] openURL:ns_url];
                }
                break;
            }
            default:
                break;
        }
    }
    
}



#pragma mark -


#pragma mark -
#pragma mark Scan For cameras


- (void) scan_for_devices
{
    if (isRebinded)
	{
        
        if ( [self isCurrentConnection3G] ||
            [self.restored_profiles count] ==0 )
        {
            NSLog(@" Connection over 3g OR empty cam list  --> Skip scanning all together");
            
            
            for (int j = 0; j < [restored_profiles count]; j++)
            {
                CamProfile * cp = (CamProfile *) [restored_profiles objectAtIndex:j];
                
                cp.isInLocal = FALSE;
                cp.hasUpdateLocalStatus = TRUE;
            }
            
            
            
            
            [self finish_scanning];
        }
        else
        {
            nextCameraToScanIndex = 0;
            [self scan_next_camera:self.restored_profiles index:nextCameraToScanIndex];
            
        }
        
        
      
        [self performSelectorOnMainThread:@selector(startShowingCameraList) withObject:nil waitUntilDone:NO];
    }
}

- (void) scan_next_camera:(NSArray *) profiles index:(int) i
{
    NSMutableArray * finalResult = [[NSMutableArray alloc] init];
    CamProfile * cp = nil;
    
    BOOL skipScan = FALSE;

    cp =(CamProfile *) [profiles objectAtIndex:i];
        
    if (cp != nil &&
        cp.mac_address !=nil)
    {
        
        //Check if we are in the same network as the camera.. IF so
        // Try to scan .. otherwise... no point ..
        //20121130: phung: incase the ip address is not valid... also try to scan ..
        if (cp.ip_address == nil || [self isInTheSameNetworkAsCamera:cp ])
        {
            skipScan = [self isCurrentIpAddressValid:cp];
            
            if (skipScan)
            {
                
                cp.port = 80;
                //Dont need to scan.. call scan_done directly
                [finalResult addObject:cp];
                
                [self performSelector:@selector(scan_done:)
                           withObject:finalResult afterDelay:0.1];
                
            }
            else // NEED to do local scan
            {
                ScanForCamera *scanner = [[ScanForCamera alloc] initWithNotifier:self];
                [scanner scan_for_device:cp.mac_address];
                
                
                
            } /* skipScan = false*/
            
        }
        else
        {
            //Skip scanning too and assume we don't get any result
            [self performSelector:@selector(scan_done:)
                       withObject:nil afterDelay:0.1];
        }
        
        
    }
    
    [finalResult release];
}

- (void)scan_done:(NSArray *) _scan_results
{
    //limit value of nextCameraToScanIndex
    if (nextCameraToScanIndex > ([self.restored_profiles count] - 1))
        return;
     CamProfile * cp =(CamProfile *) [self.restored_profiles objectAtIndex:nextCameraToScanIndex];
    //scan Done. read scan result
    
    
    
    if ( _scan_results == nil  || [_scan_results count] == 0 )
    {
        //Empty ..not found & also can't use the current IP?
        //Dont add to the final result
        cp.isInLocal = FALSE;
        cp.hasUpdateLocalStatus = TRUE;
       
    }
    else
    {
        //found the camera ..
        // --> update local IP and other info
       
        CamProfile* scanned;
        for (int i=0 ; i< [_scan_results count]; i++)
        {
            scanned = ((CamProfile*) [_scan_results objectAtIndex:i]);
            
            if ([scanned.mac_address isEqualToString:cp.mac_address])
            {
                cp.ip_address = ((CamProfile*) [_scan_results objectAtIndex:i]).ip_address;
                cp.isInLocal = TRUE;
                cp.port = ((CamProfile*) [_scan_results objectAtIndex:i]).port;//localport is always 80
                
            }
            
        }
    }
    
    cp.hasUpdateLocalStatus = TRUE;

    NSLog(@"cam:%@ is in Local? %d fw:%@", cp.mac_address, cp.isInLocal, cp.fw_version);
    ++ nextCameraToScanIndex;
    [self scanNextIndex:&nextCameraToScanIndex];
}

- (void) scanNextIndex: (int *) index
{
    // Stop scanning
    if (*index == [self.restored_profiles count])
    {
        NSLog(@"Scan done with ipserver");
//        [self startShowingCameraList];
        NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
        while ([bonjourThread isExecuting])
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:endDate];
        }
        

        if(bonjourList && [bonjourList count] != 0)
        {
            for (CamProfile * cp in restored_profiles)
            {
                for (CamProfile * cam in bonjourList)
                {
                    if ([cp.mac_address isEqualToString:cam.mac_address])
                    {
                        NSLog(@"Camera %@ is on Bonjour",cp.mac_address);
                        cp.hasUpdateLocalStatus = YES;
                        cp.ip_address = cam.ip_address;
                        cp.isInLocal = YES;
                        cp.port = 80;
                    }
                }
            }
        }
        
        [self finish_scanning];
    }
    // this camera at index has not been scanned
    else if (*index < [self.restored_profiles count] &&
        ((CamProfile *)[self.restored_profiles objectAtIndex:*index]).hasUpdateLocalStatus == NO)
    {
        if (dashBoard != nil)
        {
            NSLog(@"reload dashboard in scan_done");
            [dashBoard.cameraList reloadData];
            
        }
        
        [self scan_next_camera:self.restored_profiles index:*index];
    }
    // this camera at index has been scanned
    else if (*index < [self.restored_profiles count] &&
             ((CamProfile *)[self.restored_profiles objectAtIndex:*index]).hasUpdateLocalStatus == YES)
    {
        if (dashBoard != nil)
        {
            NSLog(@"reload dashboard in scan_done");
            [dashBoard.cameraList reloadData];
            
        }
        ++(*index);
        [self scanNextIndex:index];
    }
    
}

- (void)finish_scanning
{
    
	//Hide it, since we're done
	self.progressView.hidden = YES;
    
    
    //TODO: Need to save offline data here???
    
    if (dashBoard != nil)
    {
        NSLog(@"reload dashboard in finish");
        //[dashBoard setupTopBarForEditMode:dashBoard.editModeEnabled];
        
        [dashBoard.cameraList reloadData];
        
    }
        
}



-(BOOL) isInTheSameNetworkAsCamera :(CamProfile *) cp
{
    long ip = 0, ownip =0 ;
    long netMask = 0 ;
	struct ifaddrs *ifa = NULL, *ifList;
    
    NSString * bc = @"";
	NSString * own = @"";
	[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own ipasLong:&ownip];
    
    
    getifaddrs(&ifList); // should check for errors
    for (ifa = ifList; ifa != NULL; ifa = ifa->ifa_next) {
        
        
        if (ifa->ifa_netmask != NULL)
        {
            ip = (( struct sockaddr_in *)ifa->ifa_addr)->sin_addr.s_addr;
            if (ip == ownip)
            {
                netMask = (( struct sockaddr_in *)ifa->ifa_netmask)->sin_addr.s_addr;
                
                break;
            }
        }
        
    }
    freeifaddrs(ifList); // clean up after yourself
    
    
    if (netMask ==0 || ip ==0)
    {
        return FALSE;
    }
    
    long camera_ip =0 ;
    if (cp != nil &&
        cp.ip_address != nil)
    {
        NSArray * tokens = [cp.ip_address componentsSeparatedByString:@"."];
        if ([tokens count] != 4)
        {
            //sth is wrong
            return FALSE;
        }
        
        camera_ip = [tokens[0] integerValue] |
        ([tokens[1] integerValue] << 8) |
        ([tokens[2] integerValue] << 16) |
        ([tokens[3] integerValue] << 24) ;
        
        
        
        if ( (camera_ip & netMask) == (ip & netMask))
        {
            NSLog(@"in same subnet");
            return TRUE;
        }
    }
    
    return FALSE;
    
}

-(BOOL) isCurrentIpAddressValid :(CamProfile *) cp
{
    
    
    
    if (cp != nil &&
        cp.ip_address != nil)
    {
        HttpCommunication * dev_com = [[[HttpCommunication alloc] init] autorelease];
        
        dev_com.device_ip = cp.ip_address;
        
        NSString * mac = [dev_com sendCommandAndBlock:GET_MAC_ADDRESS withTimeout:3.0];
        
        if (mac != nil && mac.length == 12)
        {
            mac = [Util add_colon_to_mac:mac];
            
            
            if([mac isEqualToString:cp.mac_address])
            {
                return TRUE;
            }
        }
        
    }
    
    
    return FALSE;
}


#pragma mark -
#pragma mark 3G connection checks


-(BOOL) isCurrentConnection3G
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        //No internet
    }
    else if (status == ReachableViaWiFi)
    {
        //WiFi
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        
        return TRUE;
    }
   
    
     return FALSE;
    
}


#pragma mark -






+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip
{

	//Free & re-init Addresses
	FreeAddresses();

    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;

	NSString * log = @"";


	int i;

	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;

		theAddr = ip_addrs[i];

		if (theAddr == INVALID_IP)
		{

			break;
		}

		if (theAddr == localHost) continue;

		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
		}



		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		// broadcast_addrs[i]);

		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i], 
		    broadcast_addrs[i]];

	}


	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];

	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}

	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}

	
	return ;
}
+ (void)getBroadcastAddress:(NSString **) bcast AndOwnIp:(NSString**) ownip ipasLong:(long *) _ownip
{
    
	//Free & re-init Addresses
	FreeAddresses();

    GetIPAddresses();
	GetHWAddresses();
	NSString *deviceBroadcastIP = nil;
	NSString *deviceIP = nil ;
    
	NSString * log = @"";
    
    
	int i;
    
	for (i=0; i<MAXADDRS; ++i)
	{
		static unsigned long localHost = 0x7F000001;		// 127.0.0.1
		unsigned long theAddr;
        
		theAddr = ip_addrs[i];
        
		if (theAddr == INVALID_IP)
		{
            
			break;
		}
        
		if (theAddr == localHost) continue;
        
		if (strncmp(if_names[i], "en", strlen("en")) == 0)
		{
			deviceBroadcastIP =  [NSString stringWithFormat:@"%s", broadcast_addrs[i]];
			deviceIP = [NSString stringWithFormat:@"%s", ip_names[i]];
            *_ownip = ip_addrs[i];
		}
        
        
        
		//NSLog(@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
		// broadcast_addrs[i]);
        
		log = [log stringByAppendingFormat:@"%d %s %s %s %s\n", i, if_names[i], hw_addrs[i], ip_names[i],
               broadcast_addrs[i]];
        
	}
    
    
	//For Iphone4
	//deviceBroadcastIP = [NSString stringWithFormat:@"%s", broadcast_addrs[i-1]];
    
	//NSLog(@"broadcast iP: %d %@",i, deviceBroadcastIP);
	//NSLog(@"own iP: %d %@",i, deviceIP);
	if (deviceIP != nil)
	{
		*ownip = [NSString stringWithString:deviceIP];
	}
    
	if (deviceBroadcastIP != nil)
	{
		*bcast = [NSString stringWithString:deviceBroadcastIP];
	}
    
	
	return ;
}

#pragma mark -
#pragma mark SetupHTTPDelegate --- NOT USED --- check ..



-(void) show_login_or_reg:(NSTimer*) exp
{

	NSLog(@"show_login..."); 

    self.app_stage = APP_STAGE_LOGGING_IN;

    MBP_LoginOrRegistration * loginOrReg;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        loginOrReg = [[MBP_LoginOrRegistration alloc] initWithNibName:@"MBP_LoginOrRegistration_ipad"
                                                               bundle:nil
                                                     withConnDelegate:self];
    }
    else
    {
        loginOrReg = [[MBP_LoginOrRegistration alloc]
                      initWithNibName:@"MBP_LoginOrRegistration"
                      bundle:nil
                      withConnDelegate:self];
    }



	//Use navigation controller
	[loginOrReg presentModallyOn:self];

}

- (void)showNotificationViewController: (NSTimer *)exp
{
    //Back from login- login success
    [self dismissViewControllerAnimated:NO completion:nil];
    self.progressView.hidden = NO;
    
    
    NotificationViewController * notif_view;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        notif_view = [[NotificationViewController alloc]
                      initWithNibName:@"NotificationViewController_ipad" bundle:nil];
    }
    else
    {
        notif_view = [[NotificationViewController alloc]
                      initWithNibName:@"NotificationViewController" bundle:nil];
    }

    

    
    notif_view.delegate = self;
    //Feed in data now
    notif_view.cameraMacNoColon = _camAlert.cameraMacNoColon;
    notif_view.cameraName  = _camAlert.cameraName;
    notif_view.alertType   = _camAlert.alertType;
    notif_view.alertVal    = _camAlert.alertVal;
    
    [notif_view presentModallyOn:self];
}

#pragma mark -
#pragma mark Read Configure data 




- (BOOL) restoreConfigData
{
	SetupData * savedData = [[SetupData alloc]init];
    
	if ([savedData restore_session_data] ==TRUE)
	{
		//NSLog(@"restored data done");
		self.channel_array = savedData.channels;

		self.restored_profiles = savedData.configured_cams;
	}
    
    [savedData release];

	return TRUE;
}

// clear one warning
- (void)bonjourReturnCameraListAvailable:(NSMutableArray *)cameraList
{
}


@end

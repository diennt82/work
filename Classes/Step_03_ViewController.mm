//
//  Step_03_ViewController.m
//  MBP_ios
//
//  Created by NxComm on 7/24/12.
//  Copyright (c) 2012 Smart Panda Ltd. All rights reserved.
//

#import "Step_03_ViewController.h"

@interface Step_03_ViewController ()

@end

@implementation Step_03_ViewController

@synthesize  inProgress;
@synthesize   cameraMac,  cameraName, homeWifiSSID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
         
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated {
	NSArray *viewControllers = self.navigationController.viewControllers;
	if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
		// View is disappearing because a new view controller was pushed onto the stack
		NSLog(@"New view controller was pushed");
	} else if ([viewControllers indexOfObject:self] == NSNotFound) {
		// View is disappearing because it was popped from the stack
		NSLog(@"View controller was popped --- We are closing down..task_cancelled = YES");
        
		task_cancelled = YES;
        
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"Detect Camera";
    
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    task_cancelled  = NO;
       
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(checkConnectionToCamera:) 
                                   userInfo:nil
                                    repeats:NO];
    
    self.homeWifiSSID = [CameraPassword fetchSSIDInfo];
    
        
    NSLog(@"homeWifiSSID: %@", self.homeWifiSSID);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    [homeWifiSSID release]; 
    [inProgress release];
    [cameraName release];
    [cameraMac release];
        [super dealloc];
}



- (IBAction)handleButtonPress:(id)sender
{
    int tag = ((UIButton*)sender).tag; 
    
    if (tag == OPEN_WIFI_BTN_TAG)
    {

        NSLog(@"Can't Open wifi"); 
        //Open wifi
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
    
}

-(void) showProgress:(NSTimer *) exp
{
    NSLog(@"show progress "); 
    
    //if (![Step_09_ViewController isWifiConnectionAvailable])
    {
        if (self.inProgress != nil)
        {
            NSLog(@"show progress 01 ");
            self.inProgress.hidden = NO;
            [self.view addSubview:self.inProgress];
            
            
        }

        
    }
    
   
        
}

- (void) hideProgess
{
    NSLog(@"hide progress"); 
    if (self.inProgress != nil)
    {
        self.inProgress.hidden = YES; 
    }

}


- (void) checkConnectionToCamera:(NSTimer *) expired
{
	
	
#if TARGET_IPHONE_SIMULATOR != 1
    
     NSLog(@"checkConnectionToCamera"); 
    
	NSString * bc1 = @"";
	NSString * own1 = @"";
	[MBP_iosViewController getBroadcastAddress:&bc1 AndOwnIp:&own1];
	//check for ip available before check for SSID to avoid crashing .. 
	if ([own1 isEqualToString:@""])
	{
		NSLog(@"IP is not available.. comeback later..");
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];	
		return; 
	}
    
    NSLog(@"checkConnectionToCamera 01"); 
#endif
	
    
    
   
	NSString * currentSSID = [CameraPassword fetchSSIDInfo];
	
    if ( currentSSID == nil ||
        self.homeWifiSSID  ==nil ||
        ![self.homeWifiSSID isEqualToString:currentSSID]
        )
    {
         NSLog(@"cshow progress 02");
        [self showProgress:nil];
       
    }
    
    
    
    
	 NSLog(@"checkConnectionToCamera 03: %@", currentSSID);
	if ([currentSSID hasPrefix:DEFAULT_SSID_PREFIX])
	{
		//yeah we're connected ... check for ip??
		
		NSString * bc = @"";
		NSString * own = @"";
		[MBP_iosViewController getBroadcastAddress:&bc AndOwnIp:&own];
		
		if ([own hasPrefix:DEFAULT_IP_PREFIX])
		{
			
           
			//remember the mac address .. very important
			self.cameraMac = [CameraPassword fetchBSSIDInfo];
			self.cameraName = currentSSID;
			
			NSLog(@"camera mac: %@ ip:%@", self.cameraMac, own );
			
			//dont reschedule another wake up 
            [self hideProgess]; 
			[self moveToNextStep]; 
			return; 
		}
		
	}
	
	
	if (task_cancelled == YES)
	{
		//Don't do any thing here
		
	}
	else {
        
		//check back later.. 
		[NSTimer scheduledTimerWithTimeInterval: 3// 
										 target:self
									   selector:@selector(checkConnectionToCamera:)
									   userInfo:nil
										repeats:NO];	
	}
}

-(void) moveToNextStep
{
    NSLog(@"Load step 4"); 
    //Load the next xib
    Step_04_ViewController *step04ViewController = [[Step_04_ViewController alloc]
                                                    initWithNibName:@"Step_04_ViewController" bundle:nil];
    
    
    step04ViewController.cameraMac =  self.cameraMac;
    step04ViewController.cameraName  =self.cameraName;
    
    [self.navigationController pushViewController:step04ViewController animated:NO];
    
    [step04ViewController release];
    
    
}

@end
